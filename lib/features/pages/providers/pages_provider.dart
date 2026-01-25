import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/pages_project.dart';
import '../domain/models/pages_deployment.dart';
import '../domain/models/pages_domain.dart';
import '../domain/models/deployment_log.dart';
import '../../auth/providers/account_provider.dart';
import '../../auth/providers/settings_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import '../../../core/logging/log_level.dart';

part 'pages_provider.g.dart';

/// Cache expiration duration (3 days)
const _cacheMaxAge = Duration(days: 3);

// ==================== PROJECTS STATE ====================

/// State for pages projects with cache metadata
class PagesProjectsState {
  const PagesProjectsState({
    this.projects = const [],
    this.isFromCache = false,
    this.isRefreshing = false,
    this.cachedAt,
  });

  final List<PagesProject> projects;
  final bool isFromCache;
  final bool isRefreshing;
  final DateTime? cachedAt;

  PagesProjectsState copyWith({
    List<PagesProject>? projects,
    bool? isFromCache,
    bool? isRefreshing,
    DateTime? cachedAt,
  }) {
    return PagesProjectsState(
      projects: projects ?? this.projects,
      isFromCache: isFromCache ?? this.isFromCache,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

// ==================== PROJECTS NOTIFIER ====================

/// Provider for fetching and caching Pages projects (ADR-022 pattern)
@riverpod
class PagesProjectsNotifier extends _$PagesProjectsNotifier {
  SharedPreferences? _prefs;
  int _currentFetchId = 0;

  String get _cacheKey => 'pages_projects_cache_${_accountId ?? ""}';
  String get _cacheTimeKey => 'pages_projects_cache_time_${_accountId ?? ""}';

  String? get _accountId => ref.read(selectedAccountIdProvider);

  @override
  FutureOr<PagesProjectsState> build() async {
    // Watch for account changes
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) {
      return const PagesProjectsState();
    }

    // Propagate account errors
    final accountsState = ref.watch(accountsNotifierProvider);
    if (accountsState.hasError) {
      throw accountsState.error!;
    }

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try to load from cache first
    final cachedState = await _loadFromCache();
    if (cachedState != null) {
      unawaited(_refreshInBackground(cachedState));
      return cachedState;
    }

    return _fetchProjects();
  }

  Future<PagesProjectsState?> _loadFromCache() async {
    try {
      final cachedJson = _prefs?.getString(_cacheKey);
      final cachedTimeStr = _prefs?.getString(_cacheTimeKey);

      if (cachedJson == null || cachedTimeStr == null) return null;

      final cachedTime = DateTime.parse(cachedTimeStr);
      final age = DateTime.now().difference(cachedTime);

      if (age > _cacheMaxAge) {
        log.info(
          'PagesProjectsNotifier: Cache expired (${age.inDays} days old)',
          category: LogCategory.state,
        );
        return null;
      }

      final List<dynamic> projectsJson =
          json.decode(cachedJson) as List<dynamic>;
      final projects = projectsJson
          .map((e) => PagesProject.fromJson(e as Map<String, dynamic>))
          .toList();

      log.info(
        'PagesProjectsNotifier: Loaded ${projects.length} projects from cache',
        category: LogCategory.state,
      );

      return PagesProjectsState(
        projects: projects,
        isFromCache: true,
        cachedAt: cachedTime,
      );
    } catch (e, stack) {
      log.error(
        'PagesProjectsNotifier: Cache error',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  Future<void> _saveToCache(List<PagesProject> projects) async {
    try {
      final projectsJson = projects.map((p) => p.toJson()).toList();
      await _prefs?.setString(_cacheKey, json.encode(projectsJson));
      await _prefs?.setString(_cacheTimeKey, DateTime.now().toIso8601String());
      log.info(
        'PagesProjectsNotifier: Saved ${projects.length} projects to cache',
        category: LogCategory.state,
      );
    } catch (e) {
      log.warning(
        'PagesProjectsNotifier: Failed to save cache',
        details: e.toString(),
      );
    }
  }

  Future<void> _refreshInBackground(PagesProjectsState currentState) async {
    state = AsyncData(currentState.copyWith(isRefreshing: true));

    try {
      final freshState = await _fetchProjectsFromApi();
      state = AsyncData(freshState);
    } catch (e) {
      log.warning(
        'PagesProjectsNotifier: Background refresh failed',
        details: e.toString(),
      );
      state = AsyncData(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<PagesProjectsState> _fetchProjects() async {
    return _fetchProjectsFromApi();
  }

  Future<PagesProjectsState> _fetchProjectsFromApi() async {
    final fetchId = ++_currentFetchId;
    final accountId = ref.read(selectedAccountIdProvider);

    if (accountId == null) {
      return const PagesProjectsState();
    }

    log.stateChange(
      'PagesProjectsNotifier',
      'Fetching projects for account $accountId',
    );

    try {
      final api = ref.read(cloudflareApiProvider);

      // Fetch all pages (API returns max 10 per page)
      final allProjects = <PagesProject>[];
      int currentPage = 1;
      int totalPages = 1;

      do {
        final response = await api.getPagesProjects(
          accountId,
          page: currentPage,
        );

        // Race condition check (ADR-007)
        if (_currentFetchId != fetchId) {
          log.info(
            'PagesProjectsNotifier: Discarding stale response',
            category: LogCategory.state,
          );
          return state.valueOrNull ?? const PagesProjectsState();
        }

        if (!response.success || response.result == null) {
          final error = response.errors.isNotEmpty
              ? response.errors.first.message
              : 'Failed to fetch projects';
          throw Exception(error);
        }

        allProjects.addAll(response.result!);

        // Update pagination info
        if (response.resultInfo != null) {
          totalPages = response.resultInfo!.totalPages;
        }
        currentPage++;
      } while (currentPage <= totalPages);

      log.stateChange(
        'PagesProjectsNotifier',
        'Fetched ${allProjects.length} projects',
      );

      unawaited(_saveToCache(allProjects));

      return PagesProjectsState(
        projects: allProjects,
        isFromCache: false,
        cachedAt: DateTime.now(),
      );
    } catch (e, stack) {
      log.error('PagesProjectsNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    log.stateChange('PagesProjectsNotifier', 'Refreshing projects');
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchProjects);
  }
}

// ==================== PROJECT DETAILS NOTIFIER ====================

/// Provider for fetching a single project's details
@riverpod
class PagesProjectDetailsNotifier extends _$PagesProjectDetailsNotifier {
  SharedPreferences? _prefs;
  String _cacheKey(String projectName) => 'pages_project_details_cache_$projectName';

  @override
  FutureOr<PagesProject> build(String projectName) async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) throw Exception('No account selected');

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try cache
    final cached = _prefs?.getString(_cacheKey(projectName));
    if (cached != null) {
      try {
        final project = PagesProject.fromJson(json.decode(cached) as Map<String, dynamic>);
        unawaited(_fetchProject(accountId, projectName)); // Refresh in bg
        return project;
      } catch (_) {}
    }

    return _fetchProject(accountId, projectName);
  }

  Future<PagesProject> _fetchProject(String accountId, String projectName) async {
    log.stateChange('PagesProjectDetailsNotifier', 'Fetching details for $projectName');
    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getPagesProject(accountId, projectName);

      if (!response.success || response.result == null) {
        throw Exception('Failed to fetch project details');
      }

      final project = response.result!;
      await _prefs?.setString(_cacheKey(projectName), json.encode(project.toJson()));
      
      state = AsyncData(project);
      return project;
    } catch (e, stack) {
      log.error('PagesProjectDetailsNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProject(accountId, projectName));
  }
}

// ==================== DEPLOYMENTS NOTIFIER ====================

/// Provider for fetching deployments of a specific project
@riverpod
class PagesDeploymentsNotifier extends _$PagesDeploymentsNotifier {
  int _currentFetchId = 0;
  SharedPreferences? _prefs;

  String _cacheKey(String projectName) => 'pages_deployments_cache_$projectName';

  @override
  FutureOr<List<PagesDeployment>> build(String projectName) async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) return [];

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try cache
    final cached = _prefs?.getString(_cacheKey(projectName));
    if (cached != null) {
      try {
        final List<dynamic> jsonList = json.decode(cached) as List<dynamic>;
        final deployments = jsonList
            .map((e) => PagesDeployment.fromJson(e as Map<String, dynamic>))
            .toList();
        unawaited(_fetchDeployments(accountId, projectName)); // Refresh in bg
        return deployments;
      } catch (_) {}
    }

    return _fetchDeployments(accountId, projectName);
  }

  Future<List<PagesDeployment>> _fetchDeployments(
    String accountId,
    String projectName,
  ) async {
    final fetchId = ++_currentFetchId;

    log.stateChange(
      'PagesDeploymentsNotifier',
      'Fetching deployments for $projectName',
    );

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getPagesDeployments(accountId, projectName);

      if (_currentFetchId != fetchId) {
        return state.valueOrNull ?? [];
      }

      if (!response.success || response.result == null) {
        throw Exception('Failed to fetch deployments');
      }

      final deployments = response.result!;
      await _prefs?.setString(
        _cacheKey(projectName),
        json.encode(deployments.map((d) => d.toJson()).toList()),
      );

      state = AsyncData(deployments);
      return deployments;
    } catch (e, stack) {
      log.error('PagesDeploymentsNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchDeployments(accountId, projectName),
    );
  }
}

// ==================== ROLLBACK ACTION ====================

/// Provider for rollback action
@riverpod
class RollbackNotifier extends _$RollbackNotifier {
  @override
  FutureOr<void> build() async {}

  Future<bool> rollback({
    required String projectName,
    required String deploymentId,
  }) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) {
      throw Exception('No account selected');
    }

    state = const AsyncLoading();

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.rollbackDeployment(
        accountId,
        projectName,
        deploymentId,
      );

      if (!response.success) {
        final error = response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Rollback failed';
        throw Exception(error);
      }

      log.stateChange(
        'RollbackNotifier',
        'Rollback successful for $projectName to $deploymentId',
      );

      // Refresh projects and deployments after rollback
      ref.invalidate(pagesProjectsNotifierProvider);
      ref.invalidate(pagesDeploymentsNotifierProvider(projectName));

      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      log.error('RollbackNotifier: Error', error: e, stackTrace: stack);
      state = AsyncError(e, stack);
      return false;
    }
  }
}

// ==================== RETRY ACTION ====================

/// Provider for retry deployment action
@riverpod
class RetryNotifier extends _$RetryNotifier {
  @override
  FutureOr<void> build() async {}

  Future<bool> retry({
    required String projectName,
    required String deploymentId,
  }) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) {
      throw Exception('No account selected');
    }

    state = const AsyncLoading();

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.retryDeployment(
        accountId,
        projectName,
        deploymentId,
      );

      if (!response.success) {
        final error = response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Retry failed';
        throw Exception(error);
      }

      log.stateChange(
        'RetryNotifier',
        'Retry successful for $projectName deployment $deploymentId',
      );

      // Refresh projects and deployments after retry
      ref.invalidate(pagesProjectsNotifierProvider);
      ref.invalidate(pagesDeploymentsNotifierProvider(projectName));

      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      log.error('RetryNotifier: Error', error: e, stackTrace: stack);
      state = AsyncError(e, stack);
      return false;
    }
  }
}

