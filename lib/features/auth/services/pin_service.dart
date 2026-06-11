// MoneyBuddy
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles all PIN lock logic.
/// PIN stored in flutter_secure_storage (encrypted).
/// Lock enabled flag stored in SharedPreferences.
class PinService {
  static const _storage    = FlutterSecureStorage();
  static const _pinKey     = 'app_pin';
  static const _enabledKey = 'pin_lock_enabled';

  // ── Check if PIN lock is enabled ──────────────────────────────

  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  // ── Check if PIN exists in storage ───────────────────────────

  static Future<bool> hasPinSet() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  // ── Save PIN ──────────────────────────────────────────────────

  static Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
  }

  // ── Verify PIN ────────────────────────────────────────────────

  static Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored == pin;
  }

  // ── Change PIN (verify old first) ────────────────────────────

  static Future<bool> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) return false;
    await savePin(newPin);
    return true;
  }

  // ── Remove PIN (disable lock) ─────────────────────────────────

  static Future<bool> removePin(String pin) async {
    final isValid = await verifyPin(pin);
    if (!isValid) return false;
    await _storage.delete(key: _pinKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    return true;
  }

  // ── Clear all (on logout / account delete) ────────────────────

  static Future<void> clearAll() async {
    await _storage.delete(key: _pinKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
  }
}