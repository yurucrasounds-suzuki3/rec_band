import 'dart:io';

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
    required File file,
    required String filename,
  }) {
    return _uploadFile(
      path: 'songs/$uid/$songId/$filename',
      file: file,
    );
  }

  Future<StorageUploadResult> uploadPartFile({
    required String uid,
    required String songId,
    required String partId,
    required File file,
    required String filename,
  }) {
    return _uploadFile(
      path: 'parts/$songId/$uid/$partId/$filename',
      file: file,
    );
  }

  Future<StorageUploadResult> _uploadFile({
    required String path,
    required File file,
  }) async {
    final ref = _storage.ref(path);
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();
    return StorageUploadResult(downloadUrl: downloadUrl, storagePath: path);
  }
}
