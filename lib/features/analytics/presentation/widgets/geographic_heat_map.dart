import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../../../../core/providers/country_provider.dart';
import '../../domain/models/analytics.dart';

/// Geographic heatmap showing traffic distribution by country
class GeographicHeatMap extends ConsumerWidget {
  const GeographicHeatMap({
    super.key,
    required this.title,
    required this.groups,
  });

  final String title;
  final List<AnalyticsGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final countryNotifier = ref.watch(countryNotifierProvider.notifier);

    if (groups.isEmpty) {
      return _buildEmptyState(context);
    }

    // Build data for choropleth map
    final dataSource = _buildMapDataSource(groups, countryNotifier);

    if (dataSource.isEmpty) {
      return _buildEmptyState(context);
    }

    // Find max for color scaling
    final maxCount = dataSource
        .map((d) => d.count)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SfMaps(
                layers: [
                  MapShapeLayer(
                    source: MapShapeSource.asset(
                      'assets/data/world.json',
                      shapeDataField: 'ISO_A2',
                      dataCount: dataSource.length,
                      primaryValueMapper: (index) => dataSource[index].code,
                      shapeColorValueMapper: (index) =>
                          dataSource[index].count.toDouble(),
                      shapeColorMappers: [
                        MapColorMapper(
                          from: 0,
                          to: maxCount * 0.2,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        MapColorMapper(
                          from: maxCount * 0.2,
                          to: maxCount * 0.4,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        MapColorMapper(
                          from: maxCount * 0.4,
                          to: maxCount * 0.6,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        MapColorMapper(
                          from: maxCount * 0.6,
                          to: maxCount * 0.8,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        MapColorMapper(
                          from: maxCount * 0.8,
                          to: maxCount.toDouble(),
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    strokeColor: isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
                    strokeWidth: 0.5,
                    zoomPanBehavior: MapZoomPanBehavior(
                      enablePinching: true,
                      enablePanning: true,
                      zoomLevel: 1,
                      minZoomLevel: 1,
                      maxZoomLevel: 10,
                    ),
                    shapeTooltipBuilder: (context, index) {
                      final data = dataSource[index];
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${data.name}: ${_formatNumber(data.count)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                    tooltipSettings: const MapTooltipSettings(
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_CountryMapData> _buildMapDataSource(
    List<AnalyticsGroup> groups,
    CountryNotifier countryNotifier,
  ) {
    final result = <_CountryMapData>[];

    for (final group in groups) {
      final code =
          group.dimensions['clientCountryName'] as String? ??
          group.dimensions['clientCountryAlpha2'] as String? ??
          '';

      if (code.isEmpty || code == 'XX' || code == 'T1') continue;

      result.add(
        _CountryMapData(
          code: code.toUpperCase(),
          name: countryNotifier.getName(code),
          count: group.count,
        ),
      );
    }

    return result;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No geographic data available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryMapData {
  _CountryMapData({
    required this.code,
    required this.name,
    required this.count,
  });

  final String code;
  final String name;
  final int count;
}
