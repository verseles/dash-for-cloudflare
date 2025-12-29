import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../../../core/api/api_config.dart';

part 'settings_provider.g.dart';

/// Keys for storage
const String _tokenKey = 'cloudflare_api_token';
const String _themeModeKey = 'theme_mode';
const String _localeKey = 'locale';
const String _selectedZoneIdKey = 'selected_zone_id';

/// Provider for FlutterSecureStorage
@riverpod
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
}

/// Provider for SharedPreferences
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// Settings state notifier
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  @override
  FutureOr<AppSettings> build() async {
    _secureStorage = ref.read(secureStorageProvider);
    _prefs = await ref.read(sharedPreferencesProvider.future);
    return _loadSettings();
  }

  Future<AppSettings> _loadSettings() async {
    // Load token from secure storage
    final token = await _secureStorage.read(key: _tokenKey);

    // Load other settings from shared preferences
    final themeModeStr = _prefs?.getString(_themeModeKey) ?? 'system';
    final locale = _prefs?.getString(_localeKey) ?? 'en';
    final selectedZoneId = _prefs?.getString(_selectedZoneIdKey);

    final themeMode = switch (themeModeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return AppSettings(
      cloudflareApiToken: token,
      themeMode: themeMode,
      locale: locale,
      selectedZoneId: selectedZoneId,
    );
  }

  /// Save API token to secure storage
  Future<void> setApiToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _secureStorage.delete(key: _tokenKey);
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
    }

    state = AsyncData(state.value!.copyWith(cloudflareApiToken: token));
  }

  /// Validate token format
  bool isTokenValid(String? token) {
    return ApiConfig.isValidToken(token);
  }

  /// Save theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs?.setString(_themeModeKey, modeStr);
    state = AsyncData(state.value!.copyWith(themeMode: mode));
  }

  /// Save locale
  Future<void> setLocale(String locale) async {
    await _prefs?.setString(_localeKey, locale);
    state = AsyncData(state.value!.copyWith(locale: locale));
  }

  /// Save selected zone ID
  Future<void> setSelectedZoneId(String? zoneId) async {
    if (zoneId == null) {
      await _prefs?.remove(_selectedZoneIdKey);
    } else {
      await _prefs?.setString(_selectedZoneIdKey, zoneId);
    }
    state = AsyncData(state.value!.copyWith(selectedZoneId: zoneId));
  }

  /// Check if user has a valid token
  bool get hasValidToken {
    final token = state.valueOrNull?.cloudflareApiToken;
    return isTokenValid(token);
  }
}

/// Convenient provider for current API token
@riverpod
String currentApiToken(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.valueOrNull?.cloudflareApiToken ?? '';
}

/// Convenient provider for current theme mode
@riverpod
ThemeMode currentThemeMode(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.valueOrNull?.themeMode ?? ThemeMode.system;
}

/// Convenient provider for current locale
@riverpod
String currentLocale(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.valueOrNull?.locale ?? 'en';
}

/// Provider to check if token is valid
@riverpod
bool hasValidToken(Ref ref) {
  final settings = ref.watch(settingsNotifierProvider);
  final token = settings.valueOrNull?.cloudflareApiToken;
  return ApiConfig.isValidToken(token);
}
