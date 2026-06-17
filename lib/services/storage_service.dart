import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageUploadResult {
  const StorageUploadResult({
    required this.downloadUrl,
    required this.storagePath,
  });

  final String downloadUrl;
  final String storagePath;
}

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<StorageUploadResult> uploadSongFile({
    required String uid,
    required String songId,
    required String filename,
    File? file,
    Uint8List? bytes,
  }) {
    return _uploadFile(
      path: 'songs/$uid/$songId/$filename',
      file: file,
      bytes: bytes,
    );
  }

  Future<StorageUploadResult> uploadPartFile({
    required String uid,
    required String songId,
    required String partId,
    required String filename,
    File? file,
    Uint8List? bytes,
  }) {
    return _uploadFile(
      path: 'parts/$songId/$uid/$partId/$filename',
      file: file,
      bytes: bytes,
    );
  }

  Future<StorageUploadResult> _uploadFile({
    required String path,
    File? file,
    Uint8List? bytes,
  }) async {
    final ref = _storage.ref(path);
    if (file != null) {
      await ref.putFile(file);
    } else if (bytes != null) {
      await ref.putData(bytes);
    } else {
      throw ArgumentError('Either file or bytes must be provided.');
    }
    final downloadUrl = await ref.getDownloadURL();
    return StorageUploadResult(downloadUrl: downloadUrl, storagePath: path);
  }

  Future<void> deleteFile(String path) async {
    await _storage.ref(path).delete();
  }
}
