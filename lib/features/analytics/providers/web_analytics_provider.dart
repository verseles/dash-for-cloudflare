import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/analytics.dart';
import '../../dns/providers/zone_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import 'shared_analytics_provider.dart';

part 'web_analytics_provider.g.dart';

@riverpod
class WebAnalyticsNotifier extends _$WebAnalyticsNotifier {
  @override
  FutureOr<WebAnalyticsData?> build() async {
    final zoneId = ref.watch(selectedZoneIdProvider);
    final timeRange = ref.watch(sharedAnalyticsTimeRangeProvider);

    if (zoneId == null) return null;

    // Debounce/Delay to avoid multiple requests during rapid changes
    await Future.delayed(const Duration(milliseconds: 300));

    final graphql = ref.read(cloudflareGraphQLProvider);
    final now = DateTime.now();
    final since = now.subtract(timeRange.duration);

    try {
      log.stateChange(
        'WebAnalyticsNotifier',
        'Fetching web analytics for $zoneId',
      );
      return await graphql.fetchWebAnalytics(
        zoneId: zoneId,
        since: since,
        until: now,
      );
    } catch (e, stack) {
      log.error(
        'WebAnalyticsNotifier: Failed to fetch',
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
