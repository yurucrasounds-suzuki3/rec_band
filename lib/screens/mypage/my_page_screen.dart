import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/part_service.dart';
import '../../services/auth_service.dart';
import '../../services/song_service.dart';
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
                              child: ElevatedButton(
                                onPressed: () async {
                                  await context.read<SongService>().publishSong(song.id);
                                },
                                child: const Text('公開する'),
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
                                ElevatedButton(
                                  onPressed: () async {
                                    await context.read<PartService>().publishPart(part.id);
                                  },
                                  child: const Text('公開する'),
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
