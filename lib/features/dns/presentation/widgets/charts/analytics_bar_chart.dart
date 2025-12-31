import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../analytics/domain/models/analytics.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/data_centers_provider.dart';

/// Bar chart for displaying analytics group data
class AnalyticsBarChart extends ConsumerWidget {
  const AnalyticsBarChart({
    super.key,
    required this.title,
    required this.groups,
    required this.dimensionKey,
    this.maxItems = 10,
    this.horizontal = false,
  });

  final String title;
  final List<AnalyticsGroup> groups;
  final String dimensionKey;
  final int maxItems;
  final bool horizontal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (groups.isEmpty) {
      return _buildEmptyState(context);
    }

    // Get data centers for city name lookup
    final dataCenters =
        ref.watch(dataCentersNotifierProvider).valueOrNull ?? {};

    // Sort by count descending and take top items
    final sortedGroups = List<AnalyticsGroup>.from(groups)
      ..sort((a, b) => b.count.compareTo(a.count));
    final topGroups = sortedGroups.take(maxItems).toList();

    final dataPoints = topGroups
        .map(
          (g) =>
              _ChartDataPoint(label: _getLabel(g, dataCenters), value: g.count),
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Expanded(
              child: horizontal
                  ? _buildHorizontalChart(context, dataPoints)
                  : _buildVerticalChart(context, dataPoints),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalChart(
    BuildContext context,
    List<_ChartDataPoint> dataPoints,
  ) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        labelStyle: TextStyle(fontSize: 10),
        labelRotation: 45,
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
        majorGridLines: const MajorGridLines(dashArray: [5, 5]),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        zoomMode: ZoomMode.x,
      ),
      series: <CartesianSeries>[
        ColumnSeries<_ChartDataPoint, String>(
          dataSource: dataPoints,
          xValueMapper: (data, _) => data.label,
          yValueMapper: (data, _) => data.value,
          pointColorMapper: (data, index) =>
              analyticsColors[index % analyticsColors.length],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(fontSize: 9),
          ),
          dataLabelMapper: (data, _) => _formatNumber(data.value),
        ),
      ],
    );
  }

  Widget _buildHorizontalChart(
    BuildContext context,
    List<_ChartDataPoint> dataPoints,
  ) {
    // Reverse for horizontal to show highest at top
    final reversed = dataPoints.reversed.toList();

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        labelStyle: TextStyle(fontSize: 10),
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
        majorGridLines: const MajorGridLines(dashArray: [5, 5]),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        zoomMode: ZoomMode.x,
      ),
      series: <CartesianSeries>[
        BarSeries<_ChartDataPoint, String>(
          dataSource: reversed,
          xValueMapper: (data, _) => data.label,
          yValueMapper: (data, _) => data.value,
          pointColorMapper: (data, index) =>
              analyticsColors[index % analyticsColors.length],
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(4),
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(fontSize: 9),
          ),
          dataLabelMapper: (data, _) => _formatNumber(data.value),
        ),
      ],
    );
  }

  String _getLabel(
    AnalyticsGroup group,
    Map<String, DataCenterInfo> dataCenters,
  ) {
    final value = group.dimensions[dimensionKey];
    if (value == null) return 'Unknown';

    // If this is a coloName (data center), try to get the city name
    if (dimensionKey == 'coloName') {
      final iata = value.toString();
      final info = dataCenters[iata];
      if (info != null) {
        return info.place;
      }
    }

    return value.toString();
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const Expanded(
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartDataPoint {
  _ChartDataPoint({required this.label, required this.value});

  final String label;
  final int value;
}
