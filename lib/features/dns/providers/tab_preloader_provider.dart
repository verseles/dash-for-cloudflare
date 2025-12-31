import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import './zone_provider.dart';
import './dns_records_provider.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../../core/logging/log_service.dart';

part 'tab_preloader_provider.g.dart';

/// Tracks which tab is currently active
/// 0 = Records, 1 = Analytics, 2 = Settings
@riverpod
class ActiveTabIndex extends _$ActiveTabIndex {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

/// Preloads tab data when zone changes
/// Priority: current tab first, then others in background
@riverpod
class TabPreloader extends _$TabPreloader {
  Timer? _preloadTimer;

  @override
  void build() {
    // Listen for zone changes
    ref.listen(selectedZoneIdProvider, (previous, next) {
      if (next != null && next != previous) {
        _onZoneChanged(next);
      }
    });

    // Cleanup timer on dispose
    ref.onDispose(() {
      _preloadTimer?.cancel();
    });
  }

  /// Called when selected zone changes
  void _onZoneChanged(String zoneId) {
    final activeTab = ref.read(activeTabIndexProvider);
    log.stateChange(
      'TabPreloader',
      'Zone changed to $zoneId, active tab: $activeTab',
    );

    // Cancel any pending preload
    _preloadTimer?.cancel();

    // Load current tab immediately (providers auto-fetch on zone change)
    // Then preload other tabs in background after delay
    _preloadTimer = Timer(const Duration(milliseconds: 800), () {
      _preloadOtherTabs(activeTab);
    });
  }

  /// Preload tabs that are not currently active
  void _preloadOtherTabs(int activeTab) {
    log.stateChange(
      'TabPreloader',
      'Preloading other tabs (active: $activeTab)',
    );

    // Records tab (0): DnsRecordsNotifier auto-fetches on zone change
    // Analytics tab (1): AnalyticsNotifier auto-fetches on zone change
    // Settings tab (2): ZoneSettingsNotifier needs to be triggered

    // The providers already auto-fetch when zone changes, but we ensure
    // they're initialized by reading them
    if (activeTab != 0) {
      // Ensure records provider is active
      ref.read(dnsRecordsNotifierProvider);
    }

    if (activeTab != 1) {
      // Ensure analytics provider is active
      ref.read(analyticsNotifierProvider);
    }

    // Settings tab doesn't need preloading (zone info already in zonesNotifierProvider)
  }

  /// Force preload all tabs (useful after login or app resume)
  void preloadAll() {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    log.stateChange('TabPreloader', 'Force preloading all tabs');

    // Trigger all providers
    ref.read(dnsRecordsNotifierProvider);
    ref.read(analyticsNotifierProvider);
  }
}

/// Initialize tab preloader early in the widget tree
/// Place this widget near the root of the DNS section
class TabPreloaderInitializer extends StatelessWidget {
  const TabPreloaderInitializer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
