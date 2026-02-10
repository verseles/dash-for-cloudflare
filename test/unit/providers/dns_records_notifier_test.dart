
import 'package:cf/core/api/client/cloudflare_api.dart';
import 'package:cf/core/api/models/cloudflare_response.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/dns/domain/models/dns_record.dart';
import 'package:cf/features/dns/providers/dns_records_provider.dart';
import 'package:cf/features/dns/providers/zone_provider.dart';
import 'package:cf/features/auth/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCloudflareApi extends Mock implements CloudflareApi {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockCloudflareApi mockApi;
  late MockSharedPreferences mockPrefs;
  late ProviderContainer container;

  const zoneId = 'zone1';

  setUp(() {
    mockApi = MockCloudflareApi();
    mockPrefs = MockSharedPreferences();

    container = ProviderContainer(
      overrides: [
        cloudflareApiProvider.overrideWithValue(mockApi),
        sharedPreferencesProvider.overrideWith((ref) async => mockPrefs),
        selectedZoneIdProvider.overrideWith((ref) => zoneId),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DnsRecordsNotifier Pagination Tests', () {
    test('fetches all pages when multiple pages exist', () async {
      // Page 1
      final page1Records = [
        const DnsRecord(id: '1', name: 'rec1', type: 'A', content: '1.1.1.1', zoneId: zoneId),
        const DnsRecord(id: '2', name: 'rec2', type: 'A', content: '2.2.2.2', zoneId: zoneId),
      ];
      final page1Response = CloudflareResponse<List<DnsRecord>>(
        success: true,
        result: page1Records,
        resultInfo: const CloudflareResultInfo(
          page: 1,
          perPage: 2,
          count: 2,
          totalCount: 4,
          totalPages: 2,
        ),
      );

      // Page 2
      final page2Records = [
        const DnsRecord(id: '3', name: 'rec3', type: 'A', content: '3.3.3.3', zoneId: zoneId),
        const DnsRecord(id: '4', name: 'rec4', type: 'A', content: '4.4.4.4', zoneId: zoneId),
      ];
      final page2Response = CloudflareResponse<List<DnsRecord>>(
        success: true,
        result: page2Records,
        resultInfo: const CloudflareResultInfo(
          page: 2,
          perPage: 2,
          count: 2,
          totalCount: 4,
          totalPages: 2,
        ),
      );

      // Mock SharedPreferences (no cache)
      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      // Mock API calls
      when(() => mockApi.getDnsRecords(zoneId, page: 1, perPage: 100))
          .thenAnswer((_) async => page1Response);
      when(() => mockApi.getDnsRecords(zoneId, page: 2, perPage: 100))
          .thenAnswer((_) async => page2Response);

      // Trigger the provider
      final state = await container.read(dnsRecordsNotifierProvider.future);

      // Verify results
      expect(state.records.length, 4);
      expect(state.records.map((r) => r.id), containsAll(['1', '2', '3', '4']));

      // Verify API calls
      verify(() => mockApi.getDnsRecords(zoneId, page: 1, perPage: 100)).called(1);
      verify(() => mockApi.getDnsRecords(zoneId, page: 2, perPage: 100)).called(1);
    });
  });
}
