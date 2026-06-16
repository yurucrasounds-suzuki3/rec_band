import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/song_service.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/song_card.dart';
import 'song_detail_screen.dart';

class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const BrandHeader(
          title: 'みんなの曲',
          subtitle: '気になる曲を見つけたら、あなたの音で参加できます。',
        ),
        const SizedBox(height: 20),
        Text(
          '投稿された曲',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        StreamBuilder(
          stream: context.read<SongService>().watchSongs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('曲を読み込めませんでした。Firebase 設定を確認してください。'),
              );
            }

            final songs = snapshot.data ?? [];
            if (songs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Text('まだ曲がありません。最初の1曲を投稿してみましょう。'),
              );
            }

            return Column(
              children: songs
                  .map(
                    (song) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SongCard(
                        song: song,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SongDetailScreen(song: song),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
