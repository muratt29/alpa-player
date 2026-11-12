import 'package:flutter/material.dart';

import '../ad_service.dart';
import '../models.dart';
import '../xtream_api.dart';
import 'home_screen.dart' show ErrorRetry;
import 'stream_list_screen.dart' show openPlayer;

class SeriesScreen extends StatefulWidget {
  final XtreamApi api;
  final StreamItem series;
  const SeriesScreen({super.key, required this.api, required this.series});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  late Future<List<Episode>> _future = widget.api.episodes(widget.series.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.series.name)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Episode>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return ErrorRetry(
                    message: '${snap.error}',
                    onRetry: () => setState(() =>
                        _future = widget.api.episodes(widget.series.id)),
                  );
                }
                final eps = snap.data!;
                if (eps.isEmpty) {
                  return const Center(child: Text('Bölüm bulunamadı.'));
                }
                final seasons = <String, List<Episode>>{};
                for (final e in eps) {
                  seasons.putIfAbsent(e.season, () => []).add(e);
                }
                final keys = seasons.keys.toList()
                  ..sort((a, b) => (int.tryParse(a) ?? 0)
                      .compareTo(int.tryParse(b) ?? 0));
                return ListView(
                  children: [
                    for (final k in keys)
                      ExpansionTile(
                        title: Text('Sezon $k'),
                        initiallyExpanded: k == keys.first,
                        children: [
                          for (final e in seasons[k]!)
                            ListTile(
                              leading: const Icon(Icons.play_circle_outline),
                              title: Text(e.title),
                              onTap: () => openPlayer(
                                context,
                                '${widget.series.name} - ${e.title}',
                                widget.api.episodeUrl(e),
                              ),
                            ),
                        ],
                      ),
                  ],
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
