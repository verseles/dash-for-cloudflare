import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../providers/workers_provider.dart';
import '../../domain/models/worker.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/error_view.dart';

class WorkersListPage extends ConsumerWidget {
  const WorkersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final workersAsync = ref.watch(workersNotifierProvider);
    final filteredWorkersList = ref.watch(filteredWorkersProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.workers_searchWorkers,
                prefixIcon: const Icon(Symbols.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) =>
                  ref.read(workerSearchNotifierProvider.notifier).update(value),
            ),
          ),

          // List
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: workersAsync.when(
                loading: () => const Center(
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => CloudflareErrorView(
                  key: const ValueKey('error'),
                  error: error,
                  onRetry: () => ref.read(workersNotifierProvider.notifier).refresh(),
                ),
                data: (state) {
                  if (state.workers.isEmpty && !state.isRefreshing) {
                    return KeyedSubtree(
                      key: const ValueKey('empty'),
                      child: _buildEmptyState(context, l10n),
                    );
                  }

                  return Column(
                    key: const ValueKey('data'),
                    children: [
                      if (state.isRefreshing)
                        const LinearProgressIndicator(minHeight: 2),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => ref.read(workersNotifierProvider.notifier).refresh(),
                          child: filteredWorkersList.isEmpty && !state.isRefreshing
                              ? Center(child: Text(l10n.emptyState_tryAdjustingSearch))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: filteredWorkersList.length,
                                  itemBuilder: (context, index) {
                                    final worker = filteredWorkersList[index];
                                    return _WorkerCard(worker: worker)
                                        .animate()
                                        .fadeIn(duration: 300.ms)
                                        .slideY(
                                          begin: 0.1,
                                          duration: 300.ms,
                                          curve: Curves.easeOutCubic,
                                          delay: (50 * index.clamp(0, 10)).ms,
                                        );
                                  },
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const RotatedBox(
            quarterTurns: 3,
            child: Icon(Symbols.layers, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(l10n.workers_noWorkers),
        ],
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.pushNamed(
            AppRoutes.workerDetails,
            pathParameters: {'workerName': worker.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      worker.id,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildHandlerIcons(worker),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Symbols.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    l10n.workers_lastModified(dateFormat.format(worker.modifiedOn.toLocal())),
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              if (worker.lastDeployedFrom != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Symbols.rocket_launch, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      worker.lastDeployedFrom!,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandlerIcons(Worker worker) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (worker.hasFetchHandler)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Symbols.http, size: 18, color: Colors.blue),
          ),
        if (worker.hasScheduledHandler)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Symbols.alarm, size: 18, color: Colors.orange),
          ),
      ],
    );
  }
}