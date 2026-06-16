import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerTile extends StatefulWidget {
  const AudioPlayerTile({
    super.key,
    required this.title,
    required this.url,
    this.subtitle,
  });

  final String title;
  final String url;
  final String? subtitle;

  @override
  State<AudioPlayerTile> createState() => _AudioPlayerTileState();
}

class _AudioPlayerTileState extends State<AudioPlayerTile> {
  final AudioPlayer _player = AudioPlayer();
  bool _loading = false;
  String? _errorText;

  Future<void> _toggle() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (_player.audioSource == null) {
          await _player.setUrl(widget.url);
        }
        await _player.play();
      }
    } catch (_) {
      _errorText = '再生できませんでした';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _player.playingStream,
      initialData: _player.playing,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton.filled(
                      onPressed: _loading ? null : _toggle,
                      icon: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
