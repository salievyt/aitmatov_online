import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureLocalStorage {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  SecureLocalStorage(this._prefs)
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _themeKey = 'theme_mode';
  static const String _userKey = 'cached_user';
  static const String _migrationKey = 'secure_storage_migrated';

  Future<void> migrateFromSharedPreferences() async {
    final migrated = _prefs.getBool(_migrationKey) ?? false;
    if (migrated) return;

    try {
      // Migrate access token with atomic write-verify-delete pattern
      final oldToken = _prefs.getString(_tokenKey);
      if (oldToken != null && oldToken.isNotEmpty) {
        // Step 1: Write to secure storage
        await _secureStorage.write(key: _tokenKey, value: oldToken);

        // Step 2: Verify the write was successful
        final verifyToken = await _secureStorage.read(key: _tokenKey);
        if (verifyToken == oldToken) {
          // Step 3: Only delete from SharedPreferences after verification
          await _prefs.remove(_tokenKey);
        } else {
          // Verification failed, log error but don't delete old token
          debugPrint('Token migration verification failed, keeping fallback in SharedPreferences');
        }
      }

      // Migrate refresh token with same atomic pattern
      final oldRefreshToken = _prefs.getString(_refreshTokenKey);
      if (oldRefreshToken != null && oldRefreshToken.isNotEmpty) {
        await _secureStorage.write(key: _refreshTokenKey, value: oldRefreshToken);

        final verifyRefreshToken = await _secureStorage.read(key: _refreshTokenKey);
        if (verifyRefreshToken == oldRefreshToken) {
          await _prefs.remove(_refreshTokenKey);
        } else {
          debugPrint('Refresh token migration verification failed, keeping fallback in SharedPreferences');
        }
      }

      // Mark migration as complete only if we got this far
      await _prefs.setBool(_migrationKey, true);
    } catch (e, stackTrace) {
      // Log error but don't mark as migrated - will retry next time
      debugPrint('Token migration failed: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't set migration flag, so it will retry on next app start
    }
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('Error reading token from secure storage: $e');
      // DO NOT fallback to insecure storage - force re-authentication
      return null;
    }
  }

  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      if (token != null && token.isNotEmpty) return token;

      // Fallback to SharedPreferences if secure storage is empty
      final fallbackToken = _prefs.getString(_refreshTokenKey);
      if (fallbackToken != null && fallbackToken.isNotEmpty) {
        debugPrint('Using fallback refresh token from SharedPreferences');
        return fallbackToken;
      }

      return null;
    } catch (e) {
      debugPrint('Error reading refresh token from secure storage: $e');
      // Try fallback on error
      return _prefs.getString(_refreshTokenKey);
    }
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
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
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
