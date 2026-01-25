import 'package:cf/core/api/client/cloudflare_graphql.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/analytics/domain/models/analytics.dart';
import 'package:cf/features/analytics/providers/analytics_provider.dart';
import 'package:cf/features/dns/providers/zone_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCloudflareGraphQL extends Mock implements CloudflareGraphQL {}

void main() {
  late MockCloudflareGraphQL mockGraphQL;
  late ProviderContainer container;

  const zoneId = 'zone1';

  setUp(() {
    mockGraphQL = MockCloudflareGraphQL();
    
    // Register fallback values for mocktail any() matching if needed
    registerFallbackValue(DateTime.now());

    container = ProviderContainer(
      overrides: [
        cloudflareGraphQLProvider.overrideWithValue(mockGraphQL),
        selectedZoneIdProvider.overrideWith((ref) => zoneId),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AnalyticsNotifier Unit Tests', () {
    test('initial state is loading when zone is selected', () {
      final state = container.read(analyticsNotifierProvider);
      expect(state.isLoading, isTrue);
    });

    test('fetchAnalytics updates state with data', () async {
      const mockData = DnsAnalyticsData(
        total: 1000,
        timeSeries: [],
        byQueryName: [],
        byQueryType: [],
        byResponseCode: [],
        byDataCenter: [],
        byIpVersion: [],
        byProtocol: [],
      );

      when(() => mockGraphQL.fetchAnalytics(
            zoneId: any(named: 'zoneId'),
            since: any(named: 'since'),
            until: any(named: 'until'),
            queryNames: any(named: 'queryNames'),
          )).thenAnswer((_) async => mockData);

      await container.read(analyticsNotifierProvider.notifier).fetchAnalytics();

      final state = container.read(analyticsNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.data, equals(mockData));
      expect(state.data?.total, 1000);
    });

    test('setTimeRange triggers fetch', () async {
      when(() => mockGraphQL.fetchAnalytics(
            zoneId: any(named: 'zoneId'),
            since: any(named: 'since'),
            until: any(named: 'until'),
            queryNames: any(named: 'queryNames'),
          )).thenAnswer((_) async => null);

      await container.read(analyticsNotifierProvider.notifier).setTimeRange(AnalyticsTimeRange.days7);

      final state = container.read(analyticsNotifierProvider);
      expect(state.timeRange, equals(AnalyticsTimeRange.days7));
      verify(() => mockGraphQL.fetchAnalytics(
            zoneId: zoneId,
            since: any(named: 'since'),
            until: any(named: 'until'),
            queryNames: any(named: 'queryNames'),
          )).called(1);
    });
  });
}
