import 'package:flutter/material.dart';

import '../models/part.dart';
import '../utils/formatters.dart';
import 'audio_player_tile.dart';

class PartCard extends StatelessWidget {
  const PartCard({super.key, required this.part});

  final Part part;

  @override
  Widget build(BuildContext context) {
    return AudioPlayerTile(
      title: part.partName,
      subtitle: '${part.uploaderName} • ${formatDateTime(part.createdAt)}',
      url: part.audioUrl,
    );
  }
}
