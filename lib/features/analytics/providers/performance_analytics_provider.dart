import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/analytics.dart';
import '../../dns/providers/zone_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import 'shared_analytics_provider.dart';

part 'performance_analytics_provider.g.dart';

@riverpod
class PerformanceAnalyticsNotifier extends _$PerformanceAnalyticsNotifier {
  @override
  FutureOr<PerformanceAnalyticsData?> build() async {
    final zoneId = ref.watch(selectedZoneIdProvider);
    final timeRange = ref.watch(sharedAnalyticsTimeRangeProvider);

    if (zoneId == null) return null;

    // Debounce
    await Future.delayed(const Duration(milliseconds: 300));

    final graphql = ref.read(cloudflareGraphQLProvider);
    final now = DateTime.now();
    final since = now.subtract(timeRange.duration);

    try {
      log.stateChange(
        'PerformanceAnalyticsNotifier',
        'Fetching performance analytics for $zoneId',
      );
      return await graphql.fetchPerformanceAnalytics(
        zoneId: zoneId,
        since: since,
        until: now,
      );
    } catch (e, stack) {
      log.error(
        'PerformanceAnalyticsNotifier: Failed to fetch',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
