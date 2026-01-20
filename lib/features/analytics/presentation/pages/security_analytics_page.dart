import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/analytics.dart';
import '../../../dns/providers/zone_provider.dart';
import '../../../dns/presentation/widgets/charts/charts.dart';
import '../../providers/security_analytics_provider.dart';
import '../widgets/shared_analytics_time_range_selector.dart';
import '../widgets/web_analytics_charts.dart';

class SecurityAnalyticsPage extends ConsumerWidget {
  const SecurityAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final securityAsync = ref.watch(securityAnalyticsNotifierProvider);

    if (selectedZone == null) {
      return const Center(child: Text('Select a zone to view analytics'));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(securityAnalyticsNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SharedAnalyticsTimeRangeSelector()),
            securityAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) {
                final errorStr = error.toString();
                final isRestricted =
                    errorStr.contains('UPGRADE_REQUIRED') ||
                    errorStr.contains('not available') ||
                    errorStr.contains('permission') ||
                    errorStr.contains('access to the path');

                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isRestricted
                                ? Icons.lock_outline
                                : Icons.error_outline,
                            size: 64,
                            color: isRestricted ? Colors.orange : Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isRestricted
                                ? 'Security Analytics requires a paid Cloudflare plan (Pro or higher).'
                                : 'Error: $error',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (isRestricted) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Firewall events adaptive groups are not available on Free plans.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => ref
                                .read(
                                  securityAnalyticsNotifierProvider.notifier,
                                )
                                .refresh(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
                      _buildSummary(context, data.totalThreats),
                      const SizedBox(height: 16),
                      // Reuse WebTimeSeriesChart by adapting SecurityTimeSeries to WebTimeSeries (internally)
                      // or just mapping manually.
                      // Since WebTimeSeriesChart expects WebTimeSeries, I'll use a more generic chart if possible or map.
                      SizedBox(
                        height: 300,
                        child: WebTimeSeriesChart(
                          title: 'Threats Stopped',
                          timeSeries: data.timeSeries
                              .map(
                                (s) => WebTimeSeries(
                                  timestamp: s.timestamp,
                                  requests: s.threats,
                                ),
                              )
                              .toList(),
                          valueMapper: (ts) => ts.requests,
                          unit: 'threats',
                          color: Colors.red,
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

  Widget _buildSummary(BuildContext context, int total) {
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Total Threats Blocked',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              total.toString(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCharts(BuildContext context, SecurityAnalyticsData data) {
    final isWide = MediaQuery.of(context).size.width > 600;

    final charts = [
      AnalyticsBarChart(
        title: 'Actions Taken',
        groups: data.byAction,
        dimensionKey: 'action',
      ),
      AnalyticsMapChart(title: 'Threats by Country', groups: data.byCountry),
      AnalyticsDoughnutChart(
        title: 'Top Threat Sources',
        groups: data.bySource,
        dimensionKey: 'source',
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
}
