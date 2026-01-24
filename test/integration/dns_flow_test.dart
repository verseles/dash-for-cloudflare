import 'dart:convert';
import 'dart:io';

import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/auth/providers/settings_provider.dart';
import 'package:cf/features/dns/presentation/pages/dns_records_page.dart';
import 'package:cf/features/dns/presentation/widgets/dns_record_item.dart';
import 'package:cf/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Load fixtures
  final zonesJson = jsonDecode(File('test/fixtures/dns/zones.json').readAsStringSync());
  final recordsJson = jsonDecode(File('test/fixtures/dns/dns_records.json').readAsStringSync());
  final settingsJson = jsonDecode(File('test/fixtures/dns/settings.json').readAsStringSync());

  setUpAll(() {
    HttpOverrides.global = null;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'light',
      'locale': 'en',
    });
  });

  testWidgets('DNS Flow Integration Test', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    final dio = Dio(BaseOptions(baseUrl: 'https://api.cloudflare.com/client/v4'));
    final dioAdapter = DioAdapter(dio: dio);

    // Mock API calls
    dioAdapter.onGet('/zones', (server) => server.reply(200, zonesJson));
    
    final zoneId = zonesJson['result'][0]['id'];
    dioAdapter.onGet('/zones/$zoneId/dns_records', (server) => server.reply(200, recordsJson));
    dioAdapter.onGet('/zones/$zoneId/dnssec', (server) => server.reply(200, {
      'result': {'status': 'active'},
      'success': true
    }));
    dioAdapter.onGet('/zones/$zoneId/dns_settings', (server) => server.reply(200, {
      'result': {'multi_provider': false},
      'success': true
    }));
    dioAdapter.onGet('/zones/$zoneId/settings', (server) => server.reply(200, settingsJson));

    dioAdapter.onPost(
      RegExp(r'.*graphql.*'),
      (server) => server.reply(200, {'data': {'viewer': {'zones': [{'total': [{'count': 0}]}]}}}),
      data: Matchers.any,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          hasValidTokenProvider.overrideWith((ref) => true),
        ],
        child: const DashForCloudflareApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // 1. Verify zone list
    expect(find.text('back.is'), findsAtLeastNWidgets(1));
    
    // 2. Select zone
    await tester.tap(find.text('back.is').first);
    await tester.pumpAndSettle();

    // 3. Verify DNS records are loaded in the DnsRecordsPage
    expect(find.byType(DnsRecordsPage), findsOneWidget);
    expect(find.textContaining('api'), findsAtLeastNWidgets(1));
    expect(find.byType(DnsRecordItem), findsAtLeastNWidgets(1));

    // Clear all pending timers from background preloading
    await tester.pump(const Duration(seconds: 2));
  });
}