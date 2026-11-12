import 'package:flutter/material.dart';

import '../account_store.dart';
import '../ad_service.dart';
import '../models.dart';
import '../xtream_api.dart';
import 'login_screen.dart';
import 'stream_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final Account account;
  const HomeScreen({super.key, required this.account});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final XtreamApi _api = XtreamApi(widget.account);
  int _tab = 0;

  static const _titles = ['Canlı TV', 'Filmler', 'Diziler'];

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Çıkış yap'),
        content: const Text('Kayıtlı hesap bilgileri silinecek.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Vazgeç')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Çıkış yap')),
        ],
      ),
    );
    if (ok != true) return;
    await AccountStore.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 30),
            const SizedBox(width: 10),
            Text(_titles[_tab]),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Çıkış yap',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                _CategoryTab(api: _api, kind: ContentKind.live),
                _CategoryTab(api: _api, kind: ContentKind.vod),
                _CategoryTab(api: _api, kind: ContentKind.series),
              ],
            ),
          ),
          const BannerAdBar(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.live_tv), label: 'Canlı TV'),
          NavigationDestination(icon: Icon(Icons.movie), label: 'Filmler'),
          NavigationDestination(
              icon: Icon(Icons.video_library), label: 'Diziler'),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatefulWidget {
  final XtreamApi api;
  final ContentKind kind;
  const _CategoryTab({required this.api, required this.kind});

  @override
  State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab> {
  late Future<List<Category>> _future = widget.api.categories(widget.kind);

  void _reload() =>
      setState(() => _future = widget.api.categories(widget.kind));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return ErrorRetry(message: '${snap.error}', onRetry: _reload);
        }
        final cats = snap.data!;
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.separated(
            itemCount: cats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = cats[i];
              return ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(c.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StreamListScreen(
                      api: widget.api,
                      kind: widget.kind,
                      category: c,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorRetry({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: onRetry, child: const Text('Tekrar dene')),
          ],
        ),
      ),
    );
  }
}
