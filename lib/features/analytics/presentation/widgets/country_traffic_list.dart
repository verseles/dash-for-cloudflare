import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/providers/country_provider.dart';
import '../../domain/models/analytics.dart';

/// Widget that displays country traffic distribution with flags and progress bars
class CountryTrafficList extends ConsumerWidget {
  const CountryTrafficList({
    super.key,
    required this.title,
    required this.groups,
    this.maxItems = 10,
  });

  final String title;
  final List<AnalyticsGroup> groups;
  final int maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state to rebuild when countries load from CDN
    final countries = ref.watch(countryNotifierProvider).valueOrNull ?? {};
    final theme = Theme.of(context);

    if (groups.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort by count descending and take top items
    final sortedGroups = List<AnalyticsGroup>.from(groups)
      ..sort((a, b) => b.count.compareTo(a.count));
    final topGroups = sortedGroups.take(maxItems).toList();

    // Calculate total for percentage
    final totalCount = topGroups.fold<int>(0, (sum, g) => sum + g.count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: topGroups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final group = topGroups[index];
                  final code = _getCountryCode(group);
                  final lowerCode = code.toLowerCase();
                  final name = countries[lowerCode] ?? code;
                  final percentage = totalCount > 0
                      ? group.count / totalCount
                      : 0.0;

                  return _CountryListItem(
                    code: code,
                    name: name,
                    count: group.count,
                    percentage: percentage,
                    flagUrl: 'https://flagcdn.com/$lowerCode.svg',
                    color: _getColorForIndex(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCountryCode(AnalyticsGroup group) {
    // Try different possible dimension keys
    return group.dimensions['clientCountryName'] as String? ??
        group.dimensions['clientCountryAlpha2'] as String? ??
        group.dimensions['clientCountry'] as String? ??
        'XX';
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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

class _CountryListItem extends StatelessWidget {
  const _CountryListItem({
    required this.code,
    required this.name,
    required this.count,
    required this.percentage,
    required this.flagUrl,
    required this.color,
  });

  final String code;
  final String name;
  final int count;
  final double percentage;
  final String flagUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Flag
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: 24,
                height: 16,
                child: SvgPicture.network(
                  flagUrl,
                  fit: BoxFit.cover,
                  placeholderBuilder: (_) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.flag, size: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Country name
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Count
            Text(
              _formatNumber(count),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            // Percentage
            Text(
              '(${(percentage * 100).toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
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