// ==================== SELECTED PROJECT ====================

/// Provider for the currently selected project (for navigation)
@riverpod
class SelectedProjectNotifier extends _$SelectedProjectNotifier {
  @override
  PagesProject? build() => null;

  void select(PagesProject project) {
    state = project;
  }

  void clear() {
    state = null;
  }
}

// ==================== DEPLOYMENT LOGS ====================

/// Parameters for fetching deployment logs
class DeploymentLogsParams {
  const DeploymentLogsParams({
    required this.projectName,
    required this.deploymentId,
  });

  final String projectName;
  final String deploymentId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentLogsParams &&
          runtimeType == other.runtimeType &&
          projectName == other.projectName &&
          deploymentId == other.deploymentId;

  @override
  int get hashCode => projectName.hashCode ^ deploymentId.hashCode;
}

/// State for deployment logs with polling support
class DeploymentLogsState {
  const DeploymentLogsState({
    this.logs = const [],
    this.isLoading = false,
    this.error,
    this.isPolling = false,
    this.total = 0,
  });

  final List<DeploymentLogEntry> logs;
  final bool isLoading;
  final String? error;
  final bool isPolling;
  final int total;

  DeploymentLogsState copyWith({
    List<DeploymentLogEntry>? logs,
    bool? isLoading,
    String? error,
    bool? isPolling,
    int? total,
  }) {
    return DeploymentLogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isPolling: isPolling ?? this.isPolling,
      total: total ?? this.total,
    );
  }
}

