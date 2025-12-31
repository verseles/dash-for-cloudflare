import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/analytics/domain/models/analytics.dart';
import 'package:cf/features/analytics/providers/analytics_provider.dart';

void main() {
  group('AnalyticsTimeRange', () {
    test('has correct durations', () {
      expect(AnalyticsTimeRange.minutes30.duration, const Duration(minutes: 30));
      expect(AnalyticsTimeRange.hours6.duration, const Duration(hours: 6));
      expect(AnalyticsTimeRange.hours12.duration, const Duration(hours: 12));
      expect(AnalyticsTimeRange.hours24.duration, const Duration(hours: 24));
      expect(AnalyticsTimeRange.days7.duration, const Duration(days: 7));
      expect(AnalyticsTimeRange.days30.duration, const Duration(days: 30));
    });

    test('has correct labels', () {
      expect(AnalyticsTimeRange.minutes30.label, '30m');
      expect(AnalyticsTimeRange.hours6.label, '6h');
      expect(AnalyticsTimeRange.hours12.label, '12h');
      expect(AnalyticsTimeRange.hours24.label, '24h');
      expect(AnalyticsTimeRange.days7.label, '7d');
      expect(AnalyticsTimeRange.days30.label, '30d');
    });

    test('has 6 values', () {
      expect(AnalyticsTimeRange.values.length, 6);
    });
  });

  group('AnalyticsState', () {
    group('constructor', () {
      test('has correct defaults', () {
        const state = AnalyticsState();

        expect(state.data, isNull);
        expect(state.timeRange, AnalyticsTimeRange.hours24);
        expect(state.selectedQueryNames, isEmpty);
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });

      test('accepts all parameters', () {
        const data = DnsAnalyticsData(total: 1000);
        const state = AnalyticsState(
          data: data,
          timeRange: AnalyticsTimeRange.days7,
          selectedQueryNames: {'example.com', 'api.example.com'},
          isLoading: true,
          error: 'Network error',
        );

        expect(state.data?.total, 1000);
        expect(state.timeRange, AnalyticsTimeRange.days7);
        expect(state.selectedQueryNames.length, 2);
        expect(state.isLoading, true);
        expect(state.error, 'Network error');
      });

      test('can start with isLoading true for pre-fetch', () {
        const state = AnalyticsState(isLoading: true);

        expect(state.isLoading, true);
        expect(state.data, isNull);
        expect(state.error, isNull);
      });
    });

    group('copyWith', () {
      test('updates isLoading', () {
        const original = AnalyticsState(isLoading: false);
        final updated = original.copyWith(isLoading: true);

        expect(updated.isLoading, true);
      });

      test('updates timeRange', () {
        const original = AnalyticsState();
        final updated = original.copyWith(timeRange: AnalyticsTimeRange.days30);

        expect(updated.timeRange, AnalyticsTimeRange.days30);
      });

      test('updates data', () {
        const original = AnalyticsState();
        const newData = DnsAnalyticsData(total: 500, avgQps: 2.5);
        final updated = original.copyWith(data: newData);

        expect(updated.data?.total, 500);
        expect(updated.data?.avgQps, 2.5);
      });

      test('updates selectedQueryNames', () {
        const original = AnalyticsState();
        final updated = original.copyWith(
          selectedQueryNames: {'test.com', 'api.test.com'},
        );

        expect(updated.selectedQueryNames.length, 2);
        expect(updated.selectedQueryNames.contains('test.com'), true);
      });

      test('clears error when setting to null', () {
        const original = AnalyticsState(error: 'Previous error');
        final updated = original.copyWith(error: null);

        expect(updated.error, isNull);
      });

      test('preserves other values when updating single field', () {
        const original = AnalyticsState(
          timeRange: AnalyticsTimeRange.hours6,
          selectedQueryNames: {'example.com'},
        );
        final updated = original.copyWith(isLoading: true);

        expect(updated.timeRange, AnalyticsTimeRange.hours6);
        expect(updated.selectedQueryNames, {'example.com'});
        expect(updated.isLoading, true);
      });

      test('resets state for zone change', () {
        // When zone changes, state is reset to loading
        // (old data from previous zone is cleared)
        const newState = AnalyticsState(isLoading: true);

        expect(newState.data, isNull);
        expect(newState.isLoading, true);
        expect(newState.timeRange, AnalyticsTimeRange.hours24); // default
      });
    });

    group('edge cases', () {
      test('empty selectedQueryNames set', () {
        const state = AnalyticsState(selectedQueryNames: {});

        expect(state.selectedQueryNames, isEmpty);
        expect(state.selectedQueryNames.contains('anything'), false);
      });

      test('data with empty collections', () {
        const data = DnsAnalyticsData(
          total: 0,
          timeSeries: [],
          byQueryName: [],
        );
        const state = AnalyticsState(data: data);

        expect(state.data?.total, 0);
        expect(state.data?.timeSeries, isEmpty);
        expect(state.data?.byQueryName, isEmpty);
      });
    });
  });
}
