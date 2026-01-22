import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/pages_provider.dart';
import '../../domain/models/pages_deployment.dart';
import '../../../../l10n/app_localizations.dart';

/// Deployment details page with stages and rollback action
class DeploymentDetailsPage extends ConsumerWidget {
  const DeploymentDetailsPage({
    super.key,
    required this.projectName,
    required this.deploymentId,
  });

  final String projectName;
  final String deploymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final deploymentsAsync = ref.watch(
      pagesDeploymentsNotifierProvider(projectName),
    );

    // Find deployment from state
    final deployment = deploymentsAsync.valueOrNull
        ?.where((d) => d.id == deploymentId)
        .firstOrNull;

    if (deployment == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.pages_deploymentDetails)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pages_deploymentDetails),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            _buildStatusCard(context, deployment, l10n),

            const SizedBox(height: 16),

            // Commit info card
            _buildCommitCard(context, deployment, l10n),

            const SizedBox(height: 16),

            // Stages
            _buildStagesSection(context, deployment, l10n),

            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context, ref, deployment, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    PagesDeployment deployment,
    AppLocalizations l10n,
  ) {
    final retryState = ref.watch(retryNotifierProvider);
    final rollbackState = ref.watch(rollbackNotifierProvider);

    return Row(
      children: [
        // Retry button (for all deployments)
        Expanded(
          child: OutlinedButton.icon(
            onPressed: retryState.isLoading
                ? null
                : () => _showRetryDialog(context, ref, deployment, l10n),
            icon: retryState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(l10n.pages_retry),
          ),
        ),

        // Rollback button (only for production deployments)
        if (deployment.isProduction) ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: rollbackState.isLoading
                  ? null
                  : () => _showRollbackDialog(context, ref, deployment, l10n),
              icon: rollbackState.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.history),
              label: Text(l10n.pages_rollback),
            ),
          ),
        ],
      ],
    );
  }

  void _showRetryDialog(
    BuildContext context,
    WidgetRef ref,
    PagesDeployment deployment,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pages_retryConfirmTitle),
        content: Text(l10n.pages_retryConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(retryNotifierProvider.notifier)
                  .retry(projectName: projectName, deploymentId: deploymentId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.pages_retrySuccess)),
                );
              }
            },
            child: Text(l10n.pages_retry),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    PagesDeployment deployment,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd().add_Hm();
    final status = deployment.status;
    final statusColor = _getStatusColor(status, theme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Row(
              children: [
                Icon(_getStatusIcon(status), color: statusColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  _getStatusText(status, l10n),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: deployment.isProduction
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    deployment.isProduction
                        ? l10n.pages_production
                        : l10n.pages_preview,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // URL
            Row(
              children: [
                Icon(Icons.link, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    deployment.url,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Timestamp
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(deployment.createdOn.toLocal()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitCard(
    BuildContext context,
    PagesDeployment deployment,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final trigger = deployment.deploymentTrigger;
    final metadata = trigger?.metadata;

    if (metadata == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pages_commitInfo,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (metadata.commitMessage != null) ...[
              Text(metadata.commitMessage!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                if (metadata.branch != null) ...[
                  Icon(
                    Icons.account_tree,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    metadata.branch!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (metadata.commitHash != null) ...[
                  Icon(
                    Icons.commit,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    metadata.commitHash!.substring(0, 7),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStagesSection(
    BuildContext context,
    PagesDeployment deployment,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pages_buildStages,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        ...deployment.stages.map((stage) => _StageItem(stage: stage)),
      ],
    );
  }

  void _showRollbackDialog(
    BuildContext context,
    WidgetRef ref,
    PagesDeployment deployment,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pages_rollbackConfirmTitle),
        content: Text(l10n.pages_rollbackConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(rollbackNotifierProvider.notifier)
                  .rollback(
                    projectName: projectName,
                    deploymentId: deploymentId,
                  );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.pages_rollbackSuccess)),
                );
              }
            },
            child: Text(l10n.pages_rollback),
          ),
        ],
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

class _StageItem extends StatelessWidget {
  const _StageItem({required this.stage});

  final DeploymentStage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(stage.status, theme);
    final duration = _getDuration();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(_getStatusIcon(stage.status), size: 20, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getStageName(stage.name),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (duration != null)
            Text(
              duration,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  String? _getDuration() {
    if (stage.startedOn == null || stage.endedOn == null) return null;
    final duration = stage.endedOn!.difference(stage.startedOn!);
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
    return '${duration.inSeconds}s';
  }

  String _getStageName(String name) {
    switch (name) {
      case 'queued':
        return 'Queued';
      case 'initialize':
        return 'Initialize';
      case 'clone_repo':
        return 'Clone Repository';
      case 'build':
        return 'Build';
      case 'deploy':
        return 'Deploy';
      default:
        return name
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (w) =>
                  w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w,
            )
            .join(' ');
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failure':
        return theme.colorScheme.error;
      case 'active':
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
      case 'active':
        return Icons.sync;
      case 'skipped':
        return Icons.skip_next;
      case 'queued':
        return Icons.hourglass_empty;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}