/// Provider for deployment logs with automatic polling during active builds
@riverpod
class DeploymentLogsNotifier extends _$DeploymentLogsNotifier {
  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 3);

  @override
  DeploymentLogsState build(DeploymentLogsParams params) {
    // Clean up timer when provider is disposed
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    // Start fetching logs
    _fetchLogs();

    return const DeploymentLogsState(isLoading: true);
  }

  Future<void> _fetchLogs() async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) {
      state = state.copyWith(isLoading: false, error: 'No account selected');
      return;
    }

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getDeploymentLogs(
        accountId,
        params.projectName,
        params.deploymentId,
      );

      if (!response.success) {
        final error = response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Failed to fetch logs';
        state = state.copyWith(isLoading: false, error: error);
        return;
      }

      final logsResponse = response.result!;
      state = state.copyWith(
        logs: logsResponse.data,
        total: logsResponse.total,
        isLoading: false,
        error: null,
      );

      log.stateChange(
        'DeploymentLogsNotifier',
        'Fetched ${logsResponse.data.length} log entries',
      );
    } catch (e, stack) {
      log.error('DeploymentLogsNotifier: Error', error: e, stackTrace: stack);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Start polling for new logs (call when deployment is building)
  void startPolling() {
    if (_pollingTimer != null) return;

    state = state.copyWith(isPolling: true);
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _fetchLogs();
    });

    log.stateChange('DeploymentLogsNotifier', 'Started polling');
  }

  /// Stop polling (call when deployment completes or fails)
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    state = state.copyWith(isPolling: false);

    log.stateChange('DeploymentLogsNotifier', 'Stopped polling');
  }

  /// Refresh logs manually
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _fetchLogs();
  }
}

