import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/pages_provider.dart';
import '../../domain/models/pages_project.dart';
import '../../domain/models/pages_deployment.dart';
import '../widgets/pages_domains_tab.dart';
import '../widgets/pages_settings_tab.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/error_view.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pages project details page with deployments list and auto-refresh
class PagesProjectPage extends ConsumerStatefulWidget {
  const PagesProjectPage({super.key, required this.projectName});

  final String projectName;

  @override
  ConsumerState<PagesProjectPage> createState() => _PagesProjectPageState();
}

class _PagesProjectPageState extends ConsumerState<PagesProjectPage> {
  Timer? _pollingTimer;
  static const _pollingInterval = Duration(seconds: 5);

  String get projectName => widget.projectName;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _updatePolling(List<PagesDeployment> deployments) {
    final hasActiveBuilds = deployments.any((d) => d.isBuilding);

    if (hasActiveBuilds && _pollingTimer == null) {
      // Start polling
      _pollingTimer = Timer.periodic(_pollingInterval, (_) {
        ref
            .read(pagesDeploymentsNotifierProvider(projectName).notifier)
            .refresh();
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
    final deploymentsAsync = ref.watch(
      pagesDeploymentsNotifierProvider(projectName),
    );
    final projectAsync = ref.watch(pagesProjectDetailsNotifierProvider(projectName));

    // Update polling based on current state
    deploymentsAsync.whenData(_updatePolling);

    return DefaultTabController(
      length: 3,
      child: projectAsync.when(
        skipLoadingOnRefresh: true,
        loading: () => Scaffold(
          appBar: AppBar(title: Text(projectName)),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: Text(projectName)),
          body: CloudflareErrorView(
            error: err,
            onRetry: () => ref.refresh(pagesProjectDetailsNotifierProvider(projectName)),
          ),
        ),
        data: (project) => Scaffold(
          appBar: AppBar(
            title: Text(projectName),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Symbols.open_in_new),
                tooltip: l10n.pages_openInBrowser,
                onPressed: () async {
                  final url = Uri.parse(project.primaryUrl);
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: const Icon(Symbols.rocket_launch),
                  text: l10n.pages_deployments,
                ),
                Tab(
                  icon: const Icon(Symbols.language),
                  text: l10n.pages_customDomains,
                ),
                Tab(
                  icon: const Icon(Symbols.settings),
                  text: l10n.tabs_settings,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // DEPLOYMENTS TAB
              _buildDeploymentsTab(context, project, deploymentsAsync, l10n),

              // DOMAINS TAB
              PagesDomainsTab(project: project),

              // SETTINGS TAB
              PagesSettingsTab(project: project),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeploymentsTab(
    BuildContext context,
    PagesProject project,
    AsyncValue<List<PagesDeployment>> deploymentsAsync,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project info header
        _buildProjectHeader(context, project, l10n),

        const Divider(height: 1),

        // Deployments section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.pages_deployments,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),

        // Deployments list
        Expanded(
          child: deploymentsAsync.when(
            skipLoadingOnRefresh: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => CloudflareErrorView(
              error: error,
              onRetry: () => ref
                  .read(pagesDeploymentsNotifierProvider(projectName).notifier)
                  .refresh(),
            ),
            data: (deployments) =>
                _buildDeploymentsList(context, deployments, l10n),
          ),
        ),
      ],
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
                  Icon(Symbols.link, size: 18, color: theme.colorScheme.primary),
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
                    Symbols.open_in_new,
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
                Symbols.pause_circle,
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
                  Symbols.code,
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
                  Symbols.terminal,
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

  Widget _buildDeploymentsList(
    BuildContext context,
    List<PagesDeployment> deployments,
    AppLocalizations l10n,
  ) {
    if (deployments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.cloud_off, size: 48, color: Colors.grey),
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
                    const Icon(
                      Symbols.account_tree,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        branch,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (commitHash != null) ...[
                    const Icon(
                      Symbols.commit,
                      size: 14,
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
