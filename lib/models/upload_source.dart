import 'dart:typed_data';

class UploadSource {
  const UploadSource({
    required this.filename,
    required this.bytes,
    required this.label,
  });

  final String filename;
  final Uint8List bytes;
  final String label;
}
