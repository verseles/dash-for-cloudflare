import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../analytics/providers/analytics_provider.dart';

part 'shared_workers_provider.g.dart';

@riverpod
class SharedWorkersTimeRange extends _$SharedWorkersTimeRange {
  @override
  AnalyticsTimeRange build() => AnalyticsTimeRange.hours24;

  void setTimeRange(AnalyticsTimeRange range) {
    state = range;
  }
}
