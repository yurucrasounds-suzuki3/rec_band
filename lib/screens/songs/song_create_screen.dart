import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
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
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_pickedFile?.path == null) {
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
            file: File(_pickedFile!.path!),
            filename: _pickedFile!.name,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('曲を投稿しました')),
        );
        _formKey.currentState!.reset();
        _titleController.clear();
        _commentController.clear();
        setState(() => _pickedFile = null);
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
