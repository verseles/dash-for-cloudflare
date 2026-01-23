import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/analytics.dart';
import '../../../dns/providers/zone_provider.dart';
import '../../../dns/presentation/widgets/charts/charts.dart';
import '../../providers/security_analytics_provider.dart';
import '../widgets/shared_analytics_time_range_selector.dart';
import '../widgets/web_analytics_charts.dart';
import '../widgets/country_traffic_list.dart';
import '../widgets/geographic_heat_map.dart';
import '../../../../core/widgets/error_view.dart';

class SecurityAnalyticsPage extends ConsumerWidget {
  const SecurityAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final securityAsync = ref.watch(securityAnalyticsNotifierProvider);

    if (selectedZone == null) {
      return Center(child: Text(l10n.analytics_selectZone));
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
              error: (error, stack) => SliverFillRemaining(
                child: CloudflareErrorView(
                  error: error,
                  onRetry: () => ref
                      .read(securityAnalyticsNotifierProvider.notifier)
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
                      _buildSummary(context, data.totalThreats, l10n),
                      const SizedBox(height: 16),
                      // Reuse WebTimeSeriesChart by adapting SecurityTimeSeries to WebTimeSeries (internally)
                      // or just mapping manually.
                      // Since WebTimeSeriesChart expects WebTimeSeries, I'll use a more generic chart if possible or map.
                      SizedBox(
                        height: 300,
                        child: WebTimeSeriesChart(
                          title: l10n.analytics_threatsStopped,
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

  Widget _buildSummary(BuildContext context, int total, AppLocalizations l10n) {
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.analytics_totalThreatsBlocked,
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

  Widget _buildGridCharts(
    BuildContext context,
    SecurityAnalyticsData data,
    AppLocalizations l10n,
  ) {
    final isWide = MediaQuery.of(context).size.width > 600;

    final charts = [
      AnalyticsBarChart(
        title: l10n.analytics_actionsTaken,
        groups: data.byAction,
        dimensionKey: 'action',
      ),
      CountryTrafficList(
        title: l10n.analytics_threatsByCountry,
        groups: data.byCountry,
      ),
      AnalyticsDoughnutChart(
        title: l10n.analytics_topThreatSources,
        groups: data.bySource,
        dimensionKey: 'source',
      ),
      GeographicHeatMap(
        title: l10n.analytics_threatOrigins,
        groups: data.byCountry,
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
