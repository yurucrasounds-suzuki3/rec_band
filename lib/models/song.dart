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
    required this.createdAt,
  });

  final String id;
  final String title;
  final String comment;
  final String ownerUid;
  final String ownerName;
  final String audioUrl;
  final String audioPath;
  final DateTime? createdAt;

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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
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
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
