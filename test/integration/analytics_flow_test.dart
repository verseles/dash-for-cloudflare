import 'dart:convert';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/auth/providers/settings_provider.dart';
import 'package:cf/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fixtures/fixture_reader.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorage();
    when(() => mockSecureStorage.read(key: 'cloudflare_api_token'))
        .thenAnswer((_) async => 'a' * 45);
  });

  testWidgets('Analytics Dashboard Full Flow Integration Test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final dio = Dio(BaseOptions(baseUrl: 'https://api.cloudflare.com/client/v4'));
    final dioAdapter = DioAdapter(dio: dio);

    // 1. Mock Data
    dioAdapter.onGet('/zones', (server) => server.reply(200, jsonDecode(fixture('dns/zones.json'))));
    dioAdapter.onPost('/graphql', (server) => server.reply(200, jsonDecode(fixture('analytics/analytics_data.json'))), data: Matchers.any);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          secureStorageProvider.overrideWithValue(mockSecureStorage),
        ],
        child: const DashForCloudflareApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // 2. Open Drawer
    await tester.dragFrom(Offset.zero, const Offset(300, 0));
    await tester.pumpAndSettle();

    // 3. Navigate to Analytics Dashboard from Drawer
    // Assuming the Drawer has an item with "Analytics" label
    await tester.tap(find.text('Analytics').last);
    await tester.pumpAndSettle();

    // 4. Select a Zone in Analytics (if not already selected)
    // AnalyticsPage shows a zone selector if none is selected
    if (find.text('Select a zone').evaluate().isNotEmpty) {
      await tester.tap(find.text('back.is'));
      await tester.pumpAndSettle();
    }

    // 5. Verify Web Analytics is shown
    expect(find.text('Web'), findsOneWidget);
    
    // Check if stats cards are rendered (requires data from mock)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    
    expect(find.text('Requests'), findsWidgets);

    // 6. Switch Tabs (Security)
    final navBarFinder = find.descendant(
      of: find.byType(Scaffold),
      matching: find.byType(NavigationBar),
    );
    
    if (navBarFinder.evaluate().isNotEmpty) {
      final navBar = tester.widget<NavigationBar>(navBarFinder);
      navBar.onDestinationSelected!(1); // Index 1 is Security
    }
    
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    
    expect(find.text('Security'), findsOneWidget);

    // Final cleanup
    await tester.pump(const Duration(seconds: 5));
  });
}