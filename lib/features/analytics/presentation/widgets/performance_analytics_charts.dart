import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../domain/models/analytics.dart';

/// Formats bytes into human-readable format (KB, MB, GB, TB)
String _formatBytesForAxis(num bytes) {
  if (bytes >= 1024 * 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1)} TB';
  }
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${bytes.toInt()} B';
}

class PerformanceTimeSeriesChart extends StatelessWidget {
  const PerformanceTimeSeriesChart({
    super.key,
    required this.title,
    required this.timeSeries,
    required this.valueMapper,
    required this.cachedValueMapper,
    this.unit = '',
  });

  final String title;
  final List<PerformanceTimeSeries> timeSeries;
  final num Function(PerformanceTimeSeries) valueMapper;
  final num Function(PerformanceTimeSeries) cachedValueMapper;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (timeSeries.isEmpty) {
      return _buildEmptyState(context);
    }

    final dataPoints = timeSeries.map((ts) {
      return _PerformanceTimeSeriesPoint(
        timestamp: DateTime.parse(ts.timestamp),
        total: valueMapper(ts),
        cached: cachedValueMapper(ts),
      );
    }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.Hm(),
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(dashArray: [5, 5]),
                  axisLabelFormatter: unit == 'bytes'
                      ? (AxisLabelRenderDetails details) {
                          return ChartAxisLabel(
                            _formatBytesForAxis(details.value),
                            details.textStyle,
                          );
                        }
                      : null,
                ),
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  AreaSeries<_PerformanceTimeSeriesPoint, DateTime>(
                    name: 'Total',
                    dataSource: dataPoints,
                    xValueMapper: (data, _) => data.timestamp,
                    yValueMapper: (data, _) => data.total,
                    color: Colors.blue.withValues(alpha: 0.3),
                    borderColor: Colors.blue,
                    borderWidth: 1,
                  ),
                  AreaSeries<_PerformanceTimeSeriesPoint, DateTime>(
                    name: 'Cached',
                    dataSource: dataPoints,
                    xValueMapper: (data, _) => data.timestamp,
                    yValueMapper: (data, _) => data.cached,
                    color: Colors.green.withValues(alpha: 0.3),
                    borderColor: Colors.green,
                    borderWidth: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

class _PerformanceTimeSeriesPoint {
  _PerformanceTimeSeriesPoint({
    required this.timestamp,
    required this.total,
    required this.cached,
  });
  final DateTime timestamp;
  final num total;
  final num cached;
}
