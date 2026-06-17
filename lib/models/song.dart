import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  const Song({
    required this.id,
    required this.title,
    required this.comment,
    required this.ownerUid,
    required this.ownerName,
    required this.audioUrl,
    required this.audioPath,
    required this.isPublic,
    required this.bpm,
    required this.clickEnabled,
    required this.createdAt,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String comment;
  final String ownerUid;
  final String ownerName;
  final String audioUrl;
  final String audioPath;
  final bool isPublic;
  final int? bpm;
  final bool clickEnabled;
  final DateTime? createdAt;
  final DateTime? publishedAt;

  factory Song.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Song(
      id: doc.id,
      title: data['title'] as String? ?? '',
      comment: data['comment'] as String? ?? '',
      ownerUid: data['ownerUid'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      audioUrl: data['audioUrl'] as String? ?? '',
      audioPath: data['audioPath'] as String? ?? '',
      isPublic: data['isPublic'] as bool? ?? true,
      bpm: data['bpm'] as int?,
      clickEnabled: data['clickEnabled'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'songId': id,
      'title': title,
      'comment': comment,
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'audioUrl': audioUrl,
      'audioPath': audioPath,
      'isPublic': isPublic,
      'bpm': bpm,
      'clickEnabled': clickEnabled,
      'createdAt': FieldValue.serverTimestamp(),
      'publishedAt': isPublic ? FieldValue.serverTimestamp() : null,
    };
  }
}
