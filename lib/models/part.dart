import 'package:cloud_firestore/cloud_firestore.dart';

class Part {
  const Part({
    required this.id,
    required this.songId,
    required this.partName,
    required this.uploaderUid,
    required this.uploaderName,
    required this.audioUrl,
    required this.audioPath,
    required this.parentPartId,
    required this.offsetMs,
    required this.isPublic,
    required this.likeCount,
    required this.createdAt,
    required this.publishedAt,
  });

  final String id;
  final String songId;
  final String partName;
  final String uploaderUid;
  final String uploaderName;
  final String audioUrl;
  final String audioPath;
  final String? parentPartId;
  final int offsetMs;
  final bool isPublic;
  final int likeCount;
  final DateTime? createdAt;
  final DateTime? publishedAt;

  factory Part.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Part(
      id: doc.id,
      songId: data['songId'] as String? ?? '',
      partName: data['partName'] as String? ?? '',
      uploaderUid: data['uploaderUid'] as String? ?? '',
      uploaderName: data['uploaderName'] as String? ?? '',
      audioUrl: data['audioUrl'] as String? ?? '',
      audioPath: data['audioPath'] as String? ?? '',
      parentPartId: data['parentPartId'] as String?,
      offsetMs: data['offsetMs'] as int? ?? 0,
      isPublic: data['isPublic'] as bool? ?? true,
      likeCount: data['likeCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partId': id,
      'songId': songId,
      'partName': partName,
      'uploaderUid': uploaderUid,
      'uploaderName': uploaderName,
      'audioUrl': audioUrl,
      'audioPath': audioPath,
      'parentPartId': parentPartId,
      'offsetMs': offsetMs,
      'isPublic': isPublic,
      'likeCount': likeCount,
      'createdAt': FieldValue.serverTimestamp(),
      'publishedAt': isPublic ? FieldValue.serverTimestamp() : null,
    };
  }
}
