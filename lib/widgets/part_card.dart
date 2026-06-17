import 'package:flutter/material.dart';

import '../models/part.dart';
import '../utils/formatters.dart';
import 'audio_player_tile.dart';

class PartCard extends StatelessWidget {
  const PartCard({
    super.key,
    required this.part,
    this.isLiked = false,
    this.onLikeToggle,
  });

  final Part part;
  final bool isLiked;
  final VoidCallback? onLikeToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AudioPlayerTile(
          title: part.partName,
          subtitle:
              '${part.uploaderName} • ${formatDateTime(part.publishedAt ?? part.createdAt)}',
          url: part.audioUrl,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('いいね ${part.likeCount}'),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onLikeToggle,
              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
              label: Text(isLiked ? 'いいね済み' : 'いいね'),
            ),
          ],
        ),
      ],
    );
  }
}
