import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dns/providers/zone_provider.dart';
import '../../../dns/presentation/widgets/charts/charts.dart';
import '../../providers/performance_analytics_provider.dart';
import '../widgets/shared_analytics_time_range_selector.dart';
import '../widgets/performance_analytics_charts.dart';
import '../../../../core/widgets/error_view.dart';

class PerformanceAnalyticsPage extends ConsumerWidget {
  const PerformanceAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final performanceAsync = ref.watch(performanceAnalyticsNotifierProvider);

    if (selectedZone == null) {
      return Center(child: Text(l10n.analytics_selectZone));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(performanceAnalyticsNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SharedAnalyticsTimeRangeSelector()),
            performanceAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: CloudflareErrorView(
                  error: error,
                  onRetry: () => ref
                      .read(performanceAnalyticsNotifierProvider.notifier)
                      .refresh(),
                ),
              ),
              data: (data) {
                if (data == null) {
                  return SliverFillRemaining(
                    child: Center(child: Text(l10n.common_noData)),
                  );
                }

                final cacheHitRatio = data.totalRequests > 0
                    ? (data.cachedRequests / data.totalRequests) * 100
                    : 0.0;

                final bandwidthSaved = data.cachedBytes;

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSummary(
                        context,
                        cacheHitRatio,
                        bandwidthSaved,
                        l10n,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: PerformanceTimeSeriesChart(
                          title: l10n.analytics_requestsCacheVsOrigin,
                          timeSeries: data.timeSeries,
                          valueMapper: (ts) => ts.requests,
                          cachedValueMapper: (ts) => ts.cachedRequests,
                          unit: 'requests',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: PerformanceTimeSeriesChart(
                          title: l10n.analytics_bandwidthCacheVsOrigin,
                          timeSeries: data.timeSeries,
                          valueMapper: (ts) => ts.bytes,
                          cachedValueMapper: (ts) => ts.cachedBytes,
                          unit: 'bytes',
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnalyticsDoughnutChart(
                        title: l10n.analytics_cacheStatusByHttpStatus,
                        groups: data.byContentType,
                        dimensionKey: 'edgeResponseStatus',
                      ),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    double ratio,
    int saved,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    l10n.analytics_cacheHitRatio,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ratio.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    l10n.analytics_bandwidthSaved,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatBytes(saved),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }
}
