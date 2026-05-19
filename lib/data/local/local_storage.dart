import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _themeKey = 'theme_mode';
  static const String _userKey = 'cached_user';

  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() => _prefs.getString(_tokenKey);

  Future<void> setRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  Future<void> setFirstLaunch(bool value) async {
    await _prefs.setBool(_firstLaunchKey, value);
  }

  bool? getFirstLaunch() => _prefs.getBool(_firstLaunchKey);

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_onboardingKey, value);
  }

  bool getOnboardingCompleted() => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }

  String? getThemeMode() => _prefs.getString(_themeKey);

  Future<void> cacheUser(Map<String, dynamic> user) async {
    await _prefs.setString(_userKey, jsonEncode(user));
  }

  Map<String, dynamic>? getCachedUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearCachedUser() async {
    await _prefs.remove(_userKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
