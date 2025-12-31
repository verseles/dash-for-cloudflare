import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../analytics/domain/models/analytics.dart';
import '../../../../../core/theme/app_theme.dart';

/// Bar chart for displaying analytics group data
class AnalyticsBarChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort by count descending and take top items
    final sortedGroups = List<AnalyticsGroup>.from(groups)
      ..sort((a, b) => b.count.compareTo(a.count));
    final topGroups = sortedGroups.take(maxItems).toList();

    final dataPoints = topGroups
        .map((g) => _ChartDataPoint(label: _getLabel(g), value: g.count))
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

  String _getLabel(AnalyticsGroup group) {
    final value = group.dimensions[dimensionKey];
    if (value == null) return 'Unknown';
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
