import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/zone.dart';
import '../../auth/providers/settings_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import '../../../core/logging/log_level.dart';

part 'zone_provider.g.dart';

/// Provider for fetching and caching zones
@riverpod
class ZonesNotifier extends _$ZonesNotifier {
  @override
  FutureOr<List<Zone>> build() async {
    // Only fetch if we have a valid token
    final hasToken = ref.watch(hasValidTokenProvider);
    if (!hasToken) {
      log.info('ZonesNotifier: No valid token, returning empty list', category: LogCategory.state);
      return [];
    }

    return _fetchZones();
  }

  Future<List<Zone>> _fetchZones() async {
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

      log.stateChange('ZonesNotifier', 'Fetched ${response.result!.length} zones');
      return response.result!;
    } catch (e, stack) {
      log.error('ZonesNotifier: Exception fetching zones', error: e, stackTrace: stack);
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

    final zones = zonesAsync.valueOrNull ?? [];
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
    final zones = ref.read(zonesNotifierProvider).valueOrNull ?? [];
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
  final zones = ref.watch(zonesNotifierProvider).valueOrNull ?? [];
  final filter = ref.watch(zoneFilterProvider);

  if (filter.isEmpty) return zones;

  return zones
      .where((z) => z.name.toLowerCase().contains(filter.toLowerCase()))
      .toList();
}
