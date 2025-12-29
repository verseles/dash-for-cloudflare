import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../../features/analytics/domain/models/analytics.dart';

part 'data_centers_provider.g.dart';

/// CDN URL for updated data centers list
const String _cdnUrl =
    'https://cdn.jsdelivr.net/gh/insign/Cloudflare-Data-Center-IATA-Code-list/cloudflare-iata-full.json';

/// Data centers notifier
@riverpod
class DataCentersNotifier extends _$DataCentersNotifier {
  bool _hasFetched = false;

  @override
  FutureOr<Map<String, DataCenterInfo>> build() async {
    // Load from local asset first (immediate)
    final localData = await _loadFromAsset();

    // Fetch from CDN in background (if not already fetched)
    if (!_hasFetched) {
      unawaited(_fetchFromCdn());
    }

    return localData;
  }

  Future<Map<String, DataCenterInfo>> _loadFromAsset() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/cloudflare-iata-full.json',
      );
      return _parseDataCenters(jsonString);
    } catch (e) {
      return {};
    }
  }

  Future<void> _fetchFromCdn() async {
    _hasFetched = true;

    try {
      final dio = Dio();
      final response = await dio.get<String>(_cdnUrl);

      if (response.data != null) {
        final updatedData = _parseDataCenters(response.data!);
        state = AsyncData(updatedData);
      }
    } catch (e) {
      // Silently fail - we have local data as fallback
    }
  }

  Map<String, DataCenterInfo> _parseDataCenters(String jsonString) {
    final dynamic decoded = json.decode(jsonString);
    final Map<String, DataCenterInfo> result = {};

    // Handle object format: {"AAE": {"place": "...", "lat": ..., "lng": ...}, ...}
    if (decoded is Map<String, dynamic>) {
      for (final entry in decoded.entries) {
        final iata = entry.key;
        final map = entry.value as Map<String, dynamic>;

        result[iata] = DataCenterInfo(
          iata: iata,
          place: map['place'] as String? ?? iata,
          lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
          lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
        );
      }
    }
    // Handle list format: [{"iata": "AAE", "city": "...", "lat": ..., "lon": ...}, ...]
    else if (decoded is List<dynamic>) {
      for (final item in decoded) {
        final map = item as Map<String, dynamic>;
        final iata = map['iata'] as String?;
        if (iata == null) continue;

        result[iata] = DataCenterInfo(
          iata: iata,
          place: map['city'] as String? ?? map['place'] as String? ?? iata,
          lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
          lng:
              (map['lon'] as num?)?.toDouble() ??
              (map['lng'] as num?)?.toDouble() ??
              0.0,
        );
      }
    }

    return result;
  }

  /// Get info for a specific IATA code
  DataCenterInfo? getByIata(String iata) {
    return state.valueOrNull?[iata];
  }
}

/// Provider for getting a single data center by IATA code
@riverpod
DataCenterInfo? dataCenterByIata(Ref ref, String iata) {
  final dataCenters = ref.watch(dataCentersNotifierProvider).valueOrNull;
  return dataCenters?[iata];
}
