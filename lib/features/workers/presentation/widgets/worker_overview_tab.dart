import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../domain/models/worker.dart';
import '../../domain/models/worker_analytics.dart';
import '../../providers/workers_provider.dart';
import '../../providers/shared_workers_provider.dart';
import 'worker_time_range_selector.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/error_view.dart';

class WorkerOverviewTab extends ConsumerWidget {
  const WorkerOverviewTab({super.key, required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final timeRange = ref.watch(sharedWorkersTimeRangeProvider);
    
    // Calculate rounded time range based on selected period
    final now = DateTime.now();
    final until = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      (now.minute ~/ 15) * 15,
    );
    final since = until.subtract(timeRange.duration);
    
    final metricsAsync = ref.watch(workerMetricsNotifierProvider(worker.id, since, until));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(workerMetricsNotifierProvider(worker.id, since, until).future),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const WorkerTimeRangeSelector(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context, worker, l10n),
                const SizedBox(height: 24),
                Text(
                  l10n.analytics_queriesOverTime,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: metricsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => CloudflareErrorView(error: err),
                    data: (data) => _buildRequestsChart(context, data, l10n),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.workers_metrics_cpuTime,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: metricsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => CloudflareErrorView(error: err),
                    data: (data) => _buildCpuChart(context, data, l10n),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Worker worker, AppLocalizations l10n) {
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(context, l10n.workers_lastModified(''), dateFormat.format(worker.modifiedOn.toLocal())),
            const Divider(),
            _buildInfoRow(context, l10n.workers_settings_usageModel, worker.usageModel.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRequestsChart(BuildContext context, WorkerAnalyticsData? data, AppLocalizations l10n) {
    if (data == null || data.timeSeries.isEmpty) {
      return Center(child: Text(l10n.workers_metrics_noData));
    }

    return SfCartesianChart(
      margin: EdgeInsets.zero,
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Hm(),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        AreaSeries<WorkerTimeSeries, DateTime>(
          name: l10n.workers_metrics_requests,
          dataSource: data.timeSeries,
          xValueMapper: (v, _) => DateTime.parse(v.timestamp).toLocal(),
          yValueMapper: (v, _) => v.requests,
          color: Colors.blue.withValues(alpha: 0.3),
          borderColor: Colors.blue,
          borderWidth: 2,
        ),
        LineSeries<WorkerTimeSeries, DateTime>(
          name: l10n.workers_metrics_errors,
          dataSource: data.timeSeries,
          xValueMapper: (v, _) => DateTime.parse(v.timestamp).toLocal(),
          yValueMapper: (v, _) => v.errors,
          color: Colors.red,
          width: 2,
        ),
      ],
    );
  }

  Widget _buildCpuChart(BuildContext context, WorkerAnalyticsData? data, AppLocalizations l10n) {
    if (data == null || data.timeSeries.isEmpty) {
      return Center(child: Text(l10n.workers_metrics_noData));
    }

    return SfCartesianChart(
      margin: EdgeInsets.zero,
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Hm(),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}ms',
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ColumnSeries<WorkerTimeSeries, DateTime>(
          name: l10n.workers_metrics_cpuTime,
          dataSource: data.timeSeries,
          xValueMapper: (v, _) => DateTime.parse(v.timestamp).toLocal(),
          yValueMapper: (v, _) => v.cpuTimeMax,
          color: Colors.orange,
        ),
      ],
    );
  }
}
