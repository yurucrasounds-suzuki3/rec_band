import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/song.dart';
import '../../services/part_service.dart';
import '../../widgets/audio_player_tile.dart';
import '../../widgets/layered_audio_player_tile.dart';
import '../../widgets/part_card.dart';
import '../parts/part_create_screen.dart';

class SongDetailScreen extends StatelessWidget {
  const SongDetailScreen({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('曲の詳細')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PartCreateScreen(song: song),
            ),
          );
        },
        icon: const Icon(Icons.music_note_outlined),
        label: const Text('この曲に参加する'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            song.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text('投稿した人: ${song.ownerName}'),
          const SizedBox(height: 8),
          Text('募集メッセージ\n${song.comment}'),
          const SizedBox(height: 20),
          AudioPlayerTile(
            title: '元の曲を聴く',
            subtitle: '投稿された音源',
            url: song.audioUrl,
          ),
          const SizedBox(height: 20),
          Text(
            '参加した音源',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          StreamBuilder(
            stream: context.read<PartService>().watchParts(song.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const Text('参加音源を読み込めませんでした。');
              }

              final parts = snapshot.data ?? [];
              if (parts.isEmpty) {
                return const Text('まだ参加音源はありません。最初の参加者になってみましょう。');
              }

              return Column(
                children: parts
                    .map(
                      (part) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StreamBuilder<bool>(
                          stream: context.read<PartService>().watchLiked(part.id),
                          initialData: false,
                          builder: (context, likedSnapshot) {
                            final isLiked = likedSnapshot.data ?? false;
                            return Column(
                              children: [
                                PartCard(
                                  part: part,
                                  isLiked: isLiked,
                                  onLikeToggle: () async {
                                    await context.read<PartService>().toggleLike(
                                          partId: part.id,
                                          isLiked: isLiked,
                                        );
                                  },
                                ),
                                const SizedBox(height: 8),
                                LayeredAudioPlayerTile(
                                  title: 'この参加音源を重ねて聴く',
                                  subtitle: part.partName,
                                  baseUrl: song.audioUrl,
                                  overlayUrl: part.audioUrl,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 88),
        ],
      ),
    );
  }
}
