import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dns/providers/zone_provider.dart';
import '../../../dns/presentation/widgets/charts/analytics_bar_chart.dart';
import '../../../dns/presentation/widgets/charts/analytics_doughnut_chart.dart';
import '../../providers/web_analytics_provider.dart';
import '../widgets/shared_analytics_time_range_selector.dart';
import '../widgets/web_analytics_charts.dart';
import '../widgets/country_traffic_list.dart';
import '../widgets/geographic_heat_map.dart';
import '../../../../core/widgets/error_view.dart';

class WebAnalyticsPage extends ConsumerWidget {
  const WebAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final webAnalyticsAsync = ref.watch(webAnalyticsNotifierProvider);

    if (selectedZone == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.domain, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.analytics_selectZone),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(webAnalyticsNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SharedAnalyticsTimeRangeSelector()),
            webAnalyticsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: CloudflareErrorView(
                  error: error,
                  onRetry: () => ref
                      .read(webAnalyticsNotifierProvider.notifier)
                      .refresh(),
                ),
              ),
              data: (data) {
                if (data == null) {
                  return SliverFillRemaining(
                    child: Center(child: Text(l10n.common_noData)),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildOverviewCards(context, data, l10n),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: WebTimeSeriesChart(
                          title: l10n.analytics_requests,
                          timeSeries: data.timeSeries,
                          valueMapper: (ts) => ts.requests,
                          unit: 'requests',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: WebTimeSeriesChart(
                          title: l10n.analytics_bandwidth,
                          timeSeries: data.timeSeries,
                          valueMapper: (ts) => ts.bytes,
                          unit: 'bytes',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGridCharts(context, data, l10n),
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

  Widget _buildOverviewCards(
    BuildContext context,
    var data,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: l10n.analytics_requests,
            value: _formatNumber(data.totalRequests),
            icon: Icons.swap_vert,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: l10n.analytics_bandwidth,
            value: _formatBytes(data.totalBytes),
            icon: Icons.speed,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: l10n.analytics_uniqueVisitors,
            value: _formatNumber(data.totalVisits),
            icon: Icons.people,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildGridCharts(
    BuildContext context,
    var data,
    AppLocalizations l10n,
  ) {
    final isWide = MediaQuery.of(context).size.width > 600;

    final charts = [
      AnalyticsDoughnutChart(
        title: l10n.analytics_requestsByStatus,
        groups: data.byStatus,
        dimensionKey: 'edgeResponseStatus',
      ),
      CountryTrafficList(
        title: l10n.analytics_requestsByCountry,
        groups: data.byCountry,
      ),
      GeographicHeatMap(
        title: l10n.analytics_geographicDistribution,
        groups: data.byCountry,
      ),
      AnalyticsBarChart(
        title: l10n.analytics_requestsByProtocol,
        groups: data.byContentType,
        dimensionKey: 'clientRequestHTTPProtocol',
        horizontal: true,
      ),
      AnalyticsDoughnutChart(
        title: l10n.analytics_requestsByHost,
        groups: data.byBrowser,
        dimensionKey: 'clientRequestHTTPHost',
      ),
      AnalyticsBarChart(
        title: l10n.analytics_topPaths,
        groups: data.byPath,
        dimensionKey: 'clientRequestPath',
        horizontal: true,
      ),
    ];

    if (isWide) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: charts,
      );
    } else {
      return Column(
        children: charts
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(height: 300, child: c),
              ),
            )
            .toList(),
      );
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