// ==================== DOMAINS NOTIFIER ====================

/// Provider for managing project custom domains
@riverpod
class PagesDomainsNotifier extends _$PagesDomainsNotifier {
  SharedPreferences? _prefs;
  String _cacheKey(String projectName) => 'pages_domains_cache_$projectName';

  @override
  FutureOr<List<PagesDomain>> build(String projectName) async {
    final accountId = ref.watch(selectedAccountIdProvider);
    if (accountId == null) return [];

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try cache
    final cached = _prefs?.getString(_cacheKey(projectName));
    if (cached != null) {
      try {
        final List<dynamic> jsonList = json.decode(cached) as List<dynamic>;
        final domains = jsonList
            .map((e) => PagesDomain.fromJson(e as Map<String, dynamic>))
            .toList();
        unawaited(_fetchDomains(accountId, projectName)); // Refresh in bg
        return domains;
      } catch (_) {}
    }

    return _fetchDomains(accountId, projectName);
  }

  Future<List<PagesDomain>> _fetchDomains(
    String accountId,
    String projectName,
  ) async {
    log.stateChange(
      'PagesDomainsNotifier',
      'Fetching domains for $projectName',
    );

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getPagesDomains(accountId, projectName);

      if (!response.success || response.result == null) {
        throw Exception('Failed to fetch domains');
      }

      final domains = response.result!;
      await _prefs?.setString(
        _cacheKey(projectName),
        json.encode(domains.map((d) => d.toJson()).toList()),
      );

      state = AsyncData(domains);
      return domains;
    } catch (e, stack) {
      log.error('PagesDomainsNotifier: Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> addDomain(String domainName) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.addPagesDomain(
        accountId,
        projectName,
        {'name': domainName},
      );

      if (!response.success) {
        final error = response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Failed to add domain';
        throw Exception(error);
      }

      // Clear cache
      await _prefs?.remove('pages_domains_cache_$projectName');

      // Refresh list
      ref.invalidateSelf();
      // Also refresh project to update domain list
      ref.invalidate(pagesProjectsNotifierProvider);
    } catch (e, stack) {
      log.error('PagesDomainsNotifier: Add Error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteDomain(String domainName) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.deletePagesDomain(
        accountId,
        projectName,
        domainName,
      );

      if (!response.success) {
        final error = response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Failed to delete domain';
        throw Exception(error);
      }

      // Clear cache
      await _prefs?.remove('pages_domains_cache_$projectName');

      // Refresh list
      ref.invalidateSelf();
      // Also refresh project to update domain list
      ref.invalidate(pagesProjectsNotifierProvider);
    } catch (e, stack) {
      log.error(
        'PagesDomainsNotifier: Delete Error',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<void> refresh() async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchDomains(accountId, projectName),
    );
  }
}

