import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/worker.dart';
import '../domain/models/worker_settings.dart';
import '../domain/models/worker_route.dart';
import '../domain/models/worker_schedule.dart';
import '../domain/models/worker_domain.dart';
import '../domain/models/worker_analytics.dart';
import '../../auth/providers/account_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';

part 'workers_provider.g.dart';

// ==================== WORKERS LIST ====================

@riverpod
class WorkersNotifier extends _$WorkersNotifier {
  int _currentFetchId = 0;

  @override
  FutureOr<List<Worker>> build() async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) return [];

    return _fetchWorkers(accountId);
  }

  Future<List<Worker>> _fetchWorkers(String accountId) async {
    final fetchId = ++_currentFetchId;
    log.stateChange('WorkersNotifier', 'Fetching workers for account $accountId');

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getWorkersScripts(accountId);

      if (_currentFetchId != fetchId) return state.valueOrNull ?? [];

      if (!response.success || response.result == null) {
        throw Exception('Failed to fetch workers');
      }

      return response.result!;
    } catch (e, stack) {
      log.error('WorkersNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchWorkers(accountId));
  }
}

// ==================== WORKER DETAILS ====================

@riverpod
class WorkerDetailsNotifier extends _$WorkerDetailsNotifier {
  @override
  FutureOr<WorkerSettings> build(String scriptName) async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) throw Exception('No account selected');

    return _fetchSettings(accountId, scriptName);
  }

  Future<WorkerSettings> _fetchSettings(String accountId, String scriptName) async {
    log.stateChange('WorkerDetailsNotifier', 'Fetching settings for $scriptName');
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getWorkerSettings(accountId, scriptName);
      if (!response.success || response.result == null) {
        throw Exception('Failed to fetch worker settings');
      }
      return response.result!;
    } catch (e, stack) {
      log.error('WorkerDetailsNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

// ==================== WORKER SCHEDULES ====================

@riverpod
class WorkerSchedulesNotifier extends _$WorkerSchedulesNotifier {
  @override
  FutureOr<List<WorkerSchedule>> build(String scriptName) async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) return [];

    return _fetchSchedules(accountId, scriptName);
  }

  Future<List<WorkerSchedule>> _fetchSchedules(String accountId, String scriptName) async {
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getWorkerSchedules(accountId, scriptName);
      return response.result?.schedules ?? [];
    } catch (e) {
      log.warning('WorkerSchedulesNotifier: Error fetching schedules for $scriptName', details: e.toString());
      return []; // Return empty if schedules not supported or error
    }
  }
}

// ==================== WORKER METRICS ====================

@riverpod
class WorkerMetricsNotifier extends _$WorkerMetricsNotifier {
  @override
  FutureOr<WorkerAnalyticsData?> build(String scriptName, DateTime since, DateTime until) async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) return null;

    return _fetchMetrics(accountId, scriptName, since, until);
  }

  Future<WorkerAnalyticsData?> _fetchMetrics(
    String accountId,
    String scriptName,
    DateTime since,
    DateTime until,
  ) async {
    try {
      final graphql = ref.read(cloudflareGraphQLProvider);
      return await graphql.fetchWorkerAnalytics(
        accountId: accountId,
        scriptName: scriptName,
        since: since,
        until: until,
      );
    } catch (e) {
      log.error('WorkerMetricsNotifier: Error', error: e);
      rethrow;
    }
  }
}

// ==================== WORKER DOMAINS ====================

@riverpod
class WorkerDomainsNotifier extends _$WorkerDomainsNotifier {
  @override
  FutureOr<List<WorkerDomain>> build() async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) return [];

    return _fetchDomains(accountId);
  }

  Future<List<WorkerDomain>> _fetchDomains(String accountId) async {
    log.stateChange('WorkerDomainsNotifier', 'Fetching custom domains for account $accountId');
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getWorkerDomains(accountId);
      if (!response.success || response.result == null) {
        throw Exception('Failed to fetch worker domains');
      }
      return response.result!;
    } catch (e, stack) {
      log.error('WorkerDomainsNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;
    state = await AsyncValue.guard(() => _fetchDomains(accountId));
  }

  Future<void> addDomain({
    required String hostname,
    required String service,
    required String zoneId,
    String environment = 'production',
  }) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.attachWorkerDomain(accountId, {
        'hostname': hostname,
        'service': service,
        'zone_id': zoneId,
        'environment': environment,
      });

      if (!response.success) {
        throw Exception(response.errors.firstOrNull?.message ?? 'Failed to add domain');
      }

      ref.invalidateSelf();
    } catch (e) {
      log.error('WorkerDomainsNotifier: Add Error', error: e);
      rethrow;
    }
  }

  Future<void> deleteDomain(String domainId) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.detachWorkerDomain(accountId, domainId);

      if (!response.success) {
        throw Exception(response.errors.firstOrNull?.message ?? 'Failed to delete domain');
      }

      ref.invalidateSelf();
    } catch (e) {
      log.error('WorkerDomainsNotifier: Delete Error', error: e);
      rethrow;
    }
  }
}

