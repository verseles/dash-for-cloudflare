import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/analytics.dart';
import '../../dns/providers/zone_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';

part 'analytics_provider.g.dart';

/// Time range options for analytics
enum AnalyticsTimeRange {
  minutes30(Duration(minutes: 30), '30m'),
  hours6(Duration(hours: 6), '6h'),
  hours12(Duration(hours: 12), '12h'),
  hours24(Duration(hours: 24), '24h'),
  days7(Duration(days: 7), '7d'),
  days30(Duration(days: 30), '30d');

  const AnalyticsTimeRange(this.duration, this.label);

  final Duration duration;
  final String label;
}

/// State for analytics
class AnalyticsState {
  const AnalyticsState({
    this.data,
    this.timeRange = AnalyticsTimeRange.hours24,
    this.selectedQueryNames = const {},
    this.isLoading = false,
    this.error,
  });

  final DnsAnalyticsData? data;
  final AnalyticsTimeRange timeRange;
  final Set<String> selectedQueryNames;
  final bool isLoading;
  final String? error;

  AnalyticsState copyWith({
    DnsAnalyticsData? data,
    AnalyticsTimeRange? timeRange,
    Set<String>? selectedQueryNames,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      data: data ?? this.data,
      timeRange: timeRange ?? this.timeRange,
      selectedQueryNames: selectedQueryNames ?? this.selectedQueryNames,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Analytics notifier
@riverpod
class AnalyticsNotifier extends _$AnalyticsNotifier {
  @override
  AnalyticsState build() {
    // Auto-fetch when zone changes (with delay to let current tab load first)
    ref.listen(selectedZoneIdProvider, (previous, next) {
      if (next != null && next != previous) {
        // Clear old data and show loading
        state = const AnalyticsState(isLoading: true);
        _scheduleFetch();
      }
    });

    // If zone already selected, schedule initial fetch
    final currentZone = ref.read(selectedZoneIdProvider);
    if (currentZone != null) {
      _scheduleFetch();
      return const AnalyticsState(isLoading: true);
    }

    return const AnalyticsState();
  }

  /// Schedule a fetch with delay to avoid blocking current tab
  void _scheduleFetch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      fetchAnalytics();
    });
  }

  /// Fetch analytics data
  Future<void> fetchAnalytics() async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    final currentState = state;
    state = currentState.copyWith(isLoading: true, error: null);
    log.stateChange('AnalyticsNotifier', 'Fetching analytics for ${currentState.timeRange.label}');

    try {
      final graphql = ref.read(cloudflareGraphQLProvider);
      final now = DateTime.now();
      final since = now.subtract(currentState.timeRange.duration);

      final data = await graphql.fetchAnalytics(
        zoneId: zoneId,
        since: since,
        until: now,
        queryNames: currentState.selectedQueryNames.toList(),
      );

      log.stateChange('AnalyticsNotifier', 'Analytics fetched: ${data?.total ?? 0} total queries');
      state = currentState.copyWith(data: data, isLoading: false);
    } catch (e, stack) {
      log.error(
        'AnalyticsNotifier: Failed to fetch analytics',
        error: e,
        stackTrace: stack,
      );
      state = currentState.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Change time range and refetch
  Future<void> setTimeRange(AnalyticsTimeRange range) async {
    state = state.copyWith(timeRange: range);
    await fetchAnalytics();
  }

  /// Toggle query name selection (max 5)
  Future<void> toggleQueryName(String queryName) async {
    final current = state.selectedQueryNames;

    Set<String> updated;
    if (current.contains(queryName)) {
      updated = current.difference({queryName});
    } else {
      if (current.length >= 5) {
        // Max 5 selections
        return;
      }
      updated = {...current, queryName};
    }

    state = state.copyWith(selectedQueryNames: updated);
    await fetchAnalytics();
  }

  /// Clear all query name selections
  Future<void> clearQueryNames() async {
    state = state.copyWith(selectedQueryNames: {});
    await fetchAnalytics();
  }
}
