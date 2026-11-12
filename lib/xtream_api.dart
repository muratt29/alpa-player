import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'demo_content.dart';
import 'models.dart';

class XtreamException implements Exception {
  final String message;
  XtreamException(this.message);
  @override
  String toString() => message;
}

/// Xtream Codes "player_api.php" istemcisi.
class XtreamApi {
  final Account account;
  XtreamApi(this.account);

  Future<dynamic> _get([Map<String, String> params = const {}]) async {
    final uri = Uri.parse('${account.server}/player_api.php').replace(
      queryParameters: {
        'username': account.username,
        'password': account.password,
        ...params,
      },
    );
    http.Response res;
    try {
      res = await http.get(uri).timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw XtreamException('Sunucu yanıt vermedi (zaman aşımı).');
    } catch (_) {
      throw XtreamException(
          'Sunucuya bağlanılamadı. Adresi ve internet bağlantınızı kontrol edin.');
    }
    if (res.statusCode != 200) {
      throw XtreamException('Sunucu hatası (${res.statusCode}).');
    }
    try {
      return jsonDecode(utf8.decode(res.bodyBytes, allowMalformed: true));
    } catch (_) {
      throw XtreamException(
          'Sunucudan geçersiz yanıt geldi. Adres Xtream Codes uyumlu olmayabilir.');
    }
  }

  /// Giris bilgilerini dogrular; hata varsa XtreamException firlatir.
  Future<void> login() async {
    if (account.isDemo) return;
    final data = await _get();
    final info = data is Map ? data['user_info'] : null;
    if (info is! Map || '${info['auth']}' != '1') {
      throw XtreamException('Kullanıcı adı veya şifre hatalı.');
    }
    final status = '${info['status'] ?? 'Active'}';
    if (status.toLowerCase() != 'active') {
      throw XtreamException('Hesap aktif değil (durum: $status).');
    }
  }

  Future<List<Category>> categories(ContentKind kind) async {
    if (account.isDemo) return DemoContent.categories(kind);
    final action = switch (kind) {
      ContentKind.live => 'get_live_categories',
      ContentKind.vod => 'get_vod_categories',
      ContentKind.series => 'get_series_categories',
    };
    final data = await _get({'action': action});
    final list = data is List ? data : const [];
    return [
      const Category(null, 'Tümü'),
      for (final c in list)
        if (c is Map)
          Category('${c['category_id']}', '${c['category_name'] ?? ''}'),
    ];
  }

  Future<List<StreamItem>> streams(ContentKind kind, String? categoryId) async {
    if (account.isDemo) return DemoContent.streams(kind);
    final action = switch (kind) {
      ContentKind.live => 'get_live_streams',
      ContentKind.vod => 'get_vod_streams',
      ContentKind.series => 'get_series',
    };
    final data = await _get({
      'action': action,
      if (categoryId != null) 'category_id': categoryId,
    });
    final list = data is List ? data : const [];
    final idKey = kind == ContentKind.series ? 'series_id' : 'stream_id';
    final iconKey = kind == ContentKind.series ? 'cover' : 'stream_icon';
    return [
      for (final s in list)
        if (s is Map && s[idKey] != null)
          StreamItem(
            id: '${s[idKey]}',
            name: '${s['name'] ?? ''}',
            icon: _nonEmpty(s[iconKey]),
            extension: _nonEmpty(s['container_extension']),
            kind: kind,
          ),
    ];
  }

  Future<List<Episode>> episodes(String seriesId) async {
    if (account.isDemo) return DemoContent.episodes;
    final data =
        await _get({'action': 'get_series_info', 'series_id': seriesId});
    final raw = data is Map ? data['episodes'] : null;
    final result = <Episode>[];

    void addSeason(String season, dynamic eps) {
      if (eps is! List) return;
      for (final e in eps) {
        if (e is! Map || e['id'] == null) continue;
        result.add(Episode(
          id: '${e['id']}',
          title: '${e['title'] ?? 'Bölüm ${e['episode_num'] ?? ''}'}',
          season: '${e['season'] ?? season}',
          extension: _nonEmpty(e['container_extension']) ?? 'mp4',
        ));
      }
    }

    if (raw is Map) {
      raw.forEach((k, v) => addSeason('$k', v));
    } else if (raw is List) {
      for (var i = 0; i < raw.length; i++) {
        addSeason('${i + 1}', raw[i]);
      }
    }
    return result;
  }

  String get _cred =>
      '${Uri.encodeComponent(account.username)}/${Uri.encodeComponent(account.password)}';

  String liveUrl(String id) => account.isDemo
      ? DemoContent.urls[id]!
      : '${account.server}/live/$_cred/$id.ts';
  String vodUrl(String id, String? ext) => account.isDemo
      ? DemoContent.urls[id]!
      : '${account.server}/movie/$_cred/$id.${ext ?? 'mp4'}';
  String episodeUrl(Episode e) => account.isDemo
      ? DemoContent.urls[e.id]!
      : '${account.server}/series/$_cred/${e.id}.${e.extension}';

  static String? _nonEmpty(dynamic v) {
    if (v == null) return null;
    final s = '$v'.trim();
    return s.isEmpty ? null : s;
  }
}
