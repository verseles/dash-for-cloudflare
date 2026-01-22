import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/pages_provider.dart';
import '../../domain/models/pages_project.dart';
import '../../domain/models/pages_deployment.dart';
import '../../../auth/providers/account_provider.dart';
import '../../../auth/domain/models/account.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';

/// Pages projects list screen
class PagesListPage extends ConsumerWidget {
  const PagesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(pagesProjectsNotifierProvider);
    final selectedAccount = ref.watch(selectedAccountNotifierProvider);
    final accountsAsync = ref.watch(accountsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pages_title),
        centerTitle: true,
        actions: [
          // Account selector
          accountsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (state) {
              if (state.accounts.length <= 1) return const SizedBox.shrink();
              return PopupMenuButton<Account>(
                icon: const Icon(Icons.account_circle_outlined),
                tooltip: l10n.pages_selectAccount,
                onSelected: (account) {
                  ref
                      .read(selectedAccountNotifierProvider.notifier)
                      .selectAccount(account);
                },
                itemBuilder: (context) => state.accounts
                    .map(
                      (account) => PopupMenuItem(
                        value: account,
                        child: Row(
                          children: [
                            if (account.id == selectedAccount?.id)
                              Icon(
                                Icons.check,
                                size: 18,
                                color: theme.colorScheme.primary,
                              )
                            else
                              const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(account.name)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, ref, error, l10n),
        data: (state) => _buildProjectsList(context, ref, state, l10n),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.error_prefix(error.toString()),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(pagesProjectsNotifierProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.common_retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList(
    BuildContext context,
    WidgetRef ref,
    PagesProjectsState state,
    AppLocalizations l10n,
  ) {
    if (state.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.web_asset_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.pages_noProjects),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(pagesProjectsNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.projects.length,
        itemBuilder: (context, index) {
          final project = state.projects[index];
          return _ProjectCard(project: project);
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final PagesProject project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd().add_Hm();

    // Get deployment status
    final latestDeployment = project.latestDeployment;
    final status = latestDeployment?.status ?? 'unknown';
    final statusColor = _getStatusColor(status, theme);
    final statusIcon = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.pushNamed(
            AppRoutes.pagesProject,
            pathParameters: {'projectName': project.name},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name + Status
              Row(
                children: [
                  const Icon(Icons.web_asset, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(status, l10n),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Production URL
              Row(
                children: [
                  Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.productionUrl,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Last deployment info
              if (latestDeployment != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.pages_lastDeployment(
                        dateFormat.format(latestDeployment.createdOn.toLocal()),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],

              // Custom domains
              if (project.hasCustomDomains) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.public,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.domains
                            .where((d) => !d.endsWith('.pages.dev'))
                            .join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failure':
        return theme.colorScheme.error;
      case 'building':
      case 'queued':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'failure':
        return Icons.error;
      case 'building':
        return Icons.sync;
      case 'queued':
        return Icons.hourglass_empty;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status) {
      case 'success':
        return l10n.pages_statusSuccess;
      case 'failure':
        return l10n.pages_statusFailed;
      case 'building':
        return l10n.pages_statusBuilding;
      case 'queued':
        return l10n.pages_statusQueued;
      default:
        return l10n.pages_statusUnknown;
    }
  }
}
