import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingService {
  RecordingService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;

  Future<String> startRecording({String prefix = 'part'}) async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw StateError('microphone_permission_denied');
    }

    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    return path;
  }

  Future<String?> stopRecording() {
    return _recorder.stop();
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null) {
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> dispose() {
    return _recorder.dispose();
  }
}
