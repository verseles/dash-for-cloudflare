import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/models/pages_project.dart';
import '../../providers/pages_provider.dart';
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

  // Build Settings Controllers
  late TextEditingController _buildCommandController;
  late TextEditingController _destinationDirController;
  late TextEditingController _rootDirController;

  // Focus Nodes for blur detection
  late FocusNode _buildFocusNode;
  late FocusNode _destFocusNode;
  late FocusNode _rootFocusNode;

  // Environment Variables
  late Map<String, EnvVar> _productionEnvs;
  late Map<String, EnvVar> _previewEnvs;

  @override
  void initState() {
    super.initState();
    final config = widget.project.buildConfig;
    _buildCommandController = TextEditingController(
      text: config?.buildCommand ?? '',
    );
    _destinationDirController = TextEditingController(
      text: config?.destinationDir ?? '',
    );
    _rootDirController = TextEditingController(text: config?.rootDir ?? '');

    _buildFocusNode = FocusNode()..addListener(() => _onBlur(_buildFocusNode));
    _destFocusNode = FocusNode()..addListener(() => _onBlur(_destFocusNode));
    _rootFocusNode = FocusNode()..addListener(() => _onBlur(_rootFocusNode));

    _productionEnvs = Map.from(
      widget.project.deploymentConfigs?.production.envVars ?? {},
    );
    _previewEnvs = Map.from(
      widget.project.deploymentConfigs?.preview.envVars ?? {},
    );
  }

  @override
  void dispose() {
    _buildFocusNode.dispose();
    _destFocusNode.dispose();
    _rootFocusNode.dispose();
    _buildCommandController.dispose();
    _destinationDirController.dispose();
    _rootDirController.dispose();
    super.dispose();
  }

  void _onBlur(FocusNode node) {
    if (!node.hasFocus && _hasChanges(widget.project)) {
      _save();
    }
  }

  void _initializeEnvs(PagesProject project) {
    setState(() {
      _productionEnvs = Map.from(
        project.deploymentConfigs?.production.envVars ?? {},
      );
      _previewEnvs = Map.from(project.deploymentConfigs?.preview.envVars ?? {});

      final config = project.buildConfig;
      if (!_buildFocusNode.hasFocus)
        _buildCommandController.text = config?.buildCommand ?? '';
      if (!_destFocusNode.hasFocus)
        _destinationDirController.text = config?.destinationDir ?? '';
      if (!_rootFocusNode.hasFocus)
        _rootDirController.text = config?.rootDir ?? '';
    });
  }

  bool _hasChanges(PagesProject original) {
    final currentConfig = original.buildConfig;
    if (_buildCommandController.text != (currentConfig?.buildCommand ?? ''))
      return true;
    if (_destinationDirController.text != (currentConfig?.destinationDir ?? ''))
      return true;
    if (_rootDirController.text != (currentConfig?.rootDir ?? '')) return true;

    final originalProd = original.deploymentConfigs?.production.envVars ?? {};
    if (_productionEnvs.length != originalProd.length) return true;
    for (final key in _productionEnvs.keys) {
      if (_productionEnvs[key] != originalProd[key]) return true;
    }

    final originalPrev = original.deploymentConfigs?.preview.envVars ?? {};
    if (_previewEnvs.length != originalPrev.length) return true;
    for (final key in _previewEnvs.keys) {
      if (_previewEnvs[key] != originalPrev[key]) return true;
    }

    return false;
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
    ) {
      return {
        'compatibility_date': config?.compatibilityDate ?? '2024-01-01',
        'compatibility_flags': config?.compatibilityFlags ?? [],
        'env_vars': prepareEnvs(currentEnvs, originalEnvs),
      };
    }

    final buildCommand = _buildCommandController.text.trim();
    final destinationDir = _destinationDirController.text.trim();
    final rootDir = _rootDirController.text.trim();

    try {
      final success = await ref
          .read(pagesSettingsNotifierProvider.notifier)
          .updateProject(
            projectName: widget.project.name,
            // Note: For build_config fields, we send empty string "" to clear the value.
            // Sending null in a PATCH request means "don't change this field".
            // This differs from env_vars where null means "delete this variable".
            buildConfig: BuildConfig(
              buildCommand: buildCommand,
              destinationDir: destinationDir,
              rootDir: rootDir,
            ).toJson(),
            deploymentConfigs: {
              'production': cleanConfig(
                currentConfigs?.production,
                _productionEnvs,
                widget.project.deploymentConfigs?.production.envVars ?? {},
              ),
              'preview': cleanConfig(
                currentConfigs?.preview,
                _previewEnvs,
                widget.project.deploymentConfigs?.preview.envVars ?? {},
              ),
            },
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pages_settingsUpdated),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isUpdating = ref.watch(pagesSettingsNotifierProvider).isLoading;

    // Listen for project changes to update local state if not dirty
    // This handles background refreshes while the user is viewing the tab
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(context, l10n.pages_buildSettings),
                if (_isSaving || isUpdating)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
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
              label: l10n.pages_outputDirectory,
              hint: 'dist',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _rootDirController,
              focusNode: _rootFocusNode,
              label: l10n.pages_rootDirectory,
              hint: '/',
            ),

            const SizedBox(height: 32),
            _buildSectionTitle(context, l10n.pages_environmentVariables),
            const SizedBox(height: 16),

            _buildEnvSection(
              context,
              l10n.pages_productionEnv,
              _productionEnvs,
              (updated) {
                setState(() => _productionEnvs = updated);
                _save(); // Immediate save for variable changes
              },
            ),

            const SizedBox(height: 24),
            _buildEnvSection(context, l10n.pages_previewEnv, _previewEnvs, (
              updated,
            ) {
              setState(() => _previewEnvs = updated);
              _save(); // Immediate save for variable changes
            }),

            const SizedBox(height: 60), // Extra space
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
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
                if (keyController.text.isEmpty || valueController.text.isEmpty)
                  return;
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
