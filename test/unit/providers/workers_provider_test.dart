import 'dart:async';
import 'dart:convert';
import 'package:cf/core/api/client/cloudflare_api.dart';
import 'package:cf/core/api/models/cloudflare_response.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/auth/providers/account_provider.dart';
import 'package:cf/features/auth/providers/settings_provider.dart';
import 'package:cf/features/workers/domain/models/worker.dart';
import 'package:cf/features/workers/providers/workers_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../fixtures/fixture_reader.dart';

class MockCloudflareApi extends Mock implements CloudflareApi {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Mock Notifier for Accounts
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

  group('WorkersNotifier Unit Tests', () {
    test('fetches workers from API when no cache exists', () async {
      final scriptsJson = jsonDecode(fixture('workers/scripts.json'));
      final mockResponse = CloudflareResponse<List<Worker>>.fromJson(
        scriptsJson,
        (json) => (json as List).map((e) => Worker.fromJson(e)).toList(),
      );

      when(() => mockPrefs.getString(any())).thenReturn(null);
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
      when(() => mockApi.getWorkersScripts(accountId))
          .thenAnswer((_) async => mockResponse);

      final result = await container.read(workersNotifierProvider.future);

      expect(result.workers.length, mockResponse.result?.length);
      expect(result.isFromCache, isFalse);
      verify(() => mockApi.getWorkersScripts(accountId)).called(1);
    });

    test('loads from cache and refreshes in background', () async {
      final scriptsJson = jsonDecode(fixture('workers/scripts.json'));
      final cachedWorkers = (scriptsJson['result'] as List)
          .map((e) => Worker.fromJson(e))
          .toList();

      when(() => mockPrefs.getString(any(that: contains('cache_time'))))
          .thenReturn(DateTime.now().toIso8601String());
      when(() => mockPrefs.getString(any(that: contains('cache_account1'))))
          .thenReturn(jsonEncode(scriptsJson['result']));
      
      // Mock API for background refresh
      final mockResponse = CloudflareResponse<List<Worker>>.fromJson(
        scriptsJson,
        (json) => (json as List).map((e) => Worker.fromJson(e)).toList(),
      );
      when(() => mockApi.getWorkersScripts(accountId))
          .thenAnswer((_) async => mockResponse);

      final result = await container.read(workersNotifierProvider.future);

      expect(result.workers.length, cachedWorkers.length);
      expect(result.isFromCache, isTrue);
      
      // Wait for background refresh
      await Future.delayed(const Duration(milliseconds: 100));
      
      verify(() => mockApi.getWorkersScripts(accountId)).called(1);
    });

    test('deleteWorker calls API and invalidates cache', () async {
      final scriptName = 'test-worker';
      final mockResponse = CloudflareResponse<DeleteResponse>(
        success: true,
        errors: [],
        messages: [],
        result: const DeleteResponse(id: 'test-worker'),
      );

      when(() => mockApi.deleteWorkerScript(accountId, scriptName))
          .thenAnswer((_) async => mockResponse);
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
      
      // Mock list fetch for the refresh after delete
      when(() => mockApi.getWorkersScripts(accountId))
          .thenAnswer((_) async => CloudflareResponse<List<Worker>>(
            success: true, errors: [], messages: [], result: [],
          ));
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await container.read(workersNotifierProvider.notifier).deleteWorker(scriptName);

      verify(() => mockApi.deleteWorkerScript(accountId, scriptName)).called(1);
    });
  });
}
