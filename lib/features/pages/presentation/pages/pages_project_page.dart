import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/pages_provider.dart';
import '../../domain/models/pages_project.dart';
import '../../domain/models/pages_deployment.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';

/// Pages project details page with deployments list
class PagesProjectPage extends ConsumerWidget {
  const PagesProjectPage({super.key, required this.projectName});

  final String projectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final deploymentsAsync = ref.watch(
      pagesDeploymentsNotifierProvider(projectName),
    );
    final projectsState = ref.watch(pagesProjectsNotifierProvider);

    // Find project from state
    final project = projectsState.valueOrNull?.projects
        .where((p) => p.name == projectName)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(projectName),
        centerTitle: true,
        actions: [
          if (project != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: l10n.pages_openInBrowser,
              onPressed: () async {
                final url = Uri.parse(project.primaryUrl);
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project info header
          if (project != null) _buildProjectHeader(context, project, l10n),

          const Divider(height: 1),

          // Deployments section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.pages_deployments,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Deployments list
          Expanded(
            child: deploymentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildError(context, ref, error, l10n),
              data: (deployments) =>
                  _buildDeploymentsList(context, ref, deployments, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectHeader(
    BuildContext context,
    PagesProject project,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final primaryUrl = project.primaryUrl;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Production URL (clickable)
          InkWell(
            onTap: () async {
              final url = Uri.parse(primaryUrl);
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.link, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      primaryUrl,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          // Auto-deploy paused chip
          if (project.isAutoDeployPaused) ...[
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(
                Icons.pause_circle,
                size: 18,
                color: theme.colorScheme.onErrorContainer,
              ),
              label: Text(l10n.pages_autoDeployPaused),
              backgroundColor: theme.colorScheme.errorContainer,
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],

          // Source info
          if (project.hasGitSource && project.source?.config != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.code,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${project.source!.config!.owner}/${project.source!.config!.repoName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    project.source!.config!.productionBranch ?? 'main',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Build config
          if (project.buildConfig?.buildCommand != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.terminal,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.buildConfig!.buildCommand!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
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
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(l10n.error_prefix(error.toString())),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ref
                .read(pagesDeploymentsNotifierProvider(projectName).notifier)
                .refresh(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.common_retry),
          ),
        ],
      ),
    );
  }

  Widget _buildDeploymentsList(
    BuildContext context,
    WidgetRef ref,
    List<PagesDeployment> deployments,
    AppLocalizations l10n,
  ) {
    if (deployments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.pages_noDeployments),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(pagesDeploymentsNotifierProvider(projectName).notifier)
          .refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: deployments.length,
        itemBuilder: (context, index) {
          final deployment = deployments[index];
          return _DeploymentTile(
            deployment: deployment,
            projectName: projectName,
          );
        },
      ),
    );
  }
}

class _DeploymentTile extends StatelessWidget {
  const _DeploymentTile({required this.deployment, required this.projectName});

  final PagesDeployment deployment;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd().add_Hm();

    final status = deployment.status;
    final statusColor = _getStatusColor(status, theme);
    final isProduction = deployment.isProduction;

    // Get commit info
    final trigger = deployment.deploymentTrigger;
    final branch = trigger?.metadata?.branch;
    final commitHash = trigger?.metadata?.commitHash;
    final commitMessage = trigger?.metadata?.commitMessage;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.pushNamed(
            AppRoutes.pagesDeployment,
            pathParameters: {
              'projectName': projectName,
              'deploymentId': deployment.id,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Environment + Status
              Row(
                children: [
                  // Environment badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isProduction
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isProduction ? l10n.pages_production : l10n.pages_preview,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isProduction
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status
                  Icon(_getStatusIcon(status), size: 16, color: statusColor),
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

              const SizedBox(height: 8),

              // Commit info
              if (commitMessage != null)
                Text(
                  commitMessage,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 8),

              // Branch and commit hash
              Row(
                children: [
                  if (branch != null) ...[
                    Icon(
                      Icons.account_tree,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      branch,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (commitHash != null) ...[
                    Icon(
                      Icons.commit,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      commitHash.substring(0, 7),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Timestamp
                  Text(
                    dateFormat.format(deployment.createdOn.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
        return Icons.check_circle;
      case 'failure':
        return Icons.error;
      case 'building':
        return Icons.sync;
      case 'queued':
        return Icons.hourglass_empty;
      case 'skipped':
        return Icons.skip_next;
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
      case 'skipped':
        return l10n.pages_statusSkipped;
      default:
        return l10n.pages_statusUnknown;
    }
  }
}
