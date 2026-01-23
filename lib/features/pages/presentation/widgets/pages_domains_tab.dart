import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/models/pages_project.dart';
import '../../domain/models/pages_domain.dart';
import '../../providers/pages_provider.dart';
import '../../../../l10n/app_localizations.dart';

class PagesDomainsTab extends ConsumerWidget {
  const PagesDomainsTab({super.key, required this.project});

  final PagesProject project;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final l10n = AppLocalizations.of(context);
    final domainsAsync = widgetRef.watch(pagesDomainsNotifierProvider(project.name));

    return Column(
      children: [
        _buildHeader(context, widgetRef, l10n),
        const Divider(height: 1),
        Expanded(
          child: domainsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildError(context, widgetRef, error, l10n),
            data: (domains) => _buildDomainsList(context, widgetRef, domains, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pages_customDomains,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _showAddDomainDialog(context, ref, l10n),
            icon: const Icon(Symbols.add, size: 18),
            label: Text(l10n.pages_addDomain),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainsList(
    BuildContext context,
    WidgetRef ref,
    List<PagesDomain> domains,
    AppLocalizations l10n,
  ) {
    if (domains.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.language, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.common_noData),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(pagesDomainsNotifierProvider(project.name).notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: domains.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final domain = domains[index];
          return _DomainTile(
            domain: domain,
            projectName: project.name,
          );
        },
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    Object error,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.error, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(error.toString()),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                ref.read(pagesDomainsNotifierProvider(project.name).notifier).refresh(),
            child: Text(l10n.common_retry),
          ),
        ],
      ),
    );
  }

  void _showAddDomainDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pages_addDomain),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.record_name,
            hintText: l10n.pages_domainNameHint,
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              try {
                await ref
                    .read(pagesDomainsNotifierProvider(project.name).notifier)
                    .addDomain(controller.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pages_domainAdded)),
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
}

class _DomainTile extends ConsumerWidget {
  const _DomainTile({required this.domain, required this.projectName});

  final PagesDomain domain;
  final String projectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        title: Text(domain.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            _buildStatusChip(domain.status, theme),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Symbols.delete),
          onPressed: () => _confirmDelete(context, ref, l10n),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    final color = status == 'active' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pages_deleteDomainConfirmTitle),
        content: Text(l10n.pages_deleteDomainConfirmMessage(domain.name)),
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
                    .read(pagesDomainsNotifierProvider(projectName).notifier)
                    .deleteDomain(domain.name);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pages_domainDeleted)),
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
}
