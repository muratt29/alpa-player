enum ContentKind { live, vod, series }

/// Kullanicinin IPTV saglayicisindan aldigi hesap bilgileri.
class Account {
  final String server; // ornek: http://ornek.com:8080
  final String username;
  final String password;

  const Account({
    required this.server,
    required this.username,
    required this.password,
  });

  /// Kullanici girdisini temizler. Sunucu alanina tam bir M3U linki
  /// (get.php?username=..&password=..) yapistirilirsa kullanici adi ve
  /// sifreyi linkten okur.
  factory Account.fromInput(String server, String username, String password) {
    var s = server.trim();
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = 'http://$s';
    }
    final uri = Uri.tryParse(s);
    if (uri != null) {
      final u = uri.queryParameters['username'];
      final p = uri.queryParameters['password'];
      if (username.trim().isEmpty && u != null) username = u;
      if (password.trim().isEmpty && p != null) password = p;
      if (uri.host.isNotEmpty) {
        s = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      }
    }
    return Account(
      server: s,
      username: username.trim(),
      password: password.trim(),
    );
  }

  /// Sunucu adresi "demo" ise yerlesik demo icerigi kullanilir.
  bool get isDemo => Uri.tryParse(server)?.host.toLowerCase() == 'demo';

  static const demo =
      Account(server: 'http://demo', username: 'demo', password: 'demo');

  Map<String, dynamic> toJson() =>
      {'server': server, 'username': username, 'password': password};

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        server: j['server'] as String,
        username: j['username'] as String,
        password: j['password'] as String,
      );
}

class Category {
  final String? id; // null = tumu
  final String name;
  const Category(this.id, this.name);
}

class StreamItem {
  final String id;
  final String name;
  final String? icon;
  final String? extension; // film icin mp4/mkv vb.
  final ContentKind kind;

  const StreamItem({
    required this.id,
    required this.name,
    required this.kind,
    this.icon,
    this.extension,
  });
}

class Episode {
  final String id;
  final String title;
  final String season;
  final String extension;

  const Episode({
    required this.id,
    required this.title,
    required this.season,
    required this.extension,
  });
}
