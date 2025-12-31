import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../../../../../core/providers/data_centers_provider.dart';
import '../../../../../core/logging/log_service.dart';
import '../../../../analytics/domain/models/analytics.dart';

/// Map data point for bubble overlay
class MapDataPoint {
  MapDataPoint({
    required this.iata,
    required this.place,
    required this.lat,
    required this.lng,
    required this.count,
  });

  final String iata;
  final String place;
  final double lat;
  final double lng;
  final int count;
}

/// World map chart showing DNS queries by data center location
class AnalyticsMapChart extends ConsumerWidget {
  const AnalyticsMapChart({
    super.key,
    required this.title,
    required this.groups,
  });

  final String title;
  final List<AnalyticsGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataCentersAsync = ref.watch(dataCentersNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: dataCentersAsync.when(
                data: (dataCenters) => _buildMap(context, dataCenters, isDark),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => _buildMap(context, {}, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(
    BuildContext context,
    Map<String, DataCenterInfo> dataCenters,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    // Debug logging
    log.debug(
      'AnalyticsMapChart: groups=${groups.length}, dataCenters=${dataCenters.length}',
    );

    // Build data points by matching IATA codes
    final dataPoints = <MapDataPoint>[];
    int maxCount = 0;
    final missingColos = <String>[];

    for (final group in groups) {
      final coloName = group.dimensions['coloName'] as String?;
      if (coloName == null) {
        log.debug('AnalyticsMapChart: group missing coloName: ${group.dimensions}');
        continue;
      }

      final info = dataCenters[coloName];
      if (info != null && info.lat != 0.0 && info.lng != 0.0) {
        dataPoints.add(
          MapDataPoint(
            iata: coloName,
            place: info.place,
            lat: info.lat,
            lng: info.lng,
            count: group.count,
          ),
        );
        if (group.count > maxCount) maxCount = group.count;
      } else {
        missingColos.add(coloName);
      }
    }

    if (missingColos.isNotEmpty) {
      log.debug('AnalyticsMapChart: colos not found in dataCenters: $missingColos');
    }
    log.debug('AnalyticsMapChart: built ${dataPoints.length} data points');

    if (dataPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: theme.disabledColor),
            const SizedBox(height: 8),
            Text(
              'No location data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    // Use a unique key based on dataPoints to force SfMaps rebuild when data changes
    // This is necessary because initialMarkersCount doesn't update dynamically
    final mapKey = ValueKey('map_${dataPoints.length}_${dataPoints.map((p) => p.iata).join('_')}');

    return SfMaps(
      key: mapKey,
      layers: [
        MapShapeLayer(
          source: const MapShapeSource.asset(
            'assets/data/world.json',
            shapeDataField: 'name',
          ),
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          strokeColor: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          strokeWidth: 0.5,
          initialMarkersCount: dataPoints.length,
          markerBuilder: (context, index) {
            final point = dataPoints[index];
            // Calculate bubble size based on count (min 6, max 30)
            final normalizedSize = maxCount > 0
                ? (point.count / maxCount * 24) + 6
                : 10.0;

            return MapMarker(
              latitude: point.lat,
              longitude: point.lng,
              child: Tooltip(
                message:
                    '${point.place}\n${point.iata}: ${_formatNumber(point.count)} queries',
                child: Container(
                  width: normalizedSize,
                  height: normalizedSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(180),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            );
          },
          tooltipSettings: const MapTooltipSettings(color: Colors.black87),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