// ==================== WORKER ROUTES ====================

@riverpod
class WorkerRoutesNotifier extends _$WorkerRoutesNotifier {
  @override
  FutureOr<List<WorkerRoute>> build(String zoneId) async {
    return _fetchRoutes(zoneId);
  }

  Future<List<WorkerRoute>> _fetchRoutes(String zoneId) async {
    log.stateChange('WorkerRoutesNotifier', 'Fetching routes for zone $zoneId');
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getWorkerRoutes(zoneId);
      if (!response.success || response.result == null) {
        throw Exception('Failed to fetch worker routes');
      }
      return response.result!;
    } catch (e, stack) {
      log.error('WorkerRoutesNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchRoutes(zoneId));
  }

  Future<void> addRoute({required String pattern, required String script}) async {
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.createWorkerRoute(zoneId, {
        'pattern': pattern,
        'script': script,
      });

      if (!response.success) {
        throw Exception(response.errors.firstOrNull?.message ?? 'Failed to add route');
      }

      ref.invalidateSelf();
    } catch (e) {
      log.error('WorkerRoutesNotifier: Add Error', error: e);
      rethrow;
    }
  }

  Future<void> deleteRoute(String routeId) async {
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.deleteWorkerRoute(zoneId, routeId);

      if (!response.success) {
        throw Exception(response.errors.firstOrNull?.message ?? 'Failed to delete route');
      }

      ref.invalidateSelf();
    } catch (e) {
      log.error('WorkerRoutesNotifier: Delete Error', error: e);
      rethrow;
    }
  }
}

// ==================== WORKER SETTINGS ACTIONS ====================

@riverpod
class WorkerSettingsActionNotifier extends _$WorkerSettingsActionNotifier {
  @override
  FutureOr<void> build() async {}

  Future<bool> updateSettings({
    required String scriptName,
    required Map<String, dynamic> data,
  }) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return false;

    state = const AsyncLoading();
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.patchWorkerSettings(accountId, scriptName, data);

      if (!response.success) {
        throw Exception(response.errors.firstOrNull?.message ?? 'Update failed');
      }

      log.stateChange('WorkerSettingsActionNotifier', 'Settings updated for $scriptName');
      ref.invalidate(workerDetailsNotifierProvider(scriptName));
      state = const AsyncData(null);
      return true;
    } catch (e) {
      log.error('WorkerSettingsActionNotifier: Error', error: e);
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateSecret({
    required String scriptName,
    required String name,
    required String text,
  }) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return false;

    state = const AsyncLoading();
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.updateWorkerSecret(accountId, scriptName, {
        'name': name,
        'text': text,
        'type': 'secret_text',
      });

      if (!response.success) {
        throw Exception(response.errors.firstOrNull?.message ?? 'Secret update failed');
      }

      log.stateChange('WorkerSettingsActionNotifier', 'Secret $name updated for $scriptName');
      ref.invalidate(workerDetailsNotifierProvider(scriptName));
      state = const AsyncData(null);
      return true;
    } catch (e) {
      log.error('WorkerSettingsActionNotifier: Secret Error', error: e);
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

// ==================== WORKER FILTERS ====================

@riverpod
class WorkerSearchNotifier extends _$WorkerSearchNotifier {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
List<Worker> filteredWorkers(FilteredWorkersRef ref) {
  final workersAsync = ref.watch(workersNotifierProvider);
  final searchQuery = ref.watch(workerSearchNotifierProvider).toLowerCase();

  return workersAsync.maybeWhen(
    data: (workers) {
      if (searchQuery.isEmpty) return workers;
      return workers.where((w) => w.id.toLowerCase().contains(searchQuery)).toList();
    },
    orElse: () => [],
  );
}
