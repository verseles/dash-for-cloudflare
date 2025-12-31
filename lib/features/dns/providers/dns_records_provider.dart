import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/dns_record.dart';
import './zone_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import '../../../core/logging/log_level.dart';
import '../../auth/providers/settings_provider.dart';

part 'dns_records_provider.g.dart';

/// Cache expiration duration (3 days)
const _cacheMaxAge = Duration(days: 3);

/// State for DNS records with additional UI state
class DnsRecordsState {
  const DnsRecordsState({
    this.records = const [],
    this.savingIds = const {},
    this.newIds = const {},
    this.deletingIds = const {},
    this.activeFilter = 'All',
    this.searchQuery = '',
    this.isFromCache = false,
    this.isRefreshing = false,
    this.cachedAt,
  });

  final List<DnsRecord> records;
  final Set<String> savingIds;
  final Set<String> newIds;
  final Set<String> deletingIds;
  final String activeFilter;
  final String searchQuery;
  final bool isFromCache;
  final bool isRefreshing;
  final DateTime? cachedAt;

  DnsRecordsState copyWith({
    List<DnsRecord>? records,
    Set<String>? savingIds,
    Set<String>? newIds,
    Set<String>? deletingIds,
    String? activeFilter,
    String? searchQuery,
    bool? isFromCache,
    bool? isRefreshing,
    DateTime? cachedAt,
  }) {
    return DnsRecordsState(
      records: records ?? this.records,
      savingIds: savingIds ?? this.savingIds,
      newIds: newIds ?? this.newIds,
      deletingIds: deletingIds ?? this.deletingIds,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isFromCache: isFromCache ?? this.isFromCache,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  /// Get filtered records based on current filter and search
  List<DnsRecord> get filteredRecords {
    var result = records;

    // Filter by type
    if (activeFilter != 'All') {
      result = result.where((r) => r.type == activeFilter).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result
          .where(
            (r) =>
                r.name.toLowerCase().contains(query) ||
                r.content.toLowerCase().contains(query),
          )
          .toList();
    }

    return result;
  }
}

/// DNS Records notifier - manages records for selected zone
@riverpod
class DnsRecordsNotifier extends _$DnsRecordsNotifier {
  int _currentFetchId = 0;
  SharedPreferences? _prefs;

  String _cacheKey(String zoneId) => 'dns_records_cache_$zoneId';
  String _cacheTimeKey(String zoneId) => 'dns_records_cache_time_$zoneId';

  @override
  FutureOr<DnsRecordsState> build() async {
    final zoneId = ref.watch(selectedZoneIdProvider);
    if (zoneId == null) {
      return const DnsRecordsState();
    }

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try to load from cache first
    final cachedState = await _loadFromCache(zoneId);
    if (cachedState != null) {
      // Return cached data and refresh in background
      unawaited(_refreshInBackground(zoneId, cachedState));
      return cachedState;
    }

    // No cache, fetch from API
    return _fetchRecords(zoneId);
  }

  Future<DnsRecordsState?> _loadFromCache(String zoneId) async {
    try {
      final cachedJson = _prefs?.getString(_cacheKey(zoneId));
      final cachedTimeStr = _prefs?.getString(_cacheTimeKey(zoneId));

      if (cachedJson == null || cachedTimeStr == null) return null;

      final cachedTime = DateTime.parse(cachedTimeStr);
      final age = DateTime.now().difference(cachedTime);

      // Check if cache is still valid
      if (age > _cacheMaxAge) {
        log.info('DnsRecordsNotifier: Cache expired (${age.inDays} days old)', category: LogCategory.state);
        return null;
      }

      final List<dynamic> recordsJson = json.decode(cachedJson) as List<dynamic>;
      final records = recordsJson
          .map((e) => DnsRecord.fromJson(e as Map<String, dynamic>))
          .toList();

      log.info('DnsRecordsNotifier: Loaded ${records.length} records from cache (${age.inMinutes} minutes old)', category: LogCategory.state);

      return DnsRecordsState(
        records: records,
        isFromCache: true,
        cachedAt: cachedTime,
      );
    } catch (e, stack) {
      log.warning('DnsRecordsNotifier: Failed to load cache', details: e.toString());
      log.error('DnsRecordsNotifier: Cache error', error: e, stackTrace: stack);
      return null;
    }
  }

  Future<void> _saveToCache(String zoneId, List<DnsRecord> records) async {
    try {
      final recordsJson = records.map((r) => r.toJson()).toList();
      await _prefs?.setString(_cacheKey(zoneId), json.encode(recordsJson));
      await _prefs?.setString(_cacheTimeKey(zoneId), DateTime.now().toIso8601String());
      log.info('DnsRecordsNotifier: Saved ${records.length} records to cache', category: LogCategory.state);
    } catch (e) {
      log.warning('DnsRecordsNotifier: Failed to save cache', details: e.toString());
    }
  }

  Future<void> _refreshInBackground(String zoneId, DnsRecordsState currentState) async {
    // Mark as refreshing
    state = AsyncData(currentState.copyWith(isRefreshing: true));

    try {
      final freshState = await _fetchRecordsFromApi(zoneId);
      state = AsyncData(freshState.copyWith(
        activeFilter: currentState.activeFilter,
        searchQuery: currentState.searchQuery,
      ));
    } catch (e) {
      // Keep showing cached data on error
      log.warning('DnsRecordsNotifier: Background refresh failed, keeping cache', details: e.toString());
      state = AsyncData(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<DnsRecordsState> _fetchRecords(String zoneId) async {
    return _fetchRecordsFromApi(zoneId);
  }

  Future<DnsRecordsState> _fetchRecordsFromApi(String zoneId) async {
    final fetchId = ++_currentFetchId;
    log.stateChange('DnsRecordsNotifier', 'Fetching records for zone $zoneId');

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getDnsRecords(zoneId);

      // Race condition prevention
      if (_currentFetchId != fetchId) {
        log.info('DnsRecordsNotifier: Stale request discarded', category: LogCategory.state);
        throw Exception('Stale request');
      }

      if (!response.success || response.result == null) {
        final error = response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Failed to fetch DNS records';
        log.error('DnsRecordsNotifier: Failed to fetch records', details: error);
        throw Exception(error);
      }

      final records = response.result!;
      log.stateChange('DnsRecordsNotifier', 'Fetched ${records.length} records');

      // Save to cache
      unawaited(_saveToCache(zoneId, records));

      return DnsRecordsState(
        records: records,
        isFromCache: false,
        cachedAt: DateTime.now(),
      );
    } catch (e, stack) {
      log.error('DnsRecordsNotifier: Exception', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Refresh records
  Future<void> refresh() async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchRecords(zoneId));
  }

  /// Create or update a DNS record
  Future<DnsRecord?> saveRecord(DnsRecord record, {bool isNew = false}) async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return null;

    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    // Mark as saving
    state = AsyncData(
      currentState.copyWith(savingIds: {...currentState.savingIds, record.id}),
    );

    try {
      final api = ref.read(cloudflareApiProvider);
      final recordCreate = DnsRecordCreate(
        type: record.type,
        name: record.name,
        content: record.content,
        proxied: record.proxied,
        ttl: record.ttl,
        priority: record.priority,
        data: record.data,
      );

      final response = isNew
          ? await api.createDnsRecord(zoneId, recordCreate)
          : await api.updateDnsRecord(zoneId, record.id, recordCreate);

      if (!response.success || response.result == null) {
        throw Exception(
          response.errors.isNotEmpty
              ? response.errors.first.message
              : 'Failed to save record',
        );
      }

      final savedRecord = response.result!;
      final updatedRecords = isNew
          ? [savedRecord, ...currentState.records]
          : currentState.records
                .map((r) => r.id == record.id ? savedRecord : r)
                .toList();

      final newState = currentState.copyWith(
        records: updatedRecords,
        savingIds: currentState.savingIds.difference({record.id}),
        newIds: isNew
            ? {...currentState.newIds, savedRecord.id}
            : currentState.newIds,
        isFromCache: false,
        cachedAt: DateTime.now(),
      );
      state = AsyncData(newState);

      // Update cache
      unawaited(_saveToCache(zoneId, newState.records));

      // Clear new indicator after delay
      if (isNew) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          final s = state.valueOrNull;
          if (s != null) {
            state = AsyncData(
              s.copyWith(newIds: s.newIds.difference({savedRecord.id})),
            );
          }
        });
      }

      return savedRecord;
    } catch (e, stack) {
      log.error(
        'DnsRecordsNotifier: Failed to ${isNew ? 'create' : 'update'} record',
        details: 'Record: ${record.name} (${record.type})',
        error: e,
        stackTrace: stack,
      );
      // Remove from saving
      state = AsyncData(
        currentState.copyWith(
          savingIds: currentState.savingIds.difference({record.id}),
        ),
      );
      rethrow;
    }
  }

  /// Delete a DNS record
  Future<bool> deleteRecord(String recordId) async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return false;

    final currentState = state.valueOrNull;
    if (currentState == null) return false;

    // Mark as deleting
    state = AsyncData(
      currentState.copyWith(
        deletingIds: {...currentState.deletingIds, recordId},
      ),
    );

    // Delay before actual delete (for animation)
    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.deleteDnsRecord(zoneId, recordId);

      if (!response.success) {
        throw Exception(
          response.errors.isNotEmpty
              ? response.errors.first.message
              : 'Failed to delete record',
        );
      }

      // Remove from list
      final updatedRecords = currentState.records.where((r) => r.id != recordId).toList();
      state = AsyncData(
        currentState.copyWith(
          records: updatedRecords,
          deletingIds: currentState.deletingIds.difference({recordId}),
          isFromCache: false,
          cachedAt: DateTime.now(),
        ),
      );

      // Update cache
      unawaited(_saveToCache(zoneId, updatedRecords));

      return true;
    } catch (e, stack) {
      log.error(
        'DnsRecordsNotifier: Failed to delete record',
        details: 'Record ID: $recordId',
        error: e,
        stackTrace: stack,
      );
      // Remove from deleting
      state = AsyncData(
        currentState.copyWith(
          deletingIds: currentState.deletingIds.difference({recordId}),
        ),
      );
      rethrow;
    }
  }

  /// Update proxy status (optimistic update)
  Future<void> updateProxy(String recordId, bool proxied) async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final record = currentState.records.firstWhere((r) => r.id == recordId);

    // Optimistic update
    final optimisticRecords = currentState.records
        .map((r) => r.id == recordId ? r.copyWith(proxied: proxied) : r)
        .toList();
    state = AsyncData(currentState.copyWith(records: optimisticRecords));

    try {
      final api = ref.read(cloudflareApiProvider);
      await api.patchDnsRecord(zoneId, recordId, {'proxied': proxied});
      log.stateChange('DnsRecordsNotifier', 'Proxy ${proxied ? 'enabled' : 'disabled'} for ${record.name}');

      // Update cache with new records
      unawaited(_saveToCache(zoneId, optimisticRecords));
    } catch (e, stack) {
      log.error(
        'DnsRecordsNotifier: Failed to update proxy',
        details: 'Record: ${record.name}, proxied: $proxied',
        error: e,
        stackTrace: stack,
      );
      // Rollback
      state = AsyncData(
        currentState.copyWith(
          records: currentState.records
              .map((r) => r.id == recordId ? record : r)
              .toList(),
        ),
      );
      rethrow;
    }
  }

  /// Set active filter
  void setFilter(String filter) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(activeFilter: filter));
  }

  /// Set search query
  void setSearchQuery(String query) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(searchQuery: query));
  }

  /// Reset filters (on zone change)
  void resetFilters() {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(activeFilter: 'All', searchQuery: ''),
    );
  }
}

/// Available record types for filter chips
const List<String> recordTypes = [
  'A',
  'AAAA',
  'CNAME',
  'TXT',
  'MX',
  'SRV',
  'NS',
  'PTR',
];
