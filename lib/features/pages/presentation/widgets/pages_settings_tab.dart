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
  
  // Build Settings Controllers
  late TextEditingController _buildCommandController;
  late TextEditingController _destinationDirController;
  late TextEditingController _rootDirController;

  // Environment Variables
  late Map<String, EnvVar> _productionEnvs;
  late Map<String, EnvVar> _previewEnvs;

  @override
  void initState() {
    super.initState();
    final config = widget.project.buildConfig;
    _buildCommandController = TextEditingController(text: config?.buildCommand ?? '');
    _destinationDirController = TextEditingController(text: config?.destinationDir ?? '');
    _rootDirController = TextEditingController(text: config?.rootDir ?? '');

    _productionEnvs = Map.from(widget.project.deploymentConfigs?.production.envVars ?? {});
    _previewEnvs = Map.from(widget.project.deploymentConfigs?.preview.envVars ?? {});
  }

  @override
  void dispose() {
    _buildCommandController.dispose();
    _destinationDirController.dispose();
    _rootDirController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(pagesSettingsNotifierProvider.notifier).updateProject(
      projectName: widget.project.name,
      buildConfig: {
        'build_command': _buildCommandController.text.trim(),
        'destination_dir': _destinationDirController.text.trim(),
        'root_dir': _rootDirController.text.trim(),
      },
      deploymentConfigs: {
        'production': {
          'env_vars': _productionEnvs.map((k, v) => MapEntry(k, v.toJson())),
        },
        'preview': {
          'env_vars': _previewEnvs.map((k, v) => MapEntry(k, v.toJson())),
        },
      },
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pages_settingsUpdated)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isUpdating = ref.watch(pagesSettingsNotifierProvider).isLoading;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(context, l10n.pages_buildSettings),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _buildCommandController,
              label: l10n.pages_buildCommand,
              hint: 'npm run build',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _destinationDirController,
              label: l10n.pages_outputDirectory,
              hint: 'dist',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _rootDirController,
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
              (updated) => setState(() => _productionEnvs = updated),
            ),
            
            const SizedBox(height: 24),
            _buildEnvSection(
              context, 
              l10n.pages_previewEnv, 
              _previewEnvs,
              (updated) => setState(() => _previewEnvs = updated),
            ),

            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: isUpdating ? null : _save,
              icon: isUpdating 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Symbols.save),
              label: Text(l10n.pages_saveSettings),
            ),
            const SizedBox(height: 40),
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
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            child: Text(l10n.common_noData, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
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
                final isSecret = env.type == 'secret';

                return ListTile(
                  dense: true,
                  title: Text(key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(
                    isSecret ? '••••••••' : env.value,
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
                        onPressed: () => _showAddEnvDialog(context, envs, onChanged, existingKey: key),
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
    Function(Map<String, EnvVar>) onChanged,
    {String? existingKey}
  ) {
    final l10n = AppLocalizations.of(context);
    final keyController = TextEditingController(text: existingKey ?? '');
    final valueController = TextEditingController(text: existingKey != null ? envs[existingKey]?.value : '');
    bool isSecret = existingKey != null ? envs[existingKey]?.type == 'secret' : false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingKey != null ? l10n.common_edit : l10n.pages_addVariable),
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
                decoration: InputDecoration(labelText: l10n.pages_variableValue),
                obscureText: isSecret,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text(l10n.pages_secret, style: const TextStyle(fontSize: 14)),
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
                if (keyController.text.isEmpty || valueController.text.isEmpty) return;
                final newEnvs = Map<String, EnvVar>.from(envs);
                newEnvs[keyController.text.trim()] = EnvVar(
                  value: valueController.text.trim(),
                  type: isSecret ? 'secret' : 'plain_text',
                );
                onChanged(newEnvs);
                Navigator.pop(context);
              },
              child: Text(existingKey != null ? l10n.common_save : l10n.common_add),
            ),
          ],
        ),
      ),
    );
  }
}
