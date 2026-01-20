import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/analytics.dart';
import '../../dns/providers/zone_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import 'shared_analytics_provider.dart';

part 'security_analytics_provider.g.dart';

@riverpod
class SecurityAnalyticsNotifier extends _$SecurityAnalyticsNotifier {
  @override
  FutureOr<SecurityAnalyticsData?> build() async {
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
        'SecurityAnalyticsNotifier',
        'Fetching security analytics for $zoneId',
      );
      return await graphql.fetchSecurityAnalytics(
        zoneId: zoneId,
        since: since,
        until: now,
      );
    } catch (e, stack) {
      final errorStr = e.toString();
      if (errorStr.contains('does not have access to the path') ||
          errorStr.contains('access control')) {
        log.warning(
          'SecurityAnalyticsNotifier: Access denied (Plan upgrade required)',
        );
        // We return a specific "empty" state or throw a specific error that UI can catch
        throw Exception('UPGRADE_REQUIRED');
      }

      log.error(
        'SecurityAnalyticsNotifier: Failed to fetch',
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
