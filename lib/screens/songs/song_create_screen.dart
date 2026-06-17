import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../models/upload_source.dart';
import '../../services/auth_service.dart';
import '../../services/demo_audio_service.dart';
import '../../services/recording_service.dart';
import '../../services/song_service.dart';
import '../../widgets/brand_header.dart';

class SongCreateScreen extends StatefulWidget {
  const SongCreateScreen({super.key});

  @override
  State<SongCreateScreen> createState() => _SongCreateScreenState();
}

class _SongCreateScreenState extends State<SongCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  final _previewPlayer = AudioPlayer();
  final _recordingService = RecordingService();

  UploadSource? _demoSource;
  String? _recordedPath;
  bool _previewPlaying = false;
  bool _recording = false;
  bool _loading = false;
  int? _countdown;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _previewPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() => _previewPlaying = playing);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    _previewPlayer.dispose();
    _recordingService.deleteIfExists(_recordedPath);
    _recordingService.dispose();
    super.dispose();
  }

  Future<void> _runCountdown() async {
    for (var count = 3; count >= 1; count--) {
      if (!mounted) {
        return;
      }
      setState(() => _countdown = count);
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    if (mounted) {
      setState(() => _countdown = null);
    }
  }

  Future<void> _startRecording() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await _previewPlayer.stop();
      await _recordingService.deleteIfExists(_recordedPath);
      _recordedPath = null;
      _demoSource = null;

      await _runCountdown();
      final path = await _recordingService.startRecording(prefix: 'song');

      if (mounted) {
        setState(() {
          _recordedPath = path;
          _recording = true;
        });
      }
    } on StateError {
      setState(() {
        _errorText = 'マイクが使えませんでした。iPhone のマイク許可を確認してください。';
      });
    } catch (_) {
      setState(() {
        _errorText = '録音を開始できませんでした。もう一度試してください。';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_recording) {
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final path = await _recordingService.stopRecording();
      if (path == null) {
        throw StateError('recording_not_found');
      }

      await _previewPlayer.stop();
      await _previewPlayer.setFilePath(path);

      if (mounted) {
        setState(() {
          _recordedPath = path;
          _recording = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorText = '録音を保存できませんでした。もう一度録り直してください。';
        _recording = false;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _togglePreview() async {
    final path = _recordedPath;
    if (path == null) {
      return;
    }

    setState(() => _errorText = null);
    try {
      if (_previewPlaying) {
        await _previewPlayer.pause();
      } else {
        await _previewPlayer.stop();
        await _previewPlayer.setFilePath(path);
        await _previewPlayer.play();
      }
    } catch (_) {
      setState(() => _errorText = '録音した音源を再生できませんでした。');
    }
  }

  Future<void> _discardRecording() async {
    await _previewPlayer.stop();
    await _recordingService.deleteIfExists(_recordedPath);
    setState(() {
      _recordedPath = null;
      _demoSource = null;
      _errorText = null;
    });
  }

  Future<void> _useDemoAudio() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final demoSource = await context.read<DemoAudioService>().loadSongDemo();
      await _previewPlayer.stop();
      await _recordingService.deleteIfExists(_recordedPath);

      if (!mounted) {
        return;
      }

      setState(() {
        _demoSource = demoSource;
        _recordedPath = null;
        _recording = false;
      });
    } catch (_) {
      setState(() {
        _errorText = 'デモ音源を読み込めませんでした。';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_recording) {
      setState(() => _errorText = '録音中です。先に停止してください。');
      return;
    }
    if (_recordedPath == null && _demoSource == null) {
      setState(() => _errorText = 'まずは録音するか、デモ音源を使ってください。');
      return;
    }

    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      setState(() => _errorText = 'ログイン情報を確認してください');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await context.read<SongService>().createSong(
            title: _titleController.text.trim(),
            comment: _commentController.text.trim(),
            ownerUid: user.uid,
            ownerName: user.displayName ?? '名無し',
            filename: _recordedPath != null
                ? 'song_recording.m4a'
                : _demoSource!.filename,
            file: _recordedPath == null ? null : File(_recordedPath!),
            bytes: _demoSource?.bytes,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('曲を投稿しました')),
        );
        _formKey.currentState!.reset();
        _titleController.clear();
        _commentController.clear();
        await _discardRecording();
      }
    } catch (_) {
      setState(() => _errorText = '投稿できませんでした。Firebase 設定を確認してください。');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const BrandHeader(
          title: '曲を投稿',
          subtitle: 'まずはスマホで録って、そのまま投稿できます。',
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '曲名'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '曲名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '募集メッセージ',
                  hintText: '例: ギター募集、ドラム募集、コーラス歓迎',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '募集メッセージを入力してください';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. 3 秒カウントで録音する',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _recording
                      ? '録音中です。終わったら停止してください。'
                      : '録音を始めると 3 秒カウントのあと、そのまま録り始めます。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_countdown != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '$_countdown',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _loading || _recording || _countdown != null ? null : _startRecording,
                        icon: const Icon(Icons.fiber_manual_record_rounded),
                        label: const Text('録音を始める'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _loading && !_recording
                            ? null
                            : (_recording ? _stopRecording : null),
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('停止する'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _loading || _recording ? null : _useDemoAudio,
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('シミュレータ用にデモ音源を使う'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2. 録音を確認して投稿する',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (_recordedPath != null)
                  Row(
                    children: [
                      IconButton.filled(
                        onPressed: _togglePreview,
                        icon: Icon(
                          _previewPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('録音した音源を試聴する')),
                    ],
                  ),
                if (_demoSource != null)
                  Text(
                    '選択中: ${_demoSource!.label}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (_recordedPath == null && _demoSource == null)
                  const Text('まだ録音はありません。'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (_recordedPath == null && _demoSource == null) || _loading
                            ? null
                            : _discardRecording,
                        child: const Text('録り直す'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: Text(_loading ? '投稿中...' : 'この録音を投稿する'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 16),
          Text(
            _errorText!,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ],
      ],
    );
  }
}
