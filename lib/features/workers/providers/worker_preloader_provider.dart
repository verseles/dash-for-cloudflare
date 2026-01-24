import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import './workers_provider.dart';
import '../../../features/dns/providers/zone_provider.dart';
import '../../../core/logging/log_service.dart';

part 'worker_preloader_provider.g.dart';

/// Tracks which worker is currently being viewed
@riverpod
class SelectedWorkerName extends _$SelectedWorkerName {
  @override
  String? build() => null;

  void set(String? name) => state = name;
}

/// Preloads worker details, schedules, and routes in background
@riverpod
class WorkerTabPreloader extends _$WorkerTabPreloader {
  Timer? _preloadTimer;

  @override
  void build() {
    // Listen for worker selection changes
    ref.listen(selectedWorkerNameProvider, (previous, next) {
      if (next != null && next != previous) {
        _onWorkerSelected(next);
      }
    });

    ref.onDispose(() => _preloadTimer?.cancel());
  }

  void _onWorkerSelected(String workerName) {
    log.stateChange('WorkerTabPreloader', 'Worker selected: $workerName. Preloading tabs...');
    
    _preloadTimer?.cancel();
    _preloadTimer = Timer(const Duration(milliseconds: 500), () {
      _preloadAll(workerName);
    });
  }

  void _preloadAll(String workerName) {
    log.info('WorkerTabPreloader: Executing background preload for $workerName');

    // 1. Preload Settings (Bindings, Variables)
    ref.read(workerDetailsNotifierProvider(workerName));

    // 2. Preload Schedules (Cron Triggers)
    ref.read(workerSchedulesNotifierProvider(workerName));

    // 3. Preload Custom Domains (Account-scoped)
    ref.read(workerDomainsNotifierProvider);

    // 4. Preload Routes if a zone is currently selected
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId != null) {
      ref.read(workerRoutesNotifierProvider(zoneId));
    }
  }
}
