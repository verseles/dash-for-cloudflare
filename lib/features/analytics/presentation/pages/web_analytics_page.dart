import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dns/providers/zone_provider.dart';
import '../../../dns/presentation/widgets/charts/charts.dart';
import '../../providers/web_analytics_provider.dart';
import '../widgets/shared_analytics_time_range_selector.dart';
import '../widgets/web_analytics_charts.dart';

class WebAnalyticsPage extends ConsumerWidget {
  const WebAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final webAnalyticsAsync = ref.watch(webAnalyticsNotifierProvider);

    if (selectedZone == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.domain, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Select a zone to view analytics'),
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: () => ref
                            .read(webAnalyticsNotifierProvider.notifier)
                            .refresh(),
                      ),
                    ],
                  ),
                ),
              ),
              data: (data) {
                if (data == null) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No data available')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildOverviewCards(context, data),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: WebTimeSeriesChart(
                          title: 'Requests',
                          timeSeries: data.timeSeries,
                          valueMapper: (ts) => ts.requests,
                          unit: 'requests',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: WebTimeSeriesChart(
                          title: 'Bandwidth',
                          timeSeries: data.timeSeries,
                          valueMapper: (ts) => ts.bytes,
                          unit: 'bytes',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGridCharts(context, data),
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

  Widget _buildOverviewCards(BuildContext context, var data) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Requests',
            value: _formatNumber(data.totalRequests),
            icon: Icons.swap_vert,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Bandwidth',
            value: _formatBytes(data.totalBytes),
            icon: Icons.speed,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Unique Visitors',
            value: _formatNumber(data.totalVisits),
            icon: Icons.people,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildGridCharts(BuildContext context, var data) {
    final isWide = MediaQuery.of(context).size.width > 600;

    final charts = [
      AnalyticsDoughnutChart(
        title: 'Requests by Status',
        groups: data.byStatus,
        dimensionKey: 'edgeResponseStatus',
      ),
      AnalyticsMapChart(title: 'Requests by Country', groups: data.byCountry),
      AnalyticsBarChart(
        title: 'Requests by Protocol',
        groups: data.byContentType,
        dimensionKey: 'clientRequestHTTPProtocol',
        horizontal: true,
      ),
      AnalyticsDoughnutChart(
        title: 'Requests by Host',
        groups: data.byBrowser,
        dimensionKey: 'clientRequestHTTPHost',
      ),
      AnalyticsBarChart(
        title: 'Top Paths',
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
