import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Part.fromDoc)
              .where((part) => part.isPublic)
              .toList()
            ..sort((a, b) {
              final likeCompare = b.likeCount.compareTo(a.likeCount);
              if (likeCompare != 0) {
                return likeCompare;
              }
              final left = a.publishedAt ?? a.createdAt ?? DateTime(1970);
              final right = b.publishedAt ?? b.createdAt ?? DateTime(1970);
              return right.compareTo(left);
            }),
        );
  }

  Stream<List<Part>> watchDraftParts(String uploaderUid) {
    return _firestore
        .collection('parts')
        .where('uploaderUid', isEqualTo: uploaderUid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Part.fromDoc)
              .where((part) => !part.isPublic)
              .toList()
            ..sort((a, b) {
              final left = a.createdAt ?? DateTime(1970);
              final right = b.createdAt ?? DateTime(1970);
              return right.compareTo(left);
            }),
        );
  }

  Future<void> createPart({
    required String songId,
    required String partName,
    required String uploaderUid,
    required String uploaderName,
    required String filename,
    String? parentPartId,
    int offsetMs = 0,
    bool isPublic = true,
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
      parentPartId: parentPartId,
      offsetMs: offsetMs,
      isPublic: isPublic,
      likeCount: 0,
      createdAt: null,
      publishedAt: null,
    );

    await doc.set(part.toMap());
  }

  Future<void> publishPart(String partId) {
    return _firestore.collection('parts').doc(partId).update({
      'isPublic': true,
      'publishedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<bool> watchLiked(String partId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('part_likes')
        .doc('${partId}_${user.uid}')
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> toggleLike({
    required String partId,
    required bool isLiked,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('not_logged_in');
    }

    final likeDoc = _firestore.collection('part_likes').doc('${partId}_${user.uid}');
    final partDoc = _firestore.collection('parts').doc(partId);

    await _firestore.runTransaction((transaction) async {
      final partSnapshot = await transaction.get(partDoc);
      final current = (partSnapshot.data()?['likeCount'] as int?) ?? 0;

      if (isLiked) {
        transaction.delete(likeDoc);
        transaction.update(partDoc, {'likeCount': current > 0 ? current - 1 : 0});
      } else {
        transaction.set(likeDoc, {
          'partId': partId,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(partDoc, {'likeCount': current + 1});
      }
    });
  }
}
