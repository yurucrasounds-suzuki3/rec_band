import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/part_service.dart';
import '../../services/auth_service.dart';
import '../../services/song_service.dart';
import '../../widgets/audio_player_tile.dart';
import '../../widgets/song_card.dart';
import '../songs/song_detail_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({
    super.key,
    required this.displayName,
    required this.email,
  });

  final String displayName;
  final String email;

  Future<void> _confirmDeleteSong(BuildContext context, song) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('元音源を削除しますか？'),
        content: const Text('この操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      await context.read<SongService>().deleteSong(song);
    }
  }

  Future<void> _confirmDeletePart(BuildContext context, part) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('参加音源を削除しますか？'),
        content: const Text('この操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      await context.read<PartService>().deletePart(part);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'マイページ',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(email),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '公開中の元音源',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (user != null)
          StreamBuilder(
            stream: context.read<SongService>().watchPublicSongs(user.uid),
            builder: (context, snapshot) {
              final songs = snapshot.data ?? [];
              if (songs.isEmpty) {
                return const Text('公開中の元音源はありません。');
              }
              return Column(
                children: songs
                    .map(
                      (song) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            SongCard(
                              song: song,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SongDetailScreen(song: song),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: () => _confirmDeleteSong(context, song),
                                child: const Text('削除する'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        const SizedBox(height: 20),
        Text(
          '未公開保存',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (user != null)
          StreamBuilder(
            stream: context.read<SongService>().watchDraftSongs(user.uid),
            builder: (context, snapshot) {
              final songs = snapshot.data ?? [];
              if (songs.isEmpty) {
                return const Text('未公開の元音源はありません。');
              }
              return Column(
                children: songs
                    .map(
                      (song) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            SongCard(
                              song: song,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SongDetailScreen(song: song),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _confirmDeleteSong(context, song),
                                    child: const Text('削除する'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await context.read<SongService>().publishSong(song.id);
                                    },
                                    child: const Text('公開する'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        const SizedBox(height: 20),
        Text(
          '公開中の参加音源',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (user != null)
          StreamBuilder(
            stream: context.read<PartService>().watchPublicParts(user.uid),
            builder: (context, snapshot) {
              final parts = snapshot.data ?? [];
              if (parts.isEmpty) {
                return const Text('公開中の参加音源はありません。');
              }
              return Column(
                children: parts
                    .map(
                      (part) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            AudioPlayerTile(
                              title: part.partName,
                              subtitle: 'いいね ${part.likeCount}',
                              url: part.audioUrl,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: () => _confirmDeletePart(context, part),
                                child: const Text('削除する'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        const SizedBox(height: 20),
        if (user != null)
          StreamBuilder(
            stream: context.read<PartService>().watchDraftParts(user.uid),
            builder: (context, snapshot) {
              final parts = snapshot.data ?? [];
              if (parts.isEmpty) {
                return const Text('未公開の参加音源はありません。');
              }
              return Column(
                children: parts
                    .map(
                      (part) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(part.partName),
                                      const SizedBox(height: 4),
                                      Text('いいね ${part.likeCount}'),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _confirmDeletePart(context, part),
                                      child: const Text('削除する'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await context.read<PartService>().publishPart(part.id);
                                      },
                                      child: const Text('公開する'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await context.read<AuthService>().signOut();
          },
          child: const Text('ログアウト'),
        ),
      ],
    );
  }
}
