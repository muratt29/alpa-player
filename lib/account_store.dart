import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models.dart';

/// Hesap bilgilerini cihazin guvenli deposunda (Keychain / Keystore) saklar.
class AccountStore {
  static const _storage = FlutterSecureStorage();
  static const _key = 'account';

  static Future<Account?> load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      return Account.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Account a) =>
      _storage.write(key: _key, value: jsonEncode(a.toJson()));

  static Future<void> clear() => _storage.delete(key: _key);
}
