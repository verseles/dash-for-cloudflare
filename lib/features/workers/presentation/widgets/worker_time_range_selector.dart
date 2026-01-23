import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cf/features/analytics/providers/analytics_provider.dart';
import 'package:cf/features/workers/providers/shared_workers_provider.dart';

class WorkerTimeRangeSelector extends ConsumerWidget {
  const WorkerTimeRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTimeRange = ref.watch(sharedWorkersTimeRangeProvider);

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
                          .read(sharedWorkersTimeRangeProvider.notifier)
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
