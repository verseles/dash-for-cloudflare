import 'dart:convert';
import 'dart:io';

import 'package:cf/core/api/client/cloudflare_api.dart';
import 'package:cf/core/api/models/cloudflare_response.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/dns/domain/models/dns_settings.dart';
import 'package:cf/features/dns/providers/dns_settings_provider.dart';
import 'package:cf/features/dns/providers/zone_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCloudflareApi extends Mock implements CloudflareApi {}

void main() {
  late MockCloudflareApi mockApi;
  late ProviderContainer container;

  const zoneId = 'zone_id_YmFjay5pcw==';

  // Load fixtures
  final settingsJson = jsonDecode(File('test/fixtures/dns/settings.json').readAsStringSync());

  setUp(() {
    mockApi = MockCloudflareApi();

    // Mock successful responses
    when(() => mockApi.getDnssec(any())).thenAnswer((_) async => const CloudflareResponse<DnssecDetails>(
      result: DnssecDetails(status: 'active', ds: 'ds_record_dummy'),
      success: true,
      errors: [],
      messages: [],
    ));

    when(() => mockApi.getDnsZoneSettings(any())).thenAnswer((_) async => const CloudflareResponse<DnsZoneSettings>(
      result: DnsZoneSettings(multiProvider: false),
      success: true,
      errors: [],
      messages: [],
    ));

    // Convert fixture to List<DnsSetting>
    final zoneSettings = (settingsJson['result'] as List)
        .map((s) => DnsSetting(
              id: s['id'],
              value: s['value'],
              editable: s['editable'],
              modifiedOn: s['modified_on'],
            ))
        .toList();

    when(() => mockApi.getSettings(any())).thenAnswer((_) async => CloudflareResponse<List<DnsSetting>>(
      result: zoneSettings,
      success: true,
      errors: [],
      messages: [],
    ));

    // Mock write methods with default success
    when(() => mockApi.updateSetting(any(), any(), any()))
        .thenAnswer((_) async => const CloudflareResponse<DnsSetting>(
              result: DnsSetting(id: 'dummy', value: 'dummy'),
              success: true,
              errors: [],
              messages: [],
            ));

    when(() => mockApi.updateDnsZoneSettings(any(), any()))
        .thenAnswer((_) async => const CloudflareResponse<DnsZoneSettings>(
              result: DnsZoneSettings(multiProvider: true),
              success: true,
              errors: [],
              messages: [],
            ));

    container = ProviderContainer(
      overrides: [
        cloudflareApiProvider.overrideWithValue(mockApi),
        selectedZoneIdProvider.overrideWith((ref) => zoneId),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DnsSettingsNotifier', () {
    test('initial state should fetch and hold settings correctly', () async {
      // The provider is auto-disposed, so we need to listen to it
      container.listen(dnsSettingsNotifierProvider, (previous, next) {});
      
      // Wait for the future to complete
      await container.read(dnsSettingsNotifierProvider.future);
      
      final state = container.read(dnsSettingsNotifierProvider).value;

      expect(state, isNotNull);
      expect(state!.dnssec?.status, 'active');
      expect(state.dnsSettings?.multiProvider, isFalse);
      expect(state.zoneSettings.length, greaterThan(0));
      
      // Check specific setting from fixture (CNAME Flattening)
      expect(state.cnameFlattening, 'flatten_at_root');
      
      verify(() => mockApi.getDnssec(zoneId)).called(1);
      verify(() => mockApi.getSettings(zoneId)).called(1);
    });

    test('toggleCnameFlattening should call API and refresh', () async {
      // Ensure initialized
      await container.read(dnsSettingsNotifierProvider.future);

      when(() => mockApi.updateSetting(any(), any(), any()))
          .thenAnswer((_) async => const CloudflareResponse<DnsSetting>(
                result: DnsSetting(id: 'cname_flattening', value: 'flatten_all'),
                success: true,
                errors: [],
                messages: [],
              ));

      await container.read(dnsSettingsNotifierProvider.notifier).toggleCnameFlattening(value: 'flatten_all');

      verify(() => mockApi.updateSetting(zoneId, 'cname_flattening', {'value': 'flatten_all'})).called(1);
      verify(() => mockApi.getSettings(zoneId)).called(2);
    });

    test('toggleMultiProvider should update state and refresh', () async {
      // Ensure initialized
      await container.read(dnsSettingsNotifierProvider.future);

      when(() => mockApi.updateDnsZoneSettings(any(), any()))
          .thenAnswer((_) async => const CloudflareResponse<DnsZoneSettings>(
                result: DnsZoneSettings(multiProvider: true),
                success: true,
                errors: [],
                messages: [],
              ));

      await container.read(dnsSettingsNotifierProvider.notifier).toggleMultiProvider(enable: true);

      verify(() => mockApi.updateDnsZoneSettings(zoneId, {'multi_provider': true})).called(1);
      verify(() => mockApi.getDnsZoneSettings(zoneId)).called(2);
    });
  });
}