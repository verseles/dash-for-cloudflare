import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/models/pages_project.dart';
import '../../providers/pages_provider.dart';
import '../../../../core/providers/resource_providers.dart';
import '../../../../l10n/app_localizations.dart';

class PagesSettingsTab extends ConsumerStatefulWidget {
  const PagesSettingsTab({super.key, required this.project});

  final PagesProject project;

  @override
  ConsumerState<PagesSettingsTab> createState() => _PagesSettingsTabState();
}

class _PagesSettingsTabState extends ConsumerState<PagesSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isDeleting = false;

  // Build Settings Controllers
  late TextEditingController _buildCommandController;
  late TextEditingController _destinationDirController;
  late TextEditingController _rootDirController;
  late bool _buildCache;

  // Git Settings
  late TextEditingController _productionBranchController;
  late bool _deploymentsEnabled; // Automatic deployments
  late bool _productionDeploymentEnabled;
  late bool _prCommentsEnabled;

  // Build System
  String? _buildSystemVersion;

  // Runtime Settings
  late TextEditingController _compatibilityDateController;
  late String _placementMode;
  late String _usageModel;

  // Focus Nodes for blur detection
  late FocusNode _buildFocusNode;
  late FocusNode _destFocusNode;
  late FocusNode _rootFocusNode;
  late FocusNode _prodBranchFocusNode;
  late FocusNode _compatibilityDateFocusNode;

  // Environment Variables
  late Map<String, EnvVar> _productionEnvs;
  late Map<String, EnvVar> _previewEnvs;

  // Bindings (Production)
  late Map<String, PagesBinding> _kvBindings;
  late Map<String, PagesBinding> _r2Bindings;
  late Map<String, PagesBinding> _d1Bindings;
  late Map<String, PagesBinding> _serviceBindings;
  late Map<String, PagesBinding> _aiBindings;

  @override
  void initState() {
    super.initState();
    final config = widget.project.buildConfig;
    final sourceConfig = widget.project.source?.config;
    final prodConfig = widget.project.deploymentConfigs?.production;

    _buildCommandController = TextEditingController(
      text: config?.buildCommand ?? '',
    );
    _destinationDirController = TextEditingController(
      text: config?.destinationDir ?? '',
    );
    _rootDirController = TextEditingController(text: config?.rootDir ?? '');
    _buildCache = config?.buildCache ?? true;
    
    // Git init
    _productionBranchController = TextEditingController(
      text: sourceConfig?.productionBranch ?? 'main',
    );
    _deploymentsEnabled = sourceConfig?.deploymentsEnabled ?? true;
    _productionDeploymentEnabled = sourceConfig?.productionDeploymentEnabled ?? true;
    _prCommentsEnabled = sourceConfig?.prCommentsEnabled ?? true;

    // Build System init
    _buildSystemVersion = config?.buildSystemVersion ?? '2';

    // Runtime init
    _compatibilityDateController = TextEditingController(
      text: prodConfig?.compatibilityDate ?? '2024-01-01',
    );
    _placementMode = prodConfig?.placement?.mode ?? 'default';
    _usageModel = prodConfig?.usageModel ?? 'bundled';

    _buildFocusNode = FocusNode()..addListener(() => _onBlur(_buildFocusNode));
    _destFocusNode = FocusNode()..addListener(() => _onBlur(_destFocusNode));
    _rootFocusNode = FocusNode()..addListener(() => _onBlur(_rootFocusNode));
    _prodBranchFocusNode = FocusNode()..addListener(() => _onBlur(_prodBranchFocusNode));
    _compatibilityDateFocusNode = FocusNode()..addListener(() => _onBlur(_compatibilityDateFocusNode));

    _productionEnvs = Map.from(
      widget.project.deploymentConfigs?.production.envVars ?? {},
    );
    _previewEnvs = Map.from(
      widget.project.deploymentConfigs?.preview.envVars ?? {},
    );

    _kvBindings = Map.from(prodConfig?.kvNamespaces ?? {});
    _r2Bindings = Map.from(prodConfig?.r2Buckets ?? {});
    _d1Bindings = Map.from(prodConfig?.d1Databases ?? {});
    _serviceBindings = Map.from(prodConfig?.services ?? {});
    _aiBindings = Map.from(prodConfig?.aiBindings ?? {});
  }

  @override
  void dispose() {
    _buildFocusNode.dispose();
    _destFocusNode.dispose();
    _rootFocusNode.dispose();
    _prodBranchFocusNode.dispose();
    _compatibilityDateFocusNode.dispose();
    _buildCommandController.dispose();
    _destinationDirController.dispose();
    _rootDirController.dispose();
    _productionBranchController.dispose();
    _compatibilityDateController.dispose();
    super.dispose();
  }

  void _onBlur(FocusNode node) {
    if (!node.hasFocus && _hasChanges(widget.project)) {
      _save();
    }
  }

  bool _mapEquals(Map a, Map b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  void _initializeEnvs(PagesProject project) {
    setState(() {
      _productionEnvs = Map.from(
        project.deploymentConfigs?.production.envVars ?? {},
      );
      _previewEnvs = Map.from(project.deploymentConfigs?.preview.envVars ?? {});

      final config = project.buildConfig;
      final sourceConfig = project.source?.config;
      final prodConfig = project.deploymentConfigs?.production;

      _kvBindings = Map.from(prodConfig?.kvNamespaces ?? {});
      _r2Bindings = Map.from(prodConfig?.r2Buckets ?? {});
      _d1Bindings = Map.from(prodConfig?.d1Databases ?? {});
      _serviceBindings = Map.from(prodConfig?.services ?? {});
      _aiBindings = Map.from(prodConfig?.aiBindings ?? {});

      if (!_buildFocusNode.hasFocus) {
        _buildCommandController.text = config?.buildCommand ?? '';
      }
      if (!_destFocusNode.hasFocus) {
        _destinationDirController.text = config?.destinationDir ?? '';
      }
      if (!_rootFocusNode.hasFocus) {
        _rootDirController.text = config?.rootDir ?? '';
      }
      
      if (!_prodBranchFocusNode.hasFocus) {
         _productionBranchController.text = sourceConfig?.productionBranch ?? 'main';
      }

      if (!_compatibilityDateFocusNode.hasFocus) {
        _compatibilityDateController.text = prodConfig?.compatibilityDate ?? '2024-01-01';
      }
      
      // Update toggles only if we are not saving (to avoid jumping UI)
      if (!_isSaving) {
        _deploymentsEnabled = sourceConfig?.deploymentsEnabled ?? true;
        _productionDeploymentEnabled = sourceConfig?.productionDeploymentEnabled ?? true;
        _prCommentsEnabled = sourceConfig?.prCommentsEnabled ?? true;
        _buildSystemVersion = config?.buildSystemVersion ?? '2';
        _buildCache = config?.buildCache ?? true;
        _placementMode = prodConfig?.placement?.mode ?? 'default';
        _usageModel = prodConfig?.usageModel ?? 'bundled';
      }
    });
  }

  bool _hasChanges(PagesProject original) {
    final currentConfig = original.buildConfig;
    final sourceConfig = original.source?.config;
    final prodConfig = original.deploymentConfigs?.production;

    if (_buildCommandController.text != (currentConfig?.buildCommand ?? '')) {
      return true;
    }
    if (_destinationDirController.text != (currentConfig?.destinationDir ?? '')) {
      return true;
    }
    if (_rootDirController.text != (currentConfig?.rootDir ?? '')) {
      return true;
    }
    if (_buildCache != (currentConfig?.buildCache ?? true)) {
      return true;
    }
    
    // Check Git changes
    if (_productionBranchController.text != (sourceConfig?.productionBranch ?? 'main')) {
      return true;
    }
    if (_deploymentsEnabled != (sourceConfig?.deploymentsEnabled ?? true)) {
      return true;
    }
    if (_productionDeploymentEnabled != (sourceConfig?.productionDeploymentEnabled ?? true)) {
      return true;
    }
    if (_prCommentsEnabled != (sourceConfig?.prCommentsEnabled ?? true)) {
      return true;
    }

    // Check Build System changes
    if (_buildSystemVersion != (currentConfig?.buildSystemVersion ?? '2')) {
      return true;
    }

    // Runtime changes
    if (_compatibilityDateController.text != (prodConfig?.compatibilityDate ?? '2024-01-01')) {
      return true;
    }
    if (_placementMode != (prodConfig?.placement?.mode ?? 'default')) {
      return true;
    }
    if (_usageModel != (prodConfig?.usageModel ?? 'bundled')) {
      return true;
    }

    // Bindings check
    if (!_mapEquals(_kvBindings, prodConfig?.kvNamespaces ?? {})) return true;
    if (!_mapEquals(_r2Bindings, prodConfig?.r2Buckets ?? {})) return true;
    if (!_mapEquals(_d1Bindings, prodConfig?.d1Databases ?? {})) return true;
    if (!_mapEquals(_serviceBindings, prodConfig?.services ?? {})) return true;
    if (!_mapEquals(_aiBindings, prodConfig?.aiBindings ?? {})) return true;

    final originalProd = original.deploymentConfigs?.production.envVars ?? {};
    if (_productionEnvs.length != originalProd.length) {
      return true;
    }
    for (final key in _productionEnvs.keys) {
      if (_productionEnvs[key] != originalProd[key]) {
        return true;
      }
    }

    final originalPrev = original.deploymentConfigs?.preview.envVars ?? {};
    if (_previewEnvs.length != originalPrev.length) {
      return true;
    }
    for (final key in _previewEnvs.keys) {
      if (_previewEnvs[key] != originalPrev[key]) {
        return true;
      }
    }

    return false;
  }

  Future<void> _deleteProject() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pages_deleteProjectConfirmTitle),
        content: Text(
          l10n.pages_deleteProjectConfirmMessage(widget.project.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final success = await ref
          .read(pagesProjectsNotifierProvider.notifier)
          .deleteProject(widget.project.name);

      if (success && mounted) {
        // Pop back to list
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pages_projectDeleted),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _save() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final currentConfigs = widget.project.deploymentConfigs;

    // Helper to filter and clean up environment variables
    Map<String, dynamic> prepareEnvs(
      Map<String, EnvVar> current,
      Map<String, EnvVar> original,
    ) {
      final result = <String, dynamic>{};

      // 1. Add current and modified variables
      // API expects: {"key": {"type": "plain_text", "value": "..."}} or null for deletion
      current.forEach((key, env) {
        if (env.value != null && env.value!.isNotEmpty) {
          result[key] = {'type': env.type ?? 'plain_text', 'value': env.value};
        } else {
          // If value is empty/null but key exists, it means it's an unmodified secret
          // or we want to keep it as is. In Pages, secrets values are not returned.
          // To keep existing, we just don't send it in the PATCH if not changed.
        }
      });

      // 2. Identify deleted variables (in original but not in current)
      original.forEach((key, _) {
        if (!current.containsKey(key)) {
          result[key] = null; // Mark for deletion in Cloudflare API
        }
      });

      return result;
    }

    // Helper to clean up deployment config (preserve empty lists/maps)
    Map<String, dynamic> cleanConfig(
      DeploymentConfig? config,
      Map<String, EnvVar> currentEnvs,
      Map<String, EnvVar> originalEnvs,
      Map<String, PagesBinding> currentKv,
      Map<String, PagesBinding> currentR2,
      Map<String, PagesBinding> currentD1,
      Map<String, PagesBinding> currentServices,
      Map<String, PagesBinding> currentAi,
    ) {
      return {
        'compatibility_date': _compatibilityDateController.text,
        'compatibility_flags': config?.compatibilityFlags ?? [],
        'env_vars': prepareEnvs(currentEnvs, originalEnvs),
        'kv_namespaces': currentKv.map((k, v) => MapEntry(k, v.toJson())),
        'r2_buckets': currentR2.map((k, v) => MapEntry(k, v.toJson())),
        'd1_databases': currentD1.map((k, v) => MapEntry(k, v.toJson())),
        'services': currentServices.map((k, v) => MapEntry(k, v.toJson())),
        'ai_bindings': currentAi.map((k, v) => MapEntry(k, v.toJson())),
        // Only include placement if smart mode is enabled (API rejects 'default')
        if (_placementMode == 'smart') 'placement': {'mode': 'smart'},
        'usage_model': _usageModel,
      };
    }

    final buildCommand = _buildCommandController.text.trim();
    final destinationDir = _destinationDirController.text.trim();
    final rootDir = _rootDirController.text.trim();
    final productionBranch = _productionBranchController.text.trim();

    try {
      final success = await ref
          .read(pagesSettingsNotifierProvider.notifier)
          .updateProject(
            projectName: widget.project.name,
            buildConfig: BuildConfig(
              buildCommand: buildCommand.isEmpty ? null : buildCommand,
              destinationDir: destinationDir.isEmpty ? null : destinationDir,
              rootDir: rootDir.isEmpty ? null : rootDir,
              buildSystemVersion: _buildSystemVersion,
              buildCache: _buildCache,
            ).toJson(),
            source: {
              'config': {
                'production_branch': productionBranch.isEmpty ? 'main' : productionBranch,
                'deployments_enabled': _deploymentsEnabled,
                'production_deployment_enabled': _productionDeploymentEnabled,
                'pr_comments_enabled': _prCommentsEnabled,
              }
            },
            deploymentConfigs: {
              'production': cleanConfig(
                currentConfigs?.production,
                _productionEnvs,
                widget.project.deploymentConfigs?.production.envVars ?? {},
                _kvBindings,
                _r2Bindings,
                _d1Bindings,
                _serviceBindings,
                _aiBindings,
              ),
              'preview': cleanConfig(
                currentConfigs?.preview,
                _previewEnvs,
                widget.project.deploymentConfigs?.preview.envVars ?? {},
                _kvBindings, // Assuming same bindings for preview for now
                _r2Bindings,
                _d1Bindings,
                _serviceBindings,
                _aiBindings,
              ),
            },
          );

      // Set _isSaving to false BEFORE showing snackbar so the listener can update values
      if (mounted) setState(() => _isSaving = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pages_settingsUpdated),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Note: No refresh() here - local state is already correct (ADR-009 Optimistic Updates)
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      rethrow;
    }
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildGitSection(BuildContext context, AppLocalizations l10n) {
    if (!widget.project.hasGitSource) return const SizedBox.shrink();

    return _buildSectionCard(
      context: context,
      title: l10n.pages_gitRepository,
      icon: Symbols.account_tree,
      children: [
        _buildTextField(
          controller: _productionBranchController,
          focusNode: _prodBranchFocusNode,
          label: l10n.pages_productionBranch,
          hint: 'main',
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(l10n.pages_automaticDeployments),
          subtitle: Text(l10n.pages_automaticDeploymentsDescription),
          value: _deploymentsEnabled,
          onChanged: (val) {
            setState(() => _deploymentsEnabled = val);
            _save();
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text(l10n.pages_productionDeployments),
          subtitle: Text(l10n.pages_productionDeploymentsDescription),
          value: _productionDeploymentEnabled,
          onChanged: (val) {
            setState(() => _productionDeploymentEnabled = val);
            _save();
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text(l10n.pages_prComments),
          value: _prCommentsEnabled,
          onChanged: (val) {
            setState(() => _prCommentsEnabled = val);
            _save();
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildBuildSection(BuildContext context, AppLocalizations l10n) {
    return _buildSectionCard(
      context: context,
      title: l10n.pages_buildSettings,
      icon: Symbols.settings_suggest,
      children: [
        _buildTextField(
          controller: _buildCommandController,
          focusNode: _buildFocusNode,
          label: l10n.pages_buildCommand,
          hint: 'npm run build',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _destinationDirController,
          focusNode: _destFocusNode,
          label: l10n.pages_buildOutput,
          hint: 'dist',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _rootDirController,
          focusNode: _rootFocusNode,
          label: l10n.pages_rootDirectory,
          hint: '/',
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(l10n.pages_buildCache),
          value: _buildCache,
          onChanged: (val) {
            setState(() => _buildCache = val);
            _save();
          },
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.pages_buildSystemVersion,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          value: _buildSystemVersion,
          items: const [
            DropdownMenuItem(value: '1', child: Text('Version 1 (Legacy)')),
            DropdownMenuItem(value: '2', child: Text('Version 2')),
            DropdownMenuItem(value: '3', child: Text('Version 3')),
          ],
          onChanged: (val) {
            if (val != _buildSystemVersion) {
              setState(() => _buildSystemVersion = val);
              _save();
            }
          },
        ),
      ],
    );
  }

  Widget _buildRuntimeSection(BuildContext context, AppLocalizations l10n) {
    return _buildSectionCard(
      context: context,
      title: l10n.pages_runtime,
      icon: Symbols.bolt,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.pages_placement,
            border: const OutlineInputBorder(),
          ),
          value: _placementMode,
          items: const [
            DropdownMenuItem(value: 'default', child: Text('Off (Default)')),
            DropdownMenuItem(value: 'smart', child: Text('Smart Placement')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() => _placementMode = val);
              _save();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _compatibilityDateController,
          focusNode: _compatibilityDateFocusNode,
          label: l10n.pages_compatibilityDate,
          hint: '2024-01-01',
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.pages_usageModel,
            border: const OutlineInputBorder(),
          ),
          value: _usageModel,
          items: const [
            DropdownMenuItem(value: 'bundled', child: Text('Bundled')),
            DropdownMenuItem(value: 'standard', child: Text('Standard')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() => _usageModel = val);
              _save();
            }
          },
        ),
      ],
    );
  }

  Widget _buildEnvVarsSection(BuildContext context, AppLocalizations l10n) {
    return _buildSectionCard(
      context: context,
      title: l10n.pages_environmentVariables,
      icon: Symbols.variables,
      children: [
        _buildEnvSection(
          context,
          l10n.pages_productionEnv,
          _productionEnvs,
          (updated) {
            setState(() => _productionEnvs = updated);
            _save();
          },
        ),
        const SizedBox(height: 24),
        _buildEnvSection(
          context,
          l10n.pages_previewEnv,
          _previewEnvs,
          (updated) {
            setState(() => _previewEnvs = updated);
            _save();
          },
        ),
      ],
    );
  }

  Widget _buildBindingsSection(BuildContext context, AppLocalizations l10n) {
    return _buildSectionCard(
      context: context,
      title: l10n.pages_bindings,
      icon: Symbols.link,
      children: [
        _buildBindingGroup(
          context,
          l10n.workers_bindings_kv,
          _kvBindings,
          (updated) {
            setState(() => _kvBindings = updated);
            _save();
          },
          Symbols.database,
          ref.watch(kvNamespacesProvider).valueOrNull?.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title))).toList() ?? [],
        ),
        const SizedBox(height: 16),
        _buildBindingGroup(
          context,
          l10n.workers_bindings_r2,
          _r2Bindings,
          (updated) {
            setState(() => _r2Bindings = updated);
            _save();
          },
          Symbols.folder_zip,
          ref.watch(r2BucketsProvider).valueOrNull?.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList() ?? [],
        ),
        const SizedBox(height: 16),
        _buildBindingGroup(
          context,
          l10n.workers_bindings_d1,
          _d1Bindings,
          (updated) {
            setState(() => _d1Bindings = updated);
            _save();
          },
          Symbols.database_off,
          ref.watch(d1DatabasesProvider).valueOrNull?.map((e) => DropdownMenuItem(value: e.uuid, child: Text(e.name))).toList() ?? [],
        ),
      ],
    );
  }

  Widget _buildBindingGroup(
    BuildContext context,
    String title,
    Map<String, PagesBinding> bindings,
    Function(Map<String, PagesBinding>) onChanged,
    IconData icon,
    List<DropdownMenuItem<String>> availableItems,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            TextButton.icon(
              onPressed: () => _showAddBindingDialog(context, title, bindings, onChanged, availableItems),
              icon: const Icon(Symbols.add, size: 18),
              label: Text(l10n.common_add),
            ),
          ],
        ),
        if (bindings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              l10n.common_none,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          )
        else
          ...bindings.entries.map((entry) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon, size: 18),
                title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(entry.value.id ?? entry.value.namespaceId ?? entry.value.bucketName ?? ''),
                trailing: IconButton(
                  icon: const Icon(Symbols.close, size: 18),
                  onPressed: () {
                    final newMap = Map<String, PagesBinding>.from(bindings);
                    newMap.remove(entry.key);
                    onChanged(newMap);
                  },
                ),
              )),
      ],
    );
  }

  void _showAddBindingDialog(
    BuildContext context,
    String title,
    Map<String, PagesBinding> bindings,
    Function(Map<String, PagesBinding>) onChanged,
    List<DropdownMenuItem<String>> availableItems,
  ) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    String? selectedId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.record_name,
                  hintText: 'MY_BINDING',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: l10n.common_all),
                items: availableItems,
                onChanged: (val) => setDialogState(() => selectedId = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.common_cancel)),
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty || selectedId == null) return;
                final newMap = Map<String, PagesBinding>.from(bindings);
                
                // Determine resource field based on title (hacky but works for now)
                final binding = PagesBinding(
                  id: selectedId,
                  namespaceId: title.contains('KV') ? selectedId : null,
                  bucketName: title.contains('R2') ? selectedId : null,
                );
                
                newMap[nameController.text.trim()] = binding;
                onChanged(newMap);
                Navigator.pop(context);
              },
              child: Text(l10n.common_add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Symbols.warning, color: Colors.red),
                const SizedBox(width: 12),
                Text(
                  l10n.pages_dangerZone,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              l10n.pages_deleteProjectDescription,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red.shade900),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isDeleting ? null : _deleteProject,
                icon: const Icon(Symbols.delete),
                label: Text(l10n.pages_deleteProject),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isUpdating = ref.watch(pagesSettingsNotifierProvider).isLoading;

    // Listen for project changes to update local state if not dirty
    ref.listen(pagesProjectDetailsNotifierProvider(widget.project.name), (
      prev,
      next,
    ) {
      if (next.hasValue && !_hasChanges(next.value!) && !_isSaving) {
        _initializeEnvs(next.value!);
      }
    });

    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isSaving || isUpdating || _isDeleting)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
            
            _buildGitSection(context, l10n),
            _buildBuildSection(context, l10n),
            _buildRuntimeSection(context, l10n),
            _buildEnvVarsSection(context, l10n),
            _buildBindingsSection(context, l10n),
            
            // Deploy Hooks Placeholder
            _buildSectionCard(
              context: context,
              title: l10n.pages_deployHooks,
              icon: Symbols.webhook,
              children: [
                Text(
                  l10n.pages_noDeployHooks,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),

            _buildDangerZone(context, l10n),

            const SizedBox(height: 100), // Bottom padding for scroll
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildEnvSection(
    BuildContext context,
    String title,
    Map<String, EnvVar> envs,
    Function(Map<String, EnvVar>) onChanged,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            TextButton.icon(
              onPressed: () => _showAddEnvDialog(context, envs, onChanged),
              icon: const Icon(Symbols.add, size: 18),
              label: Text(l10n.pages_addVariable),
            ),
          ],
        ),
        if (envs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.common_noData,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: envs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final key = envs.keys.elementAt(index);
                final env = envs[key]!;
                final isSecret =
                    env.type == 'secret' || env.type == 'secret_text';

                return ListTile(
                  dense: true,
                  title: Text(
                    key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    isSecret ? '••••••••' : (env.value ?? ''),
                    style: TextStyle(
                      fontFamily: isSecret ? null : 'monospace',
                      color: isSecret ? Colors.orange.shade700 : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Symbols.edit, size: 18),
                        onPressed: () => _showAddEnvDialog(
                          context,
                          envs,
                          onChanged,
                          existingKey: key,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.close, size: 18),
                        onPressed: () {
                          final newEnvs = Map<String, EnvVar>.from(envs);
                          newEnvs.remove(key);
                          onChanged(newEnvs);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAddEnvDialog(
    BuildContext context,
    Map<String, EnvVar> envs,
    Function(Map<String, EnvVar>) onChanged, {
    String? existingKey,
  }) {
    final l10n = AppLocalizations.of(context);
    final keyController = TextEditingController(text: existingKey ?? '');
    final valueController = TextEditingController(
      text: existingKey != null ? envs[existingKey]?.value ?? '' : '',
    );
    bool isSecret = existingKey != null
        ? (envs[existingKey]?.type == 'secret' ||
              envs[existingKey]?.type == 'secret_text')
        : false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existingKey != null ? l10n.common_edit : l10n.pages_addVariable,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: InputDecoration(labelText: l10n.pages_variableName),
                enabled: existingKey == null,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: l10n.pages_variableValue,
                ),
                obscureText: isSecret,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text(
                  l10n.pages_secret,
                  style: const TextStyle(fontSize: 14),
                ),
                value: isSecret,
                onChanged: (val) => setDialogState(() => isSecret = val),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.common_cancel),
            ),
            TextButton(
              onPressed: () {
                if (keyController.text.isEmpty || valueController.text.isEmpty) {
                  return;
                }
                final newEnvs = Map<String, EnvVar>.from(envs);
                newEnvs[keyController.text.trim()] = EnvVar(
                  value: valueController.text.trim(),
                  type: isSecret ? 'secret_text' : 'plain_text',
                );
                onChanged(newEnvs);
                Navigator.pop(context);
              },
              child: Text(
                existingKey != null ? l10n.common_save : l10n.common_add,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
