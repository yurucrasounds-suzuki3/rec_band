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
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Song.fromDoc).toList());
  }

  Future<void> createSong({
    required String title,
    required String comment,
    required String ownerUid,
    required String ownerName,
    required String filename,
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
      createdAt: null,
    );

    await doc.set(song.toMap());
  }
}
