import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/song.dart';
import '../../services/auth_service.dart';
import '../../services/part_service.dart';

class PartCreateScreen extends StatefulWidget {
  const PartCreateScreen({super.key, required this.song});

  final Song song;

  @override
  State<PartCreateScreen> createState() => _PartCreateScreenState();
}

class _PartCreateScreenState extends State<PartCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partNameController = TextEditingController();
  PlatformFile? _pickedFile;
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _partNameController.dispose();
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
          _errorText = null;
        });
      }
    } catch (_) {
      setState(() {
        _errorText = 'ファイルを開けませんでした。iPhone シミュレータなら Files に入れた音源を選んでください。';
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
      await context.read<PartService>().createPart(
            songId: widget.song.id,
            partName: _partNameController.text.trim(),
            uploaderUid: user.uid,
            uploaderName: user.displayName ?? '名無し',
            filename: _pickedFile!.name,
            file: _pickedFile!.path == null ? null : File(_pickedFile!.path!),
            bytes: _pickedFile!.bytes,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('参加音源を投稿しました')),
        );
        Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(title: const Text('参加音源を投稿')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '「${widget.song.title}」に参加する',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('例: ギターソロ、ドラム、ベース、コーラス'),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _partNameController,
                  decoration: const InputDecoration(labelText: 'あなたのパート名'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'パート名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.library_music_outlined),
                  label: Text(
                    _pickedFile == null ? '音声ファイルを選ぶ' : _pickedFile!.name,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mac で試すときは、Finder の音源を iPhone シミュレータの Files に入れてから選ぶと通りやすいです。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_pickedFile != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '選択中: ${_pickedFile!.name} (${(_pickedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB)',
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
                  child: Text(_loading ? '投稿中...' : '参加音源を投稿する'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
