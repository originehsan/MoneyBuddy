// MoneyBuddy
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorage — single source of truth for all secure key-value storage.
/// Token storage removed — Firebase Auth handles tokens automatically.
class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage();

  // ── Keys ──────────────────────────────────────────────────────
  static const _keyUserEmail = 'userEmail';
  static const _keyUserName  = 'userName';
  static const _keyGroupIds  = 'groupIds';

  // ── User info ─────────────────────────────────────────────────
  static Future<void> saveUserEmail(String email) async =>
      _storage.write(key: _keyUserEmail, value: email);

  static Future<String?> getUserEmail() async =>
      _storage.read(key: _keyUserEmail);

  static Future<void> saveUserName(String name) async =>
      _storage.write(key: _keyUserName, value: name);

  static Future<String?> getUserName() async =>
      _storage.read(key: _keyUserName);

  // ── Group IDs ─────────────────────────────────────────────────
  static Future<void> saveGroupIds(List<String> ids) async =>
      _storage.write(key: _keyGroupIds, value: ids.join(','));

  static Future<List<String>> getGroupIds() async {
    final raw = await _storage.read(key: _keyGroupIds);
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',').where((id) => id.isNotEmpty).toList();
  }

  // ── Clear user data — on logout ───────────────────────────────
  static Future<void> clearUserData() async {
    await Future.wait([
      _storage.delete(key: _keyUserEmail),
      _storage.delete(key: _keyUserName),
      _storage.delete(key: _keyGroupIds),
    ]);
  }
}