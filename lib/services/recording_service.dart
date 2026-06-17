import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingService {
  RecordingService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;

  Future<String> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw StateError('microphone_permission_denied');
    }

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/part_${DateTime.now().millisecondsSinceEpoch}.m4a';

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

  Future<void> dispose() {
    return _recorder.dispose();
  }
}
