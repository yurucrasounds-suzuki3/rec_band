import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/song.dart';
import 'storage_service.dart';

class SongService {
  SongService(
    this._storageService, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  Stream<List<Song>> watchSongs() {
    return _firestore
        .collection('songs')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Song.fromDoc)
              .where((song) => song.isPublic)
              .toList()
            ..sort((a, b) {
              final left = a.publishedAt ?? a.createdAt ?? DateTime(1970);
              final right = b.publishedAt ?? b.createdAt ?? DateTime(1970);
              return right.compareTo(left);
            }),
        );
  }

  Stream<List<Song>> watchDraftSongs(String ownerUid) {
    return _firestore
        .collection('songs')
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Song.fromDoc)
              .where((song) => !song.isPublic)
              .toList()
            ..sort((a, b) {
              final left = a.createdAt ?? DateTime(1970);
              final right = b.createdAt ?? DateTime(1970);
              return right.compareTo(left);
            }),
        );
  }

  Stream<List<Song>> watchPublicSongs(String ownerUid) {
    return _firestore
        .collection('songs')
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Song.fromDoc)
              .where((song) => song.isPublic)
              .toList()
            ..sort((a, b) {
              final left = a.publishedAt ?? a.createdAt ?? DateTime(1970);
              final right = b.publishedAt ?? b.createdAt ?? DateTime(1970);
              return right.compareTo(left);
            }),
        );
  }

  Future<void> createSong({
    required String title,
    required String comment,
    required String ownerUid,
    required String ownerName,
    required String filename,
    bool isPublic = true,
    int? bpm,
    bool clickEnabled = false,
    File? file,
    Uint8List? bytes,
  }) async {
    final doc = _firestore.collection('songs').doc();
    final upload = await _storageService.uploadSongFile(
      uid: ownerUid,
      songId: doc.id,
      filename: filename,
      file: file,
      bytes: bytes,
    );

    final song = Song(
      id: doc.id,
      title: title,
      comment: comment,
      ownerUid: ownerUid,
      ownerName: ownerName,
      audioUrl: upload.downloadUrl,
      audioPath: upload.storagePath,
      isPublic: isPublic,
      bpm: bpm,
      clickEnabled: clickEnabled,
      createdAt: null,
      publishedAt: null,
    );

    await doc.set(song.toMap());
  }

  Future<void> publishSong(String songId) {
    return _firestore.collection('songs').doc(songId).update({
      'isPublic': true,
      'publishedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSong(Song song) async {
    await _storageService.deleteFile(song.audioPath);
    await _firestore.collection('songs').doc(song.id).delete();
  }
}
