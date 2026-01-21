import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../domain/models/analytics.dart';
import '../../../../core/theme/app_theme.dart';

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

class WebTimeSeriesChart extends StatelessWidget {
  const WebTimeSeriesChart({
    super.key,
    required this.title,
    required this.timeSeries,
    required this.valueMapper,
    this.unit = '',
    this.color,
  });

  final String title;
  final List<WebTimeSeries> timeSeries;
  final num Function(WebTimeSeries) valueMapper;
  final String unit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (timeSeries.isEmpty) {
      return _buildEmptyState(context);
    }

    final dataPoints = timeSeries.map((ts) {
      return _TimeSeriesPoint(
        timestamp: DateTime.parse(ts.timestamp),
        value: valueMapper(ts),
      );
    }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final chartColor = color ?? cloudflareOrange;

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
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  format: 'point.y $unit at point.x',
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  zoomMode: ZoomMode.x,
                ),
                series: <CartesianSeries>[
                  AreaSeries<_TimeSeriesPoint, DateTime>(
                    dataSource: dataPoints,
                    xValueMapper: (data, _) => data.timestamp,
                    yValueMapper: (data, _) => data.value,
                    color: chartColor.withValues(alpha: 0.3),
                    borderColor: chartColor,
                    borderWidth: 2,
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

class _TimeSeriesPoint {
  _TimeSeriesPoint({required this.timestamp, required this.value});
  final DateTime timestamp;
  final num value;
}