// ==================== SETTINGS NOTIFIER ====================

/// Provider for updating project settings (build, env vars)
@riverpod
class PagesSettingsNotifier extends _$PagesSettingsNotifier {
  SharedPreferences? _prefs;

  @override
  FutureOr<void> build() async {
    _prefs = await ref.read(sharedPreferencesProvider.future);
  }

  Future<bool> updateProject({
    required String projectName,
    Map<String, dynamic>? buildConfig,
    Map<String, dynamic>? deploymentConfigs,
  }) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) return false;

    state = const AsyncLoading();

    // Recursive helper to remove nulls from maps, but PRESERVE them for specific contexts
    Map<String, dynamic> removeNulls(Map<String, dynamic> map, {bool preserveNulls = false}) {
      final result = <String, dynamic>{};
      map.forEach((key, value) {
        // We preserve nulls if we are in an env_vars container OR if it's a build/deployment setting
        final shouldPreserveContext = preserveNulls || 
            key == 'env_vars' || 
            key == 'build_config' || 
            key == 'deployment_configs';

        if (value != null) {
          if (value is Map<String, dynamic>) {
            result[key] = removeNulls(value, preserveNulls: shouldPreserveContext);
          } else if (value is Map) {
            result[key] = removeNulls(Map<String, dynamic>.from(value), preserveNulls: shouldPreserveContext);
          } else {
            result[key] = value;
          }
        } else if (preserveNulls) {
          // Keep null value only if we are inside a context that requires it
          result[key] = null;
        }
      });
      return result;
    }

    try {
      final api = ref.read(cloudflareApiProvider);
      final rawData = <String, dynamic>{};
      if (buildConfig != null) rawData['build_config'] = buildConfig;
      if (deploymentConfigs != null) {
        rawData['deployment_configs'] = deploymentConfigs;
      }

      final data = removeNulls(rawData);

      log.info('PagesSettingsNotifier: updateProject payload for $projectName: ${json.encode(data)}', category: LogCategory.api);

      final response = await api.patchPagesProject(accountId, projectName, data);

      if (!response.success) {
        final error = response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Failed to update project settings';
        log.error('PagesSettingsNotifier: API Error Response: ${response.errors}', details: error);
        throw Exception(error);
      }

      log.stateChange(
        'PagesSettingsNotifier',
        'Updated settings for $projectName',
      );

      // Clear main project list cache
      final accountIdForCache = ref.read(selectedAccountIdProvider) ?? '';
      await _prefs?.remove('pages_projects_cache_$accountIdForCache');
      
      // Clear specific project details cache
      await _prefs?.remove('pages_project_details_cache_$projectName');

      // Refresh projects list to update local state
      ref.invalidate(pagesProjectsNotifierProvider);
      ref.invalidate(pagesProjectDetailsNotifierProvider(projectName));

      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      log.error('PagesSettingsNotifier: Error', error: e, stackTrace: stack);
      state = AsyncError(e, stack);
      return false;
    }
  }
}
