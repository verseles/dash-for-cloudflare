import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/pages_provider.dart';
import '../../domain/models/pages_project.dart';
import '../../domain/models/pages_deployment.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/error_view.dart';

/// Pages projects list screen with auto-refresh when builds are active
class PagesListPage extends ConsumerStatefulWidget {
  const PagesListPage({super.key});

  @override
  ConsumerState<PagesListPage> createState() => _PagesListPageState();
}

class _PagesListPageState extends ConsumerState<PagesListPage> {
  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 5);

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _updatePolling(List<PagesProject> projects) {
    final hasActiveBuilds = projects.any((p) {
      final deployment = p.effectiveDeployment;
      return deployment != null && deployment.isBuilding;
    });

    if (hasActiveBuilds && _pollingTimer == null) {
      // Start polling
      _pollingTimer = Timer.periodic(_pollingInterval, (_) {
        ref.read(pagesProjectsNotifierProvider.notifier).refresh();
      });
    } else if (!hasActiveBuilds && _pollingTimer != null) {
      // Stop polling
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projectsAsync = ref.watch(pagesProjectsNotifierProvider);

    // Update polling based on current state
    projectsAsync.whenData((state) => _updatePolling(state.projects));

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => CloudflareErrorView(
        error: error,
        onRetry: () => ref.read(pagesProjectsNotifierProvider.notifier).refresh(),
      ),
      data: (state) => _buildProjectsList(context, state, l10n),
    );
  }

  Widget _buildProjectsList(
    BuildContext context,
    PagesProjectsState state,
    AppLocalizations l10n,
  ) {
    if (state.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.electric_bolt, size: 64, color: Colors.grey),
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

    // Get deployment status (uses effectiveDeployment to handle skipped deploys)
    final deployment = project.effectiveDeployment;
    final status = deployment?.status ?? 'unknown';
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
                  const Icon(Symbols.electric_bolt, size: 24),
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
                      color: statusColor.withValues(alpha: 0.1),
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
                  Icon(Symbols.link, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.primaryUrl,
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
              if (deployment != null) ...[
                Row(
                  children: [
                    Icon(
                      Symbols.schedule,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.pages_lastDeployment(
                        dateFormat.format(deployment.createdOn.toLocal()),
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
                      Symbols.public,
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
      case 'skipped':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Symbols.check_circle;
      case 'failure':
        return Symbols.error;
      case 'building':
        return Symbols.sync;
      case 'queued':
        return Symbols.hourglass_empty;
      case 'skipped':
        return Symbols.skip_next;
      default:
        return Symbols.help;
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
      case 'skipped':
        return l10n.pages_statusSkipped;
      default:
        return l10n.pages_statusUnknown;
    }
  }
}
