import 'package:flutter/material.dart';

import '../models/song.dart';
import '../utils/formatters.dart';

class SongCard extends StatelessWidget {
  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
  });

  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text('投稿した人: ${song.ownerName}'),
              const SizedBox(height: 4),
              Text('募集メッセージ: ${song.comment}'),
              const SizedBox(height: 8),
              Text(
                formatDateTime(song.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
