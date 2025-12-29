import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/dns_settings.dart';
import './zone_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';

part 'dns_settings_provider.g.dart';

/// State for DNS zone settings
class DnsZoneSettingsState {
  const DnsZoneSettingsState({
    this.dnssec,
    this.dnsSettings,
    this.zoneSettings = const [],
    this.isLoading = false,
    this.error,
  });

  final DnssecDetails? dnssec;
  final DnsZoneSettings? dnsSettings;
  final List<DnsSetting> zoneSettings;
  final bool isLoading;
  final String? error;

  DnsZoneSettingsState copyWith({
    DnssecDetails? dnssec,
    DnsZoneSettings? dnsSettings,
    List<DnsSetting>? zoneSettings,
    bool? isLoading,
    String? error,
  }) {
    return DnsZoneSettingsState(
      dnssec: dnssec ?? this.dnssec,
      dnsSettings: dnsSettings ?? this.dnsSettings,
      zoneSettings: zoneSettings ?? this.zoneSettings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Check if CNAME flattening is enabled
  String? get cnameFlattening {
    final setting = zoneSettings
        .where((s) => s.id == 'cname_flattening')
        .firstOrNull;
    return setting?.value as String?;
  }
}

/// DNS Settings notifier - manages DNSSEC, multi-provider, etc.
@riverpod
class DnsSettingsNotifier extends _$DnsSettingsNotifier {
  @override
  FutureOr<DnsZoneSettingsState> build() async {
    final zoneId = ref.watch(selectedZoneIdProvider);
    if (zoneId == null) {
      return const DnsZoneSettingsState();
    }

    return _fetchSettings(zoneId);
  }

  Future<DnsZoneSettingsState> _fetchSettings(String zoneId) async {
    log.stateChange('DnsSettingsNotifier', 'Fetching settings for zone $zoneId');

    try {
      final api = ref.read(cloudflareApiProvider);

      // Fetch all settings in parallel
      final results = await Future.wait([
        api.getDnssec(zoneId),
        api.getDnsZoneSettings(zoneId),
        api.getSettings(zoneId),
      ]);

      final dnssecResponse = results[0] as dynamic;
      final dnsSettingsResponse = results[1] as dynamic;
      final zoneSettingsResponse = results[2] as dynamic;

      log.stateChange('DnsSettingsNotifier', 'Settings fetched, DNSSEC status: ${dnssecResponse.result?.status}');

      return DnsZoneSettingsState(
        dnssec: dnssecResponse.result,
        dnsSettings: dnsSettingsResponse.result,
        zoneSettings: zoneSettingsResponse.result ?? [],
      );
    } catch (e, stack) {
      log.error('DnsSettingsNotifier: Failed to fetch settings', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Refresh all settings
  Future<void> refresh() async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchSettings(zoneId));
  }

  /// Enable or disable DNSSEC
  Future<void> toggleDnssec({required bool enable}) async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(isLoading: true));

    try {
      final api = ref.read(cloudflareApiProvider);
      log.stateChange('DnsSettingsNotifier', 'Toggling DNSSEC: ${enable ? 'enable' : 'disable'}');
      await api.updateDnssec(zoneId, {
        'status': enable ? 'active' : 'disabled',
      });

      // Polling for status update
      await Future.delayed(const Duration(seconds: 3));
      await refresh();
      await Future.delayed(const Duration(seconds: 2));
      await refresh();
    } catch (e, stack) {
      log.error('DnsSettingsNotifier: Failed to toggle DNSSEC', error: e, stackTrace: stack);
      state = AsyncData(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// Toggle multi-signer DNSSEC
  Future<void> toggleMultiSignerDnssec({required bool enable}) async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(isLoading: true));

    try {
      final api = ref.read(cloudflareApiProvider);
      log.stateChange('DnsSettingsNotifier', 'Toggling multi-signer DNSSEC: $enable');
      await api.updateDnssec(zoneId, {'dnssec_multi_signer': enable});
      await refresh();
    } catch (e, stack) {
      log.error('DnsSettingsNotifier: Failed to toggle multi-signer DNSSEC', error: e, stackTrace: stack);
      state = AsyncData(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// Toggle multi-provider DNS
  Future<void> toggleMultiProvider({required bool enable}) async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(isLoading: true));

    try {
      final api = ref.read(cloudflareApiProvider);
      log.stateChange('DnsSettingsNotifier', 'Toggling multi-provider DNS: $enable');
      await api.updateDnsZoneSettings(zoneId, {'multi_provider': enable});
      await refresh();
    } catch (e, stack) {
      log.error('DnsSettingsNotifier: Failed to toggle multi-provider DNS', error: e, stackTrace: stack);
      state = AsyncData(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  /// Toggle CNAME flattening
  Future<void> toggleCnameFlattening({required String value}) async {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(isLoading: true));

    try {
      final api = ref.read(cloudflareApiProvider);
      log.stateChange('DnsSettingsNotifier', 'Setting CNAME flattening: $value');
      await api.updateSetting(zoneId, 'cname_flattening', {'value': value});
      await refresh();
    } catch (e, stack) {
      log.error('DnsSettingsNotifier: Failed to toggle CNAME flattening', error: e, stackTrace: stack);
      state = AsyncData(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }
}
