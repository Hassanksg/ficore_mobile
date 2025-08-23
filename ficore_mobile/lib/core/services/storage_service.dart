import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Initialize storage
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Ensure preferences are initialized
  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Authentication Token (Secure Storage)
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConfig.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConfig.tokenKey);
  }

  // Session ID (Secure Storage)
  static Future<void> saveSessionId(String sessionId) async {
    await _secureStorage.write(key: AppConfig.sessionKey, value: sessionId);
  }

  static Future<String?> getSessionId() async {
    return await _secureStorage.read(key: AppConfig.sessionKey);
  }

  static Future<void> deleteSessionId() async {
    await _secureStorage.delete(key: AppConfig.sessionKey);
  }

  // User Data (Regular Storage)
  static Future<void> saveUser(User user) async {
    final prefs = await _preferences;
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(AppConfig.userKey, userJson);
  }

  static Future<User?> getUser() async {
    try {
      final prefs = await _preferences;
      final userJson = prefs.getString(AppConfig.userKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
    } catch (e) {
      // Handle parsing errors
      await deleteUser();
    }
    return null;
  }

  static Future<void> deleteUser() async {
    final prefs = await _preferences;
    await prefs.remove(AppConfig.userKey);
  }

  // Language Preference
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await _preferences;
    await prefs.setString(AppConfig.languageKey, languageCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await _preferences;
    return prefs.getString(AppConfig.languageKey) ?? AppConfig.defaultLanguage;
  }

  // Theme Mode
  static Future<void> saveThemeMode(String themeMode) async {
    final prefs = await _preferences;
    await prefs.setString(AppConfig.themeKey, themeMode);
  }

  static Future<String> getThemeMode() async {
    final prefs = await _preferences;
    return prefs.getString(AppConfig.themeKey) ?? 'system';
  }

  // Ficore Credits Cache
  static Future<void> saveCredits(double credits) async {
    final prefs = await _preferences;
    await prefs.setDouble(AppConfig.creditsKey, credits);
  }

  static Future<double> getCredits() async {
    final prefs = await _preferences;
    return prefs.getDouble(AppConfig.creditsKey) ?? AppConfig.defaultCredits.toDouble();
  }

  // First Launch Flag
  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    final prefs = await _preferences;
    await prefs.setBool('first_launch', isFirstLaunch);
  }

  static Future<bool> isFirstLaunch() async {
    final prefs = await _preferences;
    return prefs.getBool('first_launch') ?? true;
  }

  // Onboarding Completed Flag
  static Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await _preferences;
    await prefs.setBool('onboarding_completed', completed);
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await _preferences;
    return prefs.getBool('onboarding_completed') ?? false;
  }

  // Biometric Authentication Enabled
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool('biometric_enabled', enabled);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool('biometric_enabled') ?? false;
  }

  // Push Notifications Enabled
  static Future<void> setPushNotificationsEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool('push_notifications_enabled', enabled);
  }

  static Future<bool> isPushNotificationsEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool('push_notifications_enabled') ?? true;
  }

  // Last Sync Timestamp
  static Future<void> saveLastSyncTime(DateTime timestamp) async {
    final prefs = await _preferences;
    await prefs.setString('last_sync_time', timestamp.toIso8601String());
  }

  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await _preferences;
      final timestampString = prefs.getString('last_sync_time');
      if (timestampString != null) {
        return DateTime.parse(timestampString);
      }
    } catch (e) {
      // Handle parsing errors
    }
    return null;
  }

  // Cache Management
  static Future<void> saveCache(String key, Map<String, dynamic> data) async {
    final prefs = await _preferences;
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString('cache_$key', jsonEncode(cacheData));
  }

  static Future<Map<String, dynamic>?> getCache(String key, {Duration? maxAge}) async {
    try {
      final prefs = await _preferences;
      final cacheString = prefs.getString('cache_$key');
      if (cacheString != null) {
        final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
        final timestamp = DateTime.parse(cacheData['timestamp'] as String);
        
        // Check if cache is still valid
        if (maxAge != null && DateTime.now().difference(timestamp) > maxAge) {
          await clearCache(key);
          return null;
        }
        
        return cacheData['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      // Handle parsing errors
      await clearCache(key);
    }
    return null;
  }

  static Future<void> clearCache(String key) async {
    final prefs = await _preferences;
    await prefs.remove('cache_$key');
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    final prefs = await _preferences;
    final keys = prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    await deleteToken();
    await deleteSessionId();
    await deleteUser();
  }

  // Clear all app data (for logout or reset)
  static Future<void> clearAllData() async {
    await clearAuthData();
    await clearAllCache();
    final prefs = await _preferences;
    await prefs.clear();
    await _secureStorage.deleteAll();
  }

  // Generic key-value storage
  static Future<void> saveString(String key, String value) async {
    final prefs = await _preferences;
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  static Future<void> saveInt(String key, int value) async {
    final prefs = await _preferences;
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  static Future<void> saveDouble(String key, double value) async {
    final prefs = await _preferences;
    await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble(key);
  }

  static Future<void> removeKey(String key) async {
    final prefs = await _preferences;
    await prefs.remove(key);
  }

  static Future<bool> hasKey(String key) async {
    final prefs = await _preferences;
    return prefs.containsKey(key);
  }

  // Get all stored keys (for debugging)
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _preferences;
    return prefs.getKeys();
  }
}