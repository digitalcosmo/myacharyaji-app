import 'package:shared_preferences/shared_preferences.dart';

/// Local storage wrapper for user session data.
class UserData {
  static const _keyLoggedIn = 'isLoggedIn';
  static const _keyUserId = 'userId';
  static const _keyAppId = 'appId';
  static const _keyRId = 'rId';
  static const _keyUserName = 'userName';
  static const _keyDuration = 'duration';
  static const _keyStartMonth = 'startMonth';

  // --- Login state ---
  static Future<void> setLoggedIn(bool v) async {
    final p = await SharedPreferences.getInstance();
    p.setBool(_keyLoggedIn, v);
  }

  static Future<bool> getLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keyLoggedIn) ?? false;
  }

  // --- User ID ---
  static Future<void> setUserId(String v) async {
    final p = await SharedPreferences.getInstance();
    p.setString(_keyUserId, v);
  }

  static Future<String> getUserId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyUserId) ?? '';
  }

  // --- App ID (Acharyaji code validated) ---
  static Future<void> setAppId(String v) async {
    final p = await SharedPreferences.getInstance();
    p.setString(_keyAppId, v);
  }

  static Future<String> getAppId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyAppId) ?? '';
  }

  // --- Report ID (selected member) ---
  static Future<void> setRId(String v) async {
    final p = await SharedPreferences.getInstance();
    p.setString(_keyRId, v);
  }

  static Future<String> getRId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyRId) ?? '';
  }

  // --- User name ---
  static Future<void> setUserName(String v) async {
    final p = await SharedPreferences.getInstance();
    p.setString(_keyUserName, v);
  }

  static Future<String> getUserName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyUserName) ?? '';
  }

  // --- Duration ---
  static Future<void> setDuration(String v) async {
    final p = await SharedPreferences.getInstance();
    p.setString(_keyDuration, v);
  }

  static Future<String> getDuration() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyDuration) ?? '';
  }

  // --- Start month ---
  static Future<void> setStartMonth(String v) async {
    final p = await SharedPreferences.getInstance();
    p.setString(_keyStartMonth, v);
  }

  static Future<String> getStartMonth() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyStartMonth) ?? '';
  }

  // --- Logout ---
  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }
}
