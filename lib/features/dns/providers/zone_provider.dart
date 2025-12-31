import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/zone.dart';
import '../../auth/providers/settings_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import '../../../core/logging/log_level.dart';

part 'zone_provider.g.dart';

/// Cache expiration duration (3 days)
const _cacheMaxAge = Duration(days: 3);

/// State for zones with cache metadata
class ZonesState {
  const ZonesState({
    this.zones = const [],
    this.isFromCache = false,
    this.isRefreshing = false,
    this.cachedAt,
  });

  final List<Zone> zones;
  final bool isFromCache;
  final bool isRefreshing;
  final DateTime? cachedAt;

  ZonesState copyWith({
    List<Zone>? zones,
    bool? isFromCache,
    bool? isRefreshing,
    DateTime? cachedAt,
  }) {
    return ZonesState(
      zones: zones ?? this.zones,
      isFromCache: isFromCache ?? this.isFromCache,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

/// Provider for fetching and caching zones (ADR-022 pattern)
@riverpod
class ZonesNotifier extends _$ZonesNotifier {
  SharedPreferences? _prefs;

  static const _cacheKey = 'zones_cache';
  static const _cacheTimeKey = 'zones_cache_time';

  @override
  FutureOr<ZonesState> build() async {
    // Only fetch if we have a valid token
    final hasToken = ref.watch(hasValidTokenProvider);
    if (!hasToken) {
      log.info(
        'ZonesNotifier: No valid token, returning empty list',
        category: LogCategory.state,
      );
      return const ZonesState();
    }

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try to load from cache first
    final cachedState = await _loadFromCache();
    if (cachedState != null) {
      // Return cached data and refresh in background
      unawaited(_refreshInBackground(cachedState));
      return cachedState;
    }

    // No cache, fetch from API
    return _fetchZones();
  }

  Future<ZonesState?> _loadFromCache() async {
    try {
      final cachedJson = _prefs?.getString(_cacheKey);
      final cachedTimeStr = _prefs?.getString(_cacheTimeKey);

      if (cachedJson == null || cachedTimeStr == null) return null;

      final cachedTime = DateTime.parse(cachedTimeStr);
      final age = DateTime.now().difference(cachedTime);

      // Check if cache is still valid
      if (age > _cacheMaxAge) {
        log.info(
          'ZonesNotifier: Cache expired (${age.inDays} days old)',
          category: LogCategory.state,
        );
        return null;
      }

      final List<dynamic> zonesJson = json.decode(cachedJson) as List<dynamic>;
      final zones = zonesJson
          .map((e) => Zone.fromJson(e as Map<String, dynamic>))
          .toList();

      log.info(
        'ZonesNotifier: Loaded ${zones.length} zones from cache (${age.inMinutes} minutes old)',
        category: LogCategory.state,
      );

      return ZonesState(zones: zones, isFromCache: true, cachedAt: cachedTime);
    } catch (e, stack) {
      log.warning('ZonesNotifier: Failed to load cache', details: e.toString());
      log.error('ZonesNotifier: Cache error', error: e, stackTrace: stack);
      return null;
    }
  }

  Future<void> _saveToCache(List<Zone> zones) async {
    try {
      final zonesJson = zones.map((z) => z.toJson()).toList();
      await _prefs?.setString(_cacheKey, json.encode(zonesJson));
      await _prefs?.setString(_cacheTimeKey, DateTime.now().toIso8601String());
      log.info(
        'ZonesNotifier: Saved ${zones.length} zones to cache',
        category: LogCategory.state,
      );
    } catch (e) {
      log.warning('ZonesNotifier: Failed to save cache', details: e.toString());
    }
  }

  Future<void> _refreshInBackground(ZonesState currentState) async {
    // Mark as refreshing
    state = AsyncData(currentState.copyWith(isRefreshing: true));

    try {
      final freshState = await _fetchZonesFromApi();
      state = AsyncData(freshState);
    } catch (e) {
      // Keep showing cached data on error
      log.warning(
        'ZonesNotifier: Background refresh failed, keeping cache',
        details: e.toString(),
      );
      state = AsyncData(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<ZonesState> _fetchZones() async {
    return _fetchZonesFromApi();
  }

  Future<ZonesState> _fetchZonesFromApi() async {
    log.stateChange('ZonesNotifier', 'Fetching zones...');

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getZones();

      if (!response.success || response.result == null) {
        final error = response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Failed to fetch zones';
        log.error('Failed to fetch zones', details: error);
        throw Exception(error);
      }

      final zones = response.result!;
      log.stateChange('ZonesNotifier', 'Fetched ${zones.length} zones');

      // Save to cache
      unawaited(_saveToCache(zones));

      return ZonesState(
        zones: zones,
        isFromCache: false,
        cachedAt: DateTime.now(),
      );
    } catch (e, stack) {
      log.error(
        'ZonesNotifier: Exception fetching zones',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Refresh zones list
  Future<void> refresh() async {
    log.stateChange('ZonesNotifier', 'Refreshing zones');
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchZones);
  }
}

/// Provider for the currently selected zone
@riverpod
class SelectedZoneNotifier extends _$SelectedZoneNotifier {
  @override
  Zone? build() {
    // Watch zones to get the list
    final zonesAsync = ref.watch(zonesNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    final zones = zonesAsync.valueOrNull?.zones ?? [];
    final savedZoneId = settings.valueOrNull?.selectedZoneId;

    if (zones.isEmpty) return null;

    // Try to find saved zone
    if (savedZoneId != null) {
      final savedZone = zones.where((z) => z.id == savedZoneId).firstOrNull;
      if (savedZone != null) return savedZone;
    }

    // Auto-select first zone if none saved or saved not found
    return zones.first;
  }

  /// Select a zone and persist
  Future<void> selectZone(Zone zone) async {
    state = zone;
    await ref
        .read(settingsNotifierProvider.notifier)
        .setSelectedZoneId(zone.id);
  }

  /// Clear selection
  Future<void> clearSelection() async {
    state = null;
    await ref.read(settingsNotifierProvider.notifier).setSelectedZoneId(null);
  }
}

/// Convenient provider for selected zone ID
@riverpod
String? selectedZoneId(Ref ref) {
  return ref.watch(selectedZoneNotifierProvider)?.id;
}

/// Provider that auto-selects zone when filter returns single result
@riverpod
class ZoneFilter extends _$ZoneFilter {
  @override
  String build() => '';

  void setFilter(String query) {
    state = query;

    // Auto-select if filter returns exactly 1 result
    final zones = ref.read(zonesNotifierProvider).valueOrNull?.zones ?? [];
    final filtered = zones
        .where((z) => z.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filtered.length == 1) {
      ref
          .read(selectedZoneNotifierProvider.notifier)
          .selectZone(filtered.first);
    }
  }

  void clear() {
    state = '';
  }
}

/// Provider for filtered zones based on search query
@riverpod
List<Zone> filteredZones(Ref ref) {
  final zones = ref.watch(zonesNotifierProvider).valueOrNull?.zones ?? [];
  final filter = ref.watch(zoneFilterProvider);

  if (filter.isEmpty) return zones;

  return zones
      .where((z) => z.name.toLowerCase().contains(filter.toLowerCase()))
      .toList();
}
