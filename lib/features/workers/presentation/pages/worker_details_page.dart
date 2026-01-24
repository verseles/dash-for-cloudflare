import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../providers/workers_provider.dart';
import '../../providers/worker_preloader_provider.dart';
import '../widgets/worker_overview_tab.dart';
import '../widgets/worker_triggers_tab.dart';
import '../widgets/worker_settings_tab.dart';
import '../../../../l10n/app_localizations.dart';

class WorkerDetailsPage extends ConsumerWidget {
  const WorkerDetailsPage({super.key, required this.workerName});

  final String workerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    // Initialize preloader and set selected worker
    ref.watch(workerTabPreloaderProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(selectedWorkerNameProvider) != workerName) {
        ref.read(selectedWorkerNameProvider.notifier).set(workerName);
      }
    });

    final workersAsync = ref.watch(workersNotifierProvider);
    
    // Find worker in state
    final worker = workersAsync.maybeWhen(
      data: (state) => state.workers.where((w) => w.id == workerName).firstOrNull,
      orElse: () => null,
    );

    if (worker == null) {
      return Scaffold(
        appBar: AppBar(title: Text(workerName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(workerName),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Symbols.dashboard, fill: 0),
                text: l10n.workers_tabs_overview,
              ),
              Tab(
                icon: const Icon(Symbols.bolt, fill: 0),
                text: l10n.workers_tabs_triggers,
              ),
              Tab(
                icon: const Icon(Symbols.settings, fill: 0),
                text: l10n.workers_tabs_settings,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WorkerOverviewTab(worker: worker),
            WorkerTriggersTab(worker: worker),
            WorkerSettingsTab(worker: worker),
          ],
        ),
      ),
    );
  }
}