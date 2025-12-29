import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../analytics/providers/analytics_provider.dart';
import '../../providers/zone_provider.dart';
import '../widgets/charts/charts.dart';

/// DNS Analytics page with Syncfusion charts
class DnsAnalyticsPage extends ConsumerWidget {
  const DnsAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final analyticsState = ref.watch(analyticsNotifierProvider);

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
            ref.read(analyticsNotifierProvider.notifier).fetchAnalytics(),
        child: CustomScrollView(
          slivers: [
            // Time range selector
            SliverToBoxAdapter(
              child: _buildTimeRangeSelector(context, ref, analyticsState),
            ),

            // Analytics content
            if (analyticsState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (analyticsState.error != null)
              SliverFillRemaining(
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
                      Text('Error: ${analyticsState.error}'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: () => ref
                            .read(analyticsNotifierProvider.notifier)
                            .fetchAnalytics(),
                      ),
                    ],
                  ),
                ),
              )
            else if (analyticsState.data == null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text('No analytics data'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Load Analytics'),
                        onPressed: () => ref
                            .read(analyticsNotifierProvider.notifier)
                            .fetchAnalytics(),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Overview card
                    _buildOverviewCard(context, ref, analyticsState),
                    const SizedBox(height: 16),

                    // Stats row
                    _buildStatsRow(context, analyticsState),
                    const SizedBox(height: 16),

                    // Time series chart (full width)
                    SizedBox(
                      height: 300,
                      child: AnalyticsTimeSeriesChart(
                        title: 'Queries Over Time',
                        timeSeries: analyticsState.data!.timeSeries,
                        byQueryNameTimeSeries:
                            analyticsState.selectedQueryNames.isNotEmpty
                            ? analyticsState.data!.byQueryNameTimeSeries
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Charts grid
                    _buildChartsGrid(context, analyticsState),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(
    BuildContext context,
    WidgetRef ref,
    AnalyticsState state,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: AnalyticsTimeRange.values
            .map(
              (range) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(range.label),
                  selected: state.timeRange == range,
                  onSelected: (_) {
                    ref
                        .read(analyticsNotifierProvider.notifier)
                        .setTimeRange(range);
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    WidgetRef ref,
    AnalyticsState state,
  ) {
    final data = state.data!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Total Queries',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  _formatNumber(data.total),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Top Query Names',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.byQueryName.take(5).map((group) {
                final name =
                    group.dimensions['queryName'] as String? ?? 'Unknown';
                final isSelected = state.selectedQueryNames.contains(name);

                return ActionChip(
                  label: Text('$name (${_formatNumber(group.count)})'),
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  onPressed: () {
                    ref
                        .read(analyticsNotifierProvider.notifier)
                        .toggleQueryName(name);
                  },
                );
              }).toList(),
            ),
            if (state.selectedQueryNames.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear selection'),
                onPressed: () {
                  ref
                      .read(analyticsNotifierProvider.notifier)
                      .clearQueryNames();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AnalyticsState state) {
    final data = state.data!;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    _formatNumber(data.total),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Query Types',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.byQueryType.length}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Centers',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.byDataCenter.length}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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

  Widget _buildChartsGrid(BuildContext context, AnalyticsState state) {
    final data = state.data!;
    final isWide = MediaQuery.of(context).size.width > 600;

    final charts = [
      AnalyticsDoughnutChart(
        title: 'Queries by Data Center',
        groups: data.byDataCenter,
        dimensionKey: 'coloCode',
      ),
      AnalyticsBarChart(
        title: 'Queries by Record Type',
        groups: data.byQueryType,
        dimensionKey: 'queryType',
      ),
      AnalyticsDoughnutChart(
        title: 'Queries by Response Code',
        groups: data.byResponseCode,
        dimensionKey: 'responseCode',
      ),
      AnalyticsDoughnutChart(
        title: 'Queries by IP Version',
        groups: data.byIpVersion,
        dimensionKey: 'ipVersion',
      ),
      AnalyticsDoughnutChart(
        title: 'Queries by Protocol',
        groups: data.byProtocol,
        dimensionKey: 'protocol',
      ),
      AnalyticsBarChart(
        title: 'Top Query Names',
        groups: data.byQueryName,
        dimensionKey: 'queryName',
        horizontal: true,
        maxItems: 8,
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
        children: charts
            .map((chart) => SizedBox(height: 300, child: chart))
            .toList(),
      );
    } else {
      return Column(
        children: charts
            .map(
              (chart) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(height: 300, child: chart),
              ),
            )
            .toList(),
      );
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
