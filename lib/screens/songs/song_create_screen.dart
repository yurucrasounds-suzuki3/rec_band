import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/upload_source.dart';
import '../../services/auth_service.dart';
import '../../services/demo_audio_service.dart';
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
  PlatformFile? _pickedFile;
  UploadSource? _demoSource;
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = result.files.first;
          _demoSource = null;
          _errorText = null;
        });
      }
    } catch (_) {
      setState(() {
        _errorText = 'ファイルを開けませんでした。iPhone シミュレータなら Files に入れた音源を選んでください。';
      });
    }
  }

  Future<void> _useDemoAudio() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final demoSource = await context.read<DemoAudioService>().loadSongDemo();
      if (!mounted) {
        return;
      }
      setState(() {
        _pickedFile = null;
        _demoSource = demoSource;
      });
    } catch (_) {
      setState(() {
        _errorText = 'デモ音源を読み込めませんでした。アプリを再起動してもう一度試してください。';
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
    if (_pickedFile == null && _demoSource == null) {
      setState(() => _errorText = '音声ファイルを選んでください');
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
            filename: _pickedFile?.name ?? _demoSource!.filename,
            file: _pickedFile?.path == null ? null : File(_pickedFile!.path!),
            bytes: _pickedFile?.bytes ?? _demoSource!.bytes,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('曲を投稿しました')),
        );
        _formKey.currentState!.reset();
        _titleController.clear();
        _commentController.clear();
        setState(() {
          _pickedFile = null;
          _demoSource = null;
        });
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
          subtitle: 'まずは今ある音源を1つ投稿すれば大丈夫です。高音質より参加しやすさを優先します。',
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
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.audio_file_outlined),
                label: Text(
                  _pickedFile == null ? '音声ファイルを選ぶ' : _pickedFile!.name,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _loading ? null : _useDemoAudio,
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('デモ音源を使う'),
              ),
              const SizedBox(height: 8),
              Text(
                'シミュレータで試すなら「デモ音源を使う」が最短です。実ファイルを使う場合は Files 経由で選んでください。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_pickedFile != null) ...[
                const SizedBox(height: 8),
                Text(
                  '選択中: ${_pickedFile!.name} (${(_pickedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_demoSource != null) ...[
                const SizedBox(height: 8),
                Text(
                  '選択中: ${_demoSource!.label}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: Text(_loading ? '投稿中...' : '曲を投稿する'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
