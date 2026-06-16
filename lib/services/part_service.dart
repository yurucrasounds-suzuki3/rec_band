import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/part.dart';
import 'storage_service.dart';

class PartService {
  PartService(
    this._storageService, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  Stream<List<Part>> watchParts(String songId) {
    return _firestore
        .collection('parts')
        .where('songId', isEqualTo: songId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Part.fromDoc).toList());
  }

  Future<void> createPart({
    required String songId,
    required String partName,
    required String uploaderUid,
    required String uploaderName,
    required String filename,
    File? file,
    Uint8List? bytes,
  }) async {
    final doc = _firestore.collection('parts').doc();
    final upload = await _storageService.uploadPartFile(
      uid: uploaderUid,
      songId: songId,
      partId: doc.id,
      filename: filename,
      file: file,
      bytes: bytes,
    );

    final part = Part(
      id: doc.id,
      songId: songId,
      partName: partName,
      uploaderUid: uploaderUid,
      uploaderName: uploaderName,
      audioUrl: upload.downloadUrl,
      audioPath: upload.storagePath,
      createdAt: null,
    );

    await doc.set(part.toMap());
  }
}
