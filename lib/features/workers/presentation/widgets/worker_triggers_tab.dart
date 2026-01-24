import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/models/worker.dart';
import '../../domain/models/worker_route.dart';
import '../../domain/models/worker_domain.dart';
import '../../providers/workers_provider.dart';
import '../../../../features/dns/providers/zone_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/error_view.dart';

class WorkerTriggersTab extends ConsumerWidget {
  const WorkerTriggersTab({super.key, required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final schedulesAsync = ref.watch(workerSchedulesNotifierProvider(worker.id));
    final customDomainsAsync = ref.watch(workerDomainsNotifierProvider);
    
    // Fetch routes if zone is selected
    final routesAsync = selectedZone != null 
        ? ref.watch(workerRoutesNotifierProvider(selectedZone.id))
        : const AsyncData(<WorkerRoute>[]);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // CUSTOM DOMAINS (Account-scoped)
        _buildHeader(
          context,
          l10n.workers_triggers_customDomains,
          Symbols.language,
          onAdd: () => _showAddDomainDialog(context, ref, l10n),
        ),
        const SizedBox(height: 8),
        customDomainsAsync.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CloudflareErrorView(
              error: err,
              onRetry: () => ref.refresh(workerDomainsNotifierProvider),
            ),
          ),
          data: (domains) {
            final workerDomains = domains.where((d) => d.service == worker.id).toList();
            if (workerDomains.isEmpty) {
              return _buildInfoBox(context, l10n.common_noData);
            }
            return Column(
              children: workerDomains.map((d) => _buildDomainCard(context, ref, d, l10n)).toList(),
            );
          },
        ),

        const SizedBox(height: 32),
        // ROUTES (Zone-scoped)
        _buildHeader(
          context,
          l10n.workers_triggers_routes,
          Symbols.alt_route,
          onAdd: selectedZone != null ? () => _showAddRouteDialog(context, ref, selectedZone.id, l10n) : null,
        ),
        const SizedBox(height: 8),
        if (selectedZone == null)
          _buildInfoBox(context, l10n.analytics_selectZone)
        else
          routesAsync.when(
            skipLoadingOnRefresh: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CloudflareErrorView(
                error: err,
                onRetry: () => ref.refresh(workerRoutesNotifierProvider(selectedZone.id)),
              ),
            ),
            data: (routes) {
              final workerRoutes = routes.where((r) => r.script == worker.id).toList();
              if (workerRoutes.isEmpty) {
                return _buildInfoBox(context, l10n.workers_triggers_noRoutes);
              }
              return Column(
                children: workerRoutes.map((r) => _buildRouteCard(context, ref, r, l10n)).toList(),
              );
            },
          ),
        
        const SizedBox(height: 32),
        // CRON TRIGGERS (Account-scoped)
        _buildHeader(context, l10n.workers_triggers_cron, Symbols.schedule),
        const SizedBox(height: 8),
        schedulesAsync.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CloudflareErrorView(
              error: err,
              onRetry: () => ref.refresh(workerSchedulesNotifierProvider(worker.id)),
            ),
          ),
          data: (schedules) {
            if (schedules.isEmpty) {
              return _buildInfoBox(context, l10n.workers_triggers_noSchedules);
            }
            return Column(
              children: schedules.map((s) => _buildScheduleCard(context, s)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onAdd,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        if (onAdd != null)
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Symbols.add, size: 20),
            visualDensity: VisualDensity.compact,
            tooltip: 'Add',
          ),
      ],
    );
  }

  Widget _buildInfoBox(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isError ? Colors.red : Colors.grey.shade700,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDomainCard(
    BuildContext context,
    WidgetRef ref,
    WorkerDomain domain,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Symbols.link, size: 20),
        title: Text(
          domain.hostname,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(domain.zoneName, style: const TextStyle(fontSize: 12)),
        dense: true,
        trailing: IconButton(
          icon: const Icon(Symbols.delete, size: 18),
          onPressed: () => _confirmDeleteDomain(context, ref, domain, l10n),
        ),
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    WidgetRef ref,
    WorkerRoute route,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Symbols.alt_route, size: 20),
        title: Text(
          route.pattern,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
        dense: true,
        trailing: IconButton(
          icon: const Icon(Symbols.delete, size: 18),
          onPressed: () => _confirmDeleteRoute(context, ref, route, l10n),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, dynamic schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Symbols.alarm, size: 20, color: Colors.orange),
        title: Text(
          schedule.cron,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_parseCron(schedule.cron)),
        dense: true,
      ),
    );
  }

  void _showAddDomainDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final hostnameController = TextEditingController();
    final zonesAsync = ref.read(zonesNotifierProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.workers_triggers_addDomain),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hostnameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Hostname',
                hintText: l10n.pages_domainNameHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Domain must be managed by Cloudflare.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () async {
              final hostname = hostnameController.text.trim();
              if (hostname.isEmpty) return;

              // Find zone ID from hostname (naive check)
              final zones = zonesAsync.valueOrNull?.zones ?? [];
              final zone = zones.where((z) => hostname.endsWith(z.name)).firstOrNull;

              if (zone == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Zone not found for this hostname.')),
                );
                return;
              }

              Navigator.pop(context);
              try {
                await ref.read(workerDomainsNotifierProvider.notifier).addDomain(
                      hostname: hostname,
                      service: worker.id,
                      zoneId: zone.id,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.workers_triggers_domainAdded)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text(l10n.common_add),
          ),
        ],
      ),
    );
  }

  void _showAddRouteDialog(
    BuildContext context,
    WidgetRef ref,
    String zoneId,
    AppLocalizations l10n,
  ) {
    final patternController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.workers_triggers_addRoute),
        content: TextField(
          controller: patternController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.workers_triggers_routePattern,
            hintText: l10n.workers_triggers_routePatternHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (patternController.text.isEmpty) return;
              Navigator.pop(context);
              try {
                await ref
                    .read(workerRoutesNotifierProvider(zoneId).notifier)
                    .addRoute(
                      pattern: patternController.text.trim(),
                      script: worker.id,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.workers_triggers_routeAdded)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text(l10n.common_add),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDomain(
    BuildContext context,
    WidgetRef ref,
    WorkerDomain domain,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.common_delete),
        content: Text(l10n.workers_triggers_deleteDomainConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(workerDomainsNotifierProvider.notifier)
                    .deleteDomain(domain.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.workers_triggers_domainDeleted)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRoute(
    BuildContext context,
    WidgetRef ref,
    WorkerRoute route,
    AppLocalizations l10n,
  ) {
    final zoneId = ref.read(selectedZoneIdProvider);
    if (zoneId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.common_delete),
        content: Text(l10n.workers_triggers_deleteRouteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(workerRoutesNotifierProvider(zoneId).notifier)
                    .deleteRoute(route.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.workers_triggers_routeDeleted)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
  }

  String _parseCron(String cron) {
    if (cron == '*/5 * * * *') return 'Every 5 minutes';
    if (cron == '0 * * * *') return 'Every hour';
    if (cron == '0 0 * * *') return 'Daily at midnight';
    if (cron.startsWith('0 0 * *')) return 'Weekly';
    return 'Scheduled Trigger';
  }
}
