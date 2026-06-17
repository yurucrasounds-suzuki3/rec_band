import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class LayeredAudioPlayerTile extends StatefulWidget {
  const LayeredAudioPlayerTile({
    super.key,
    required this.title,
    required this.baseUrl,
    required this.overlayUrl,
    this.subtitle,
  });

  final String title;
  final String baseUrl;
  final String overlayUrl;
  final String? subtitle;

  @override
  State<LayeredAudioPlayerTile> createState() => _LayeredAudioPlayerTileState();
}

class _LayeredAudioPlayerTileState extends State<LayeredAudioPlayerTile> {
  final AudioPlayer _basePlayer = AudioPlayer();
  final AudioPlayer _overlayPlayer = AudioPlayer();
  bool _loading = false;
  bool _ready = false;
  String? _errorText;

  Future<void> _ensureReady() async {
    if (_ready) {
      return;
    }

    await Future.wait([
      _basePlayer.setUrl(widget.baseUrl),
      _overlayPlayer.setUrl(widget.overlayUrl),
    ]);
    await _basePlayer.setVolume(0.9);
    await _overlayPlayer.setVolume(1.0);
    _ready = true;
  }

  Future<void> _toggle() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      if (_basePlayer.playing || _overlayPlayer.playing) {
        await Future.wait([
          _basePlayer.pause(),
          _overlayPlayer.pause(),
        ]);
      } else {
        await _ensureReady();
        await Future.wait([
          _basePlayer.seek(Duration.zero),
          _overlayPlayer.seek(Duration.zero),
        ]);
        await Future.wait([
          _basePlayer.play(),
          _overlayPlayer.play(),
        ]);
      }
    } catch (_) {
      _errorText = '重ねて再生できませんでした';
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
    _basePlayer.dispose();
    _overlayPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _basePlayer.playingStream,
      initialData: _basePlayer.playing,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Card(
          color: const Color(0xFFECFDF5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: _loading ? null : _toggle,
                      icon: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.graphic_eq_rounded,
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
                const SizedBox(height: 10),
                Text(
                  '元曲と参加音源を同時に再生します。完全同期ではありませんが、重なりは確認できます。',
                  style: Theme.of(context).textTheme.bodySmall,
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
