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
    required this.createdAt,
  });

  final String id;
  final String songId;
  final String partName;
  final String uploaderUid;
  final String uploaderName;
  final String audioUrl;
  final String audioPath;
  final DateTime? createdAt;

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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
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
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
