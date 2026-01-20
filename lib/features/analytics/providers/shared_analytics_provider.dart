import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'analytics_provider.dart';

part 'shared_analytics_provider.g.dart';

@riverpod
class SharedAnalyticsTimeRange extends _$SharedAnalyticsTimeRange {
  @override
  AnalyticsTimeRange build() => AnalyticsTimeRange.hours24;

  void setTimeRange(AnalyticsTimeRange range) {
    state = range;
  }
}
