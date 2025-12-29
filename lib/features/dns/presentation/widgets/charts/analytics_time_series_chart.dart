import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../analytics/domain/models/analytics.dart';
import '../../../../../core/theme/app_theme.dart';

/// Line chart for displaying time series analytics data
class AnalyticsTimeSeriesChart extends StatelessWidget {
  const AnalyticsTimeSeriesChart({
    super.key,
    required this.title,
    required this.timeSeries,
    this.byQueryNameTimeSeries,
  });

  final String title;
  final List<AnalyticsTimeSeries> timeSeries;
  final Map<String, List<AnalyticsTimeSeries>>? byQueryNameTimeSeries;

  @override
  Widget build(BuildContext context) {
    final hasQueryNameData =
        byQueryNameTimeSeries != null && byQueryNameTimeSeries!.isNotEmpty;

    if (timeSeries.isEmpty && !hasQueryNameData) {
      return _buildEmptyState(context);
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
              child: hasQueryNameData
                  ? _buildMultiSeriesChart(context)
                  : _buildSingleSeriesChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleSeriesChart(BuildContext context) {
    final dataPoints =
        timeSeries
            .map(
              (ts) => _TimeSeriesPoint(
                timestamp: DateTime.parse(ts.timestamp),
                value: ts.count,
              ),
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Hm(),
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: const TextStyle(fontSize: 10),
      ),
      primaryYAxis: const NumericAxis(
        majorGridLines: MajorGridLines(dashArray: [5, 5]),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        format: 'point.y queries at point.x',
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
          color: cloudflareOrange.withValues(alpha: 0.3),
          borderColor: cloudflareOrange,
          borderWidth: 2,
        ),
      ],
    );
  }

  Widget _buildMultiSeriesChart(BuildContext context) {
    final series = <CartesianSeries>[];
    var colorIndex = 0;

    byQueryNameTimeSeries!.forEach((queryName, data) {
      final dataPoints =
          data
              .map(
                (ts) => _TimeSeriesPoint(
                  timestamp: DateTime.parse(ts.timestamp),
                  value: ts.count,
                ),
              )
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final color = analyticsColors[colorIndex % analyticsColors.length];
      colorIndex++;

      series.add(
        LineSeries<_TimeSeriesPoint, DateTime>(
          name: queryName,
          dataSource: dataPoints,
          xValueMapper: (data, _) => data.timestamp,
          yValueMapper: (data, _) => data.value,
          color: color,
          width: 2,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 4,
            width: 4,
          ),
        ),
      );
    });

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Hm(),
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: const TextStyle(fontSize: 10),
      ),
      primaryYAxis: const NumericAxis(
        majorGridLines: MajorGridLines(dashArray: [5, 5]),
      ),
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(fontSize: 10),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        zoomMode: ZoomMode.x,
      ),
      series: series,
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
  final int value;
}
