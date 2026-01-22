import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/account.dart';
import 'settings_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import '../../../core/logging/log_level.dart';

part 'account_provider.g.dart';

/// Cache expiration duration (3 days)
const _cacheMaxAge = Duration(days: 3);

/// State for accounts with cache metadata
class AccountsState {
  const AccountsState({
    this.accounts = const [],
    this.isFromCache = false,
    this.isRefreshing = false,
    this.cachedAt,
  });

  final List<Account> accounts;
  final bool isFromCache;
  final bool isRefreshing;
  final DateTime? cachedAt;

  AccountsState copyWith({
    List<Account>? accounts,
    bool? isFromCache,
    bool? isRefreshing,
    DateTime? cachedAt,
  }) {
    return AccountsState(
      accounts: accounts ?? this.accounts,
      isFromCache: isFromCache ?? this.isFromCache,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

/// Provider for fetching and caching accounts (ADR-022 pattern)
@riverpod
class AccountsNotifier extends _$AccountsNotifier {
  SharedPreferences? _prefs;

  static const _cacheKey = 'accounts_cache';
  static const _cacheTimeKey = 'accounts_cache_time';

  @override
  FutureOr<AccountsState> build() async {
    // Only fetch if we have a valid token
    final hasToken = ref.watch(hasValidTokenProvider);
    if (!hasToken) {
      log.info(
        'AccountsNotifier: No valid token, returning empty list',
        category: LogCategory.state,
      );
      return const AccountsState();
    }

    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Try to load from cache first
    final cachedState = await _loadFromCache();
    if (cachedState != null) {
      // Return cached data and refresh in background
      unawaited(_refreshInBackground(cachedState));
      return cachedState;
    }

    // No cache, fetch from API
    return _fetchAccounts();
  }

  Future<AccountsState?> _loadFromCache() async {
    try {
      final cachedJson = _prefs?.getString(_cacheKey);
      final cachedTimeStr = _prefs?.getString(_cacheTimeKey);

      if (cachedJson == null || cachedTimeStr == null) return null;

      final cachedTime = DateTime.parse(cachedTimeStr);
      final age = DateTime.now().difference(cachedTime);

      // Check if cache is still valid
      if (age > _cacheMaxAge) {
        log.info(
          'AccountsNotifier: Cache expired (${age.inDays} days old)',
          category: LogCategory.state,
        );
        return null;
      }

      final List<dynamic> accountsJson =
          json.decode(cachedJson) as List<dynamic>;
      final accounts = accountsJson
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList();

      log.info(
        'AccountsNotifier: Loaded ${accounts.length} accounts from cache (${age.inMinutes} minutes old)',
        category: LogCategory.state,
      );

      return AccountsState(
        accounts: accounts,
        isFromCache: true,
        cachedAt: cachedTime,
      );
    } catch (e, stack) {
      log.warning(
        'AccountsNotifier: Failed to load cache',
        details: e.toString(),
      );
      log.error('AccountsNotifier: Cache error', error: e, stackTrace: stack);
      return null;
    }
  }

  Future<void> _saveToCache(List<Account> accounts) async {
    try {
      final accountsJson = accounts.map((a) => a.toJson()).toList();
      await _prefs?.setString(_cacheKey, json.encode(accountsJson));
      await _prefs?.setString(_cacheTimeKey, DateTime.now().toIso8601String());
      log.info(
        'AccountsNotifier: Saved ${accounts.length} accounts to cache',
        category: LogCategory.state,
      );
    } catch (e) {
      log.warning(
        'AccountsNotifier: Failed to save cache',
        details: e.toString(),
      );
    }
  }

  Future<void> _refreshInBackground(AccountsState currentState) async {
    // Mark as refreshing
    state = AsyncData(currentState.copyWith(isRefreshing: true));

    try {
      final freshState = await _fetchAccountsFromApi();
      state = AsyncData(freshState);
    } catch (e) {
      // Keep showing cached data on error
      log.warning(
        'AccountsNotifier: Background refresh failed, keeping cache',
        details: e.toString(),
      );
      state = AsyncData(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<AccountsState> _fetchAccounts() async {
    return _fetchAccountsFromApi();
  }

  Future<AccountsState> _fetchAccountsFromApi() async {
    log.stateChange('AccountsNotifier', 'Fetching accounts...');

    try {
      final api = ref.read(cloudflareApiProvider);
      final response = await api.getAccounts();

      if (!response.success || response.result == null) {
        final error = response.errors.isNotEmpty
            ? response.errors.first.message
            : 'Failed to fetch accounts';
        log.error('Failed to fetch accounts', details: error);
        throw Exception(error);
      }

      final accounts = response.result!;
      log.stateChange(
        'AccountsNotifier',
        'Fetched ${accounts.length} accounts',
      );

      // Save to cache
      unawaited(_saveToCache(accounts));

      return AccountsState(
        accounts: accounts,
        isFromCache: false,
        cachedAt: DateTime.now(),
      );
    } catch (e, stack) {
      log.error(
        'AccountsNotifier: Exception fetching accounts',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Refresh accounts list
  Future<void> refresh() async {
    log.stateChange('AccountsNotifier', 'Refreshing accounts');
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAccounts);
  }
}

/// Provider for the currently selected account
@riverpod
class SelectedAccountNotifier extends _$SelectedAccountNotifier {
  @override
  Account? build() {
    // Watch accounts to get the list
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    final accounts = accountsAsync.valueOrNull?.accounts ?? [];
    final savedAccountId = settings.valueOrNull?.selectedAccountId;

    if (accounts.isEmpty) return null;

    // Try to find saved account
    if (savedAccountId != null) {
      final savedAccount = accounts
          .where((a) => a.id == savedAccountId)
          .firstOrNull;
      if (savedAccount != null) return savedAccount;
    }

    // Auto-select first account if none saved or saved not found
    return accounts.first;
  }

  /// Select an account and persist
  Future<void> selectAccount(Account account) async {
    state = account;
    await ref
        .read(settingsNotifierProvider.notifier)
        .setSelectedAccountId(account.id);
  }

  /// Clear selection
  Future<void> clearSelection() async {
    state = null;
    await ref
        .read(settingsNotifierProvider.notifier)
        .setSelectedAccountId(null);
  }
}

/// Convenient provider for selected account ID
@riverpod
String? selectedAccountId(Ref ref) {
  return ref.watch(selectedAccountNotifierProvider)?.id;
}
