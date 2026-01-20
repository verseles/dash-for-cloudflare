import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/shared_analytics_provider.dart';

class SharedAnalyticsTimeRangeSelector extends ConsumerWidget {
  const SharedAnalyticsTimeRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTimeRange = ref.watch(sharedAnalyticsTimeRangeProvider);

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
                  selected: currentTimeRange == range,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(sharedAnalyticsTimeRangeProvider.notifier)
                          .setTimeRange(range);
                    }
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
