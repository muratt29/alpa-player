import 'package:flutter/material.dart';

import '../ad_service.dart';
import '../models.dart';
import '../xtream_api.dart';
import 'home_screen.dart' show ErrorRetry;
import 'player_screen.dart';
import 'series_screen.dart';

/// Reklam (uygunsa) gosterip ardindan oynaticiyi acar.
Future<void> openPlayer(BuildContext context, String title, String url) async {
  await AdService.instance.maybeShowInterstitial();
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PlayerScreen(title: title, url: url)),
  );
}

class StreamListScreen extends StatefulWidget {
  final XtreamApi api;
  final ContentKind kind;
  final Category category;

  const StreamListScreen({
    super.key,
    required this.api,
    required this.kind,
    required this.category,
  });

  @override
  State<StreamListScreen> createState() => _StreamListScreenState();
}

class _StreamListScreenState extends State<StreamListScreen> {
  late Future<List<StreamItem>> _future = _fetch();
  String _query = '';

  Future<List<StreamItem>> _fetch() =>
      widget.api.streams(widget.kind, widget.category.id);

  void _open(StreamItem s) {
    switch (s.kind) {
      case ContentKind.live:
        openPlayer(context, s.name, widget.api.liveUrl(s.id));
      case ContentKind.vod:
        openPlayer(context, s.name, widget.api.vodUrl(s.id, s.extension));
      case ContentKind.series:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SeriesScreen(api: widget.api, series: s),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StreamItem>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return ErrorRetry(
                    message: '${snap.error}',
                    onRetry: () => setState(() => _future = _fetch()),
                  );
                }
                final all = snap.data!;
                final items = _query.isEmpty
                    ? all
                    : all
                        .where((s) => s.name.toLowerCase().contains(_query))
                        .toList();
                if (items.isEmpty) {
                  return const Center(child: Text('İçerik bulunamadı.'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final s = items[i];
                    return ListTile(
                      leading: _Logo(url: s.icon, kind: s.kind),
                      title: Text(s.name,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => _open(s),
                    );
                  },
                );
              },
            ),
          ),
          const BannerAdBar(),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String? url;
  final ContentKind kind;
  const _Logo({required this.url, required this.kind});

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(switch (kind) {
      ContentKind.live => Icons.tv,
      ContentKind.vod => Icons.movie_outlined,
      ContentKind.series => Icons.video_library_outlined,
    });
    return SizedBox(
      width: 48,
      height: 48,
      child: url == null
          ? fallback
          : Image.network(
              url!,
              fit: BoxFit.contain,
              cacheWidth: 144,
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}
