import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/dns_record.dart';
import './zone_provider.dart';
import '../../../core/providers/api_providers.dart';

part 'dns_records_provider.g.dart';

/// State for DNS records with additional UI state
class DnsRecordsState {
  final List<DnsRecord> records;
  final Set<String> savingIds;
  final Set<String> newIds;
  final Set<String> deletingIds;
  final String activeFilter;
  final String searchQuery;

  const DnsRecordsState({
    this.records = const [],
    this.savingIds = const {},
    this.newIds = const {},
    this.deletingIds = const {},
    this.activeFilter = 'All',
    this.searchQuery = '',
  });

  DnsRecordsState copyWith({
    List<DnsRecord>? records,
    Set<String>? savingIds,
    Set<String>? newIds,
    Set<String>? deletingIds,
    String? activeFilter,
    String? searchQuery,
  }) {
    return DnsRecordsState(
      records: records ?? this.records,
      savingIds: savingIds ?? this.savingIds,
      newIds: newIds ?? this.newIds,
      deletingIds: deletingIds ?? this.deletingIds,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
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

  @override
  FutureOr<DnsRecordsState> build() async {
    final zoneId = ref.watch(selectedZoneIdProvider);
    if (zoneId == null) {
      return const DnsRecordsState();
    }

    return _fetchRecords(zoneId);
  }

  Future<DnsRecordsState> _fetchRecords(String zoneId) async {
    final fetchId = ++_currentFetchId;
    final api = ref.read(cloudflareApiProvider);

    final response = await api.getDnsRecords(zoneId);

    // Race condition prevention
    if (_currentFetchId != fetchId) {
      throw Exception('Stale request');
    }

    if (!response.success || response.result == null) {
      throw Exception(
        response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Failed to fetch DNS records',
      );
    }

    return DnsRecordsState(records: response.result!);
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

      state = AsyncData(
        currentState.copyWith(
          records: updatedRecords,
          savingIds: currentState.savingIds.difference({record.id}),
          newIds: isNew
              ? {...currentState.newIds, savedRecord.id}
              : currentState.newIds,
        ),
      );

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
    } catch (e) {
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
      state = AsyncData(
        currentState.copyWith(
          records: currentState.records.where((r) => r.id != recordId).toList(),
          deletingIds: currentState.deletingIds.difference({recordId}),
        ),
      );

      return true;
    } catch (e) {
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
    } catch (e) {
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
