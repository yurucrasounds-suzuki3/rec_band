import 'package:flutter/services.dart';

import '../models/upload_source.dart';

class DemoAudioService {
  const DemoAudioService();

  Future<UploadSource> loadSongDemo() async {
    return _load(
      assetPath: 'assets/audio/demo_song.wav',
      filename: 'demo_song.wav',
      label: 'アプリ内デモ音源',
    );
  }

  Future<UploadSource> loadPartDemo() async {
    return _load(
      assetPath: 'assets/audio/demo_part.wav',
      filename: 'demo_part.wav',
      label: 'アプリ内デモ参加音源',
    );
  }

  Future<UploadSource> _load({
    required String assetPath,
    required String filename,
    required String label,
  }) async {
    final data = await rootBundle.load(assetPath);
    return UploadSource(
      filename: filename,
      bytes: data.buffer.asUint8List(),
      label: label,
    );
  }
}
