import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cf/main.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/core/router/app_router.dart';
import 'package:cf/features/auth/providers/settings_provider.dart';
import 'package:cf/features/auth/providers/account_provider.dart';
import 'package:cf/features/auth/models/app_settings.dart';
import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    dynamic responseData;
    if (options.path.contains('/pages/projects')) {
      responseData = {
        'result': [
          {
            'id': 'p1',
            'name': 'Fresh Project',
            'subdomain': 'fresh.pages.dev',
            'created_on': '2024-01-01T00:00:00Z',
          }
        ],
        'success': true,
        'result_info': {'total_pages': 1}
      };
    } else if (options.path.contains('/zones')) {
      responseData = {'result': [], 'success': true};
    } else if (options.path.contains('/accounts')) {
      responseData = {
        'result': [{'id': 'test-account', 'name': 'Test Account'}],
        'success': true,
      };
    }

    if (responseData != null) {
      handler.resolve(Response(
        requestOptions: options,
        data: responseData,
        statusCode: 200,
      ));
    } else {
      handler.next(options);
    }
  }
}

class FakeSettingsNotifier extends SettingsNotifier {
  @override
  FutureOr<AppSettings> build() {
    return const AppSettings(
      cloudflareApiToken: 'fake-token-with-more-than-40-characters-1234567890',
      themeMode: ThemeMode.system,
      locale: 'en',
      lastVisitedRoute: '/pages',
    );
  }
}

void main() {
  testWidgets('Integration: Pages SWR flow - Cache then Fresh Data', (tester) async {
    // Arrange: Setup mock cache
    final oldProject = {
      'id': 'p1',
      'name': 'Stale Cached Project',
      'subdomain': 'stale.pages.dev',
      'created_on': '2023-01-01T00:00:00Z',
    };
    
    SharedPreferences.setMockInitialValues({
      'pages_projects_cache_test-account': json.encode([oldProject]),
      'pages_projects_cache_time_test-account': DateTime.now().toIso8601String(),
    });

    final dio = Dio();
    dio.interceptors.add(MockInterceptor());

    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(dio),
        selectedAccountIdProvider.overrideWith((ref) => 'test-account'),
        settingsNotifierProvider.overrideWith(() => FakeSettingsNotifier()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DashForCloudflareApp(),
      ),
    );

    // Force navigation to /pages
    container.read(appRouterProvider).go('/pages');
    await tester.pump(); // Start navigation
    await tester.pump(const Duration(milliseconds: 100)); // Process cache loading

    // Assert 1: Should show stale data from cache immediately
    expect(find.text('Stale Cached Project'), findsOneWidget);
    
    // Act: Wait for background refresh to finish
    bool foundFresh = false;
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('Fresh Project').evaluate().isNotEmpty) {
        foundFresh = true;
        break;
      }
    }

    // Assert 2: Should update to fresh data from API
    expect(foundFresh, isTrue, reason: 'Fresh Project should appear after background refresh');
    expect(find.text('Stale Cached Project'), findsNothing);
  });
}