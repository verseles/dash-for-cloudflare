import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/worker.dart';
import '../domain/models/worker_settings.dart';
import '../domain/models/worker_route.dart';
import '../domain/models/worker_schedule.dart';
import '../domain/models/worker_domain.dart';
import '../domain/models/worker_analytics.dart';
import '../../auth/providers/account_provider.dart';
import '../../auth/providers/settings_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import '../../../core/logging/log_level.dart';

part 'workers_provider.g.dart';

// ==================== WORKERS STATE ====================

class WorkersState {
  const WorkersState({
    this.workers = const [],
    this.isFromCache = false,
    this.isRefreshing = false,
    this.cachedAt,
  });

  final List<Worker> workers;
  final bool isFromCache;
  final bool isRefreshing;
  final DateTime? cachedAt;

  WorkersState copyWith({
    List<Worker>? workers,
    bool? isFromCache,
    bool? isRefreshing,
    DateTime? cachedAt,
  }) {
    return WorkersState(
      workers: workers ?? this.workers,
      isFromCache: isFromCache ?? this.isFromCache,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

// ==================== WORKERS LIST ====================

const _cacheMaxAge = Duration(days: 3);

@riverpod
class WorkersNotifier extends _$WorkersNotifier {
  int _currentFetchId = 0;
  SharedPreferences? _prefs;

  String _cacheKey(String accountId) => 'workers_cache_$accountId';
  String _cacheTimeKey(String accountId) => 'workers_cache_time_$accountId';

  @override
  FutureOr<WorkersState> build() async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) return const WorkersState();

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try to load from cache first
    final cachedState = await _loadFromCache(accountId);
    if (cachedState != null) {
      // Return cached data and refresh in background
      unawaited(_refreshInBackground(accountId, cachedState));
      return cachedState;
    }

    // No cache, fetch from API
    return _fetchWorkers(accountId);
  }

  Future<WorkersState?> _loadFromCache(String accountId) async {
    try {
      final cachedJson = _prefs?.getString(_cacheKey(accountId));
      final cachedTimeStr = _prefs?.getString(_cacheTimeKey(accountId));

      if (cachedJson == null || cachedTimeStr == null) return null;

      final cachedTime = DateTime.parse(cachedTimeStr);
      final age = DateTime.now().difference(cachedTime);

      if (age > _cacheMaxAge) {
        log.info('WorkersNotifier: Cache expired (${age.inDays} days old)', category: LogCategory.state);
        return null;
      }

      final List<dynamic> workersJson = json.decode(cachedJson) as List<dynamic>;
      final workers = workersJson
          .map((e) => Worker.fromJson(e as Map<String, dynamic>))
          .toList();

      log.info('WorkersNotifier: Loaded ${workers.length} workers from cache', category: LogCategory.state);

      return WorkersState(
        workers: workers,
        isFromCache: true,
        cachedAt: cachedTime,
      );
    } catch (e) {
      log.warning('WorkersNotifier: Failed to load cache', details: e.toString());
      return null;
    }
  }

  Future<void> _saveToCache(String accountId, List<Worker> workers) async {
    try {
      final workersJson = workers.map((w) => w.toJson()).toList();
      await _prefs?.setString(_cacheKey(accountId), json.encode(workersJson));
      await _prefs?.setString(_cacheTimeKey(accountId), DateTime.now().toIso8601String());
    } catch (e) {
      log.warning('WorkersNotifier: Failed to save cache', details: e.toString());
    }
  }

  Future<void> _refreshInBackground(String accountId, WorkersState currentState) async {
    state = AsyncData(currentState.copyWith(isRefreshing: true));
    try {
      final freshState = await _fetchWorkersFromApi(accountId);
      state = AsyncData(freshState);
    } catch (e) {
      log.warning('WorkersNotifier: Background refresh failed', details: e.toString());
      state = AsyncData(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<WorkersState> _fetchWorkers(String accountId) async {
    return _fetchWorkersFromApi(accountId);
  }

  Future<WorkersState> _fetchWorkersFromApi(String accountId) async {
    final fetchId = ++_currentFetchId;
    log.stateChange('WorkersNotifier', 'Fetching workers for account $accountId');

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getWorkersScripts(accountId);

      if (_currentFetchId != fetchId) throw Exception('Stale request');

      if (!response.success || response.result == null) {
        throw Exception('Failed to fetch workers');
      }

      final workers = response.result!;
      unawaited(_saveToCache(accountId, workers));

      return WorkersState(
        workers: workers,
        isFromCache: false,
        cachedAt: DateTime.now(),
      );
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
  SharedPreferences? _prefs;
  String _cacheKey(String scriptName) => 'worker_settings_cache_$scriptName';

  @override
  FutureOr<WorkerSettings> build(String scriptName) async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) throw Exception('No account selected');

    _prefs = await ref.read(sharedPreferencesProvider.future);
    
    // Try cache
    final cached = _prefs?.getString(_cacheKey(scriptName));
    if (cached != null) {
      try {
        final settings = WorkerSettings.fromJson(json.decode(cached) as Map<String, dynamic>);
        unawaited(_fetchSettings(accountId, scriptName)); // Refresh in bg
        return settings;
      } catch (_) {}
    }

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
      
      final settings = response.result!;
      await _prefs?.setString(_cacheKey(scriptName), json.encode(settings.toJson()));
      
      state = AsyncData(settings);
      return settings;
    } catch (e, stack) {
      log.error('WorkerDetailsNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

// ==================== WORKER SCHEDULES ====================

@riverpod
class WorkerSchedulesNotifier extends _$WorkerSchedulesNotifier {
  SharedPreferences? _prefs;
  String _cacheKey(String scriptName) => 'worker_schedules_cache_$scriptName';

  @override
  FutureOr<List<WorkerSchedule>> build(String scriptName) async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) return [];

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try cache
    final cached = _prefs?.getString(_cacheKey(scriptName));
    if (cached != null) {
      try {
        final List<dynamic> jsonList = json.decode(cached) as List<dynamic>;
        final schedules = jsonList.map((e) => WorkerSchedule.fromJson(e as Map<String, dynamic>)).toList();
        unawaited(_fetchSchedules(accountId, scriptName)); // Refresh in bg
        return schedules;
      } catch (_) {}
    }

    return _fetchSchedules(accountId, scriptName);
  }

  Future<List<WorkerSchedule>> _fetchSchedules(String accountId, String scriptName) async {
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getWorkerSchedules(accountId, scriptName);
      final schedules = response.result?.schedules ?? [];
      
      await _prefs?.setString(_cacheKey(scriptName), json.encode(schedules.map((s) => s.toJson()).toList()));
      
      state = AsyncData(schedules);
      return schedules;
    } catch (e) {
      log.warning('WorkerSchedulesNotifier: Error fetching schedules for $scriptName', details: e.toString());
      return [];
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
  SharedPreferences? _prefs;
  static const _cacheKey = 'worker_domains_cache';

  @override
  FutureOr<List<WorkerDomain>> build() async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) return [];

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try cache
    final cached = _prefs?.getString(_cacheKey);
    if (cached != null) {
      try {
        final List<dynamic> jsonList = json.decode(cached) as List<dynamic>;
        final domains = jsonList.map((e) => WorkerDomain.fromJson(e as Map<String, dynamic>)).toList();
        unawaited(_fetchDomains(accountId)); // Refresh in bg
        return domains;
      } catch (_) {}
    }

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
      
      final domains = response.result!;
      await _prefs?.setString(_cacheKey, json.encode(domains.map((d) => d.toJson()).toList()));
      
      state = AsyncData(domains);
      return domains;
    } catch (e, stack) {
      log.error('WorkerDomainsNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;
    state = const AsyncLoading();
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
  SharedPreferences? _prefs;
  String _cacheKey(String zoneId) => 'worker_routes_cache_$zoneId';

  @override
  FutureOr<List<WorkerRoute>> build(String zoneId) async {
    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try cache
    final cached = _prefs?.getString(_cacheKey(zoneId));
    if (cached != null) {
      try {
        final List<dynamic> jsonList = json.decode(cached) as List<dynamic>;
        final routes = jsonList.map((e) => WorkerRoute.fromJson(e as Map<String, dynamic>)).toList();
        unawaited(_fetchRoutes(zoneId)); // Refresh in bg
        return routes;
      } catch (_) {}
    }

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
      
      final routes = response.result!;
      await _prefs?.setString(_cacheKey(zoneId), json.encode(routes.map((r) => r.toJson()).toList()));
      
      state = AsyncData(routes);
      return routes;
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
  SharedPreferences? _prefs;

  @override
  FutureOr<void> build() async {
    _prefs = await ref.read(sharedPreferencesProvider.future);
  }

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
      
      // Clear persistent cache to force fresh fetch
      await _prefs?.remove('worker_settings_cache_$scriptName');
      
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
      
      // Clear persistent cache to force fresh fetch
      await _prefs?.remove('worker_settings_cache_$scriptName');
      
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
  final workersStateAsync = ref.watch(workersNotifierProvider);
  final searchQuery = ref.watch(workerSearchNotifierProvider).toLowerCase();

  return workersStateAsync.maybeWhen(
    data: (state) {
      final workers = state.workers;
      if (searchQuery.isEmpty) return workers;
      return workers.where((w) => w.id.toLowerCase().contains(searchQuery)).toList();
    },
    orElse: () => [],
  );
}
