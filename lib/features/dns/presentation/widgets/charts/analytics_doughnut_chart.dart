import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../analytics/domain/models/analytics.dart';
import '../../../../../core/theme/app_theme.dart';

/// Doughnut chart for displaying analytics group data
class AnalyticsDoughnutChart extends StatelessWidget {
  const AnalyticsDoughnutChart({
    super.key,
    required this.title,
    required this.groups,
    required this.dimensionKey,
    this.maxItems = 8,
  });

  final String title;
  final List<AnalyticsGroup> groups;
  final String dimensionKey;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort by count descending and take top items
    final sortedGroups = List<AnalyticsGroup>.from(groups)
      ..sort((a, b) => b.count.compareTo(a.count));

    // Group remaining items as "Other"
    List<_ChartDataPoint> dataPoints;
    if (sortedGroups.length > maxItems) {
      final topItems = sortedGroups.take(maxItems - 1).toList();
      final otherCount = sortedGroups
          .skip(maxItems - 1)
          .fold(0, (sum, g) => sum + g.count);

      dataPoints = [
        ...topItems.map(
          (g) => _ChartDataPoint(label: _getLabel(g), value: g.count),
        ),
        _ChartDataPoint(label: 'Other', value: otherCount),
      ];
    } else {
      dataPoints = sortedGroups
          .map((g) => _ChartDataPoint(label: _getLabel(g), value: g.count))
          .toList();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Expanded(
              child: SfCircularChart(
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: TextStyle(fontSize: 10),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries>[
                  DoughnutSeries<_ChartDataPoint, String>(
                    dataSource: dataPoints,
                    xValueMapper: (data, _) => data.label,
                    yValueMapper: (data, _) => data.value,
                    pointColorMapper: (data, index) =>
                        analyticsColors[index % analyticsColors.length],
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      connectorLineSettings: ConnectorLineSettings(
                        type: ConnectorType.curve,
                        length: '10%',
                      ),
                    ),
                    dataLabelMapper: (data, _) =>
                        '${_formatPercentage(data.value, _totalCount(dataPoints))}%',
                    innerRadius: '50%',
                    radius: '70%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(AnalyticsGroup group) {
    final value = group.dimensions[dimensionKey];
    if (value == null) return 'Unknown';
    return value.toString();
  }

  int _totalCount(List<_ChartDataPoint> points) {
    return points.fold(0, (sum, p) => sum + p.value);
  }

  String _formatPercentage(int value, int total) {
    if (total == 0) return '0';
    return ((value / total) * 100).toStringAsFixed(1);
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
  final String label;
  final int value;

  _ChartDataPoint({required this.label, required this.value});
}
