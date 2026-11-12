import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Tam ekran video oynatici. Oynatma sirasinda reklam gosterilmez.
class PlayerScreen extends StatefulWidget {
  final String title;
  final String url;
  const PlayerScreen({super.key, required this.title, required this.url});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);
  StreamSubscription<String>? _errorSub;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _errorSub = _player.stream.error.listen((e) {
      if (mounted) setState(() => _error = e);
    });
    _open();
  }

  void _open() {
    setState(() => _error = null);
    _player.open(Media(widget.url));
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    _player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topBar = <Widget>[
      const BackButton(color: Colors.white),
      Expanded(
        child: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    ];
    final controls = MaterialVideoControlsThemeData(topButtonBar: topBar);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: MaterialVideoControlsTheme(
                normal: controls,
                fullscreen: controls,
                child: Video(
                  controller: _controller,
                  controls: MaterialVideoControls,
                ),
              ),
            ),
            if (_error != null)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        const Text('Yayın oynatılamadı.',
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Geri'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _open,
                              child: const Text('Tekrar dene'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
