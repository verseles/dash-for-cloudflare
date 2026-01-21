import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../logging/log_service.dart';
import '../logging/log_level.dart';

part 'country_provider.g.dart';

/// CDN URL for country codes JSON (FlagCDN)
const String _countriesCdnUrl = 'https://flagcdn.com/en/codes.json';

/// Country data notifier with Local-First pattern
/// Loads from local asset immediately, then refreshes from CDN in background
@riverpod
class CountryNotifier extends _$CountryNotifier {
  bool _hasFetched = false;

  @override
  FutureOr<Map<String, String>> build() async {
    // Load from local asset first (immediate)
    final localData = await _loadFromAsset();

    // Fetch from CDN in background (if not already fetched)
    if (!_hasFetched) {
      unawaited(_fetchFromCdn());
    }

    return localData;
  }

  Future<Map<String, String>> _loadFromAsset() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/countries.json',
      );
      final data = _parseCountries(jsonString);
      log.info(
        'CountryNotifier: Loaded ${data.length} countries from asset',
        category: LogCategory.state,
      );
      return data;
    } catch (e, stack) {
      log.error(
        'CountryNotifier: Failed to load from asset',
        error: e,
        stackTrace: stack,
      );
      return {};
    }
  }

  Future<void> _fetchFromCdn() async {
    _hasFetched = true;

    try {
      final dio = Dio();
      log.info(
        'CountryNotifier: Fetching from CDN...',
        category: LogCategory.state,
      );
      final response = await dio.get<String>(_countriesCdnUrl);

      if (response.data != null) {
        final updatedData = _parseCountries(response.data!);
        log.info(
          'CountryNotifier: Updated with ${updatedData.length} countries from CDN',
          category: LogCategory.state,
        );
        state = AsyncData(updatedData);
      }
    } catch (e) {
      log.warning(
        'CountryNotifier: Failed to fetch from CDN (using local fallback)',
        details: e.toString(),
      );
      // Silently fail - we have local data as fallback
    }
  }

  Map<String, String> _parseCountries(String jsonString) {
    final dynamic decoded = json.decode(jsonString);
    final Map<String, String> result = {};

    if (decoded is Map<String, dynamic>) {
      for (final entry in decoded.entries) {
        // Store as-is (lowercase keys from CDN)
        result[entry.key] = entry.value as String? ?? entry.key;
      }
    }

    return result;
  }

  /// Get country name from Alpha-2 code
  /// Handles case conversion internally (Cloudflare returns uppercase, CDN uses lowercase)
  String getName(String code) {
    final lowerCode = code.toLowerCase();
    return state.valueOrNull?[lowerCode] ?? code;
  }

  /// Get flag SVG URL from Alpha-2 code
  String getFlagUrl(String code) {
    final lowerCode = code.toLowerCase();
    return 'https://flagcdn.com/$lowerCode.svg';
  }

  /// Get flag PNG URL with specific width (for fallback)
  String getFlagPngUrl(String code, {int width = 40}) {
    final lowerCode = code.toLowerCase();
    return 'https://flagcdn.com/w$width/$lowerCode.png';
  }
}

/// Provider for getting country name by code
@riverpod
String countryName(CountryNameRef ref, String code) {
  final countries = ref.watch(countryNotifierProvider).valueOrNull;
  if (countries == null) return code;
  return countries[code.toLowerCase()] ?? code;
}
