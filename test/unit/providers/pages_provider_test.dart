import 'dart:async';
import 'dart:convert';
import 'package:cf/core/api/client/cloudflare_api.dart';
import 'package:cf/core/api/models/cloudflare_response.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/auth/providers/account_provider.dart';
import 'package:cf/features/auth/providers/settings_provider.dart';
import 'package:cf/features/pages/domain/models/pages_project.dart';
import 'package:cf/features/pages/providers/pages_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../fixtures/fixture_reader.dart';

class MockCloudflareApi extends Mock implements CloudflareApi {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Mock Notifier
class MockAccountsNotifier extends AccountsNotifier with Mock {
  @override
  FutureOr<AccountsState> build() => const AccountsState();
}

void main() {
  late MockCloudflareApi mockApi;
  late MockSharedPreferences mockPrefs;
  late ProviderContainer container;

  const accountId = 'account1';

  setUp(() {
    mockApi = MockCloudflareApi();
    mockPrefs = MockSharedPreferences();

    container = ProviderContainer(
      overrides: [
        cloudflareApiProvider.overrideWithValue(mockApi),
        sharedPreferencesProvider.overrideWith((ref) async => mockPrefs),
        selectedAccountIdProvider.overrideWith((ref) => accountId),
        accountsNotifierProvider.overrideWith(() => MockAccountsNotifier()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PagesProjectsNotifier Unit Tests', () {
    test('fetches projects from API when no cache exists', () async {
      final projectsJson = jsonDecode(fixture('pages/projects.json'));
      final mockResponse = CloudflareResponse<List<PagesProject>>.fromJson(
        projectsJson,
        (json) => (json as List).map((e) => PagesProject.fromJson(e)).toList(),
      );

      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
      when(() => mockApi.getPagesProjects(accountId, page: any(named: 'page')))
          .thenAnswer((_) async => mockResponse);

      final result = await container.read(pagesProjectsNotifierProvider.future);

      expect(result.projects.length, mockResponse.result?.length);
      expect(result.isFromCache, isFalse);
      verify(() => mockApi.getPagesProjects(accountId, page: 1)).called(1);
    });

    test('loads from cache and refreshes in background', () async {
      final projectsJson = jsonDecode(fixture('pages/projects.json'));
      final cachedProjects = (projectsJson['result'] as List)
          .map((e) => PagesProject.fromJson(e))
          .toList();

      // Setup specific cache keys
      when(() => mockPrefs.getString(any(that: contains('cache_time'))))
          .thenReturn(DateTime.now().toIso8601String());
      when(() => mockPrefs.getString(any(that: contains('cache_account1'))))
          .thenReturn(jsonEncode(projectsJson['result']));
      
      // Mock API for background refresh
      final mockResponse = CloudflareResponse<List<PagesProject>>.fromJson(
        projectsJson,
        (json) => (json as List).map((e) => PagesProject.fromJson(e)).toList(),
      );
      when(() => mockApi.getPagesProjects(accountId, page: any(named: 'page')))
          .thenAnswer((_) async => mockResponse);

      final result = await container.read(pagesProjectsNotifierProvider.future);

      expect(result.projects.length, cachedProjects.length);
      expect(result.isFromCache, isTrue);
      
      // Wait for background refresh
      await Future.delayed(const Duration(milliseconds: 100));
      
      verify(() => mockApi.getPagesProjects(accountId, page: 1)).called(1);
    });
  });
}