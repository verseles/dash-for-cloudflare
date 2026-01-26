import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/models/worker.dart';
import '../../domain/models/worker_settings.dart';
import '../../providers/workers_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/error_view.dart';

class WorkerSettingsTab extends ConsumerStatefulWidget {
  const WorkerSettingsTab({super.key, required this.worker});

  final Worker worker;

  @override
  ConsumerState<WorkerSettingsTab> createState() => _WorkerSettingsTabState();
}

class _WorkerSettingsTabState extends ConsumerState<WorkerSettingsTab> {
  // Local state for environment variables (plain_text only)
  Map<String, String>? _localVariables;
  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  // Runtime Controllers
  late TextEditingController _compatibilityDateController;
  late String _usageModel;
  late String _placementMode;
  
  // Observability
  late bool _observabilityEnabled;

  // Focus Nodes
  late FocusNode _compatibilityDateFocusNode;

  @override
  void initState() {
    super.initState();
    _compatibilityDateController = TextEditingController();
    _compatibilityDateFocusNode = FocusNode()..addListener(() {
      if (!_compatibilityDateFocusNode.hasFocus) {
        _saveSettings();
      }
    });
  }

  @override
  void dispose() {
    _compatibilityDateController.dispose();
    _compatibilityDateFocusNode.dispose();
    super.dispose();
  }

  void _initializeLocalState(WorkerSettings settings) {
    final vars = <String, String>{};
    for (final b in settings.bindings) {
      if (b.type == 'plain_text' && b.text != null) {
        vars[b.name] = b.text!;
      }
    }
    setState(() {
      _localVariables = vars;
      _compatibilityDateController.text = settings.compatibilityDate ?? '';
      _usageModel = settings.usageModel;
      _placementMode = settings.placement?.mode ?? 'default';
      _observabilityEnabled = settings.observability?.enabled ?? false;
      _isInitialized = true;
    });
  }

  bool _hasChanges(WorkerSettings original) {
    if (_localVariables == null) return false;
    
    final originalVars = <String, String>{};
    for (final b in original.bindings) {
      if (b.type == 'plain_text' && b.text != null) {
        originalVars[b.name] = b.text!;
      }
    }

    if (_localVariables!.length != originalVars.length) return true;
    for (final key in _localVariables!.keys) {
      if (_localVariables![key] != originalVars[key]) return true;
    }

    if (_compatibilityDateController.text != (original.compatibilityDate ?? '')) return true;
    if (_usageModel != original.usageModel) return true;
    if (_placementMode != (original.placement?.mode ?? 'default')) return true;
    if (_observabilityEnabled != (original.observability?.enabled ?? false)) return true;
    
    return false;
  }

  Future<void> _saveSettings() async {
    final currentSettings = ref.read(workerDetailsNotifierProvider(widget.worker.id)).valueOrNull;
    if (currentSettings == null || !_hasChanges(currentSettings)) return;

    if (!mounted) return;
    setState(() => _isSaving = true);

    final updatedBindings = <Map<String, dynamic>>[];
    
    // Keep non-variable bindings
    for (final b in currentSettings.bindings) {
      if (b.type != 'plain_text' && b.type != 'secret_text') {
        updatedBindings.add(b.toJson());
      }
    }

    // Add updated variables
    _localVariables?.forEach((name, text) {
      updatedBindings.add({
        'type': 'plain_text',
        'name': name,
        'text': text,
      });
    });

    final data = {
      'bindings': updatedBindings,
      'compatibility_date': _compatibilityDateController.text.trim(),
      'usage_model': _usageModel,
      'placement': {'mode': _placementMode},
      'observability': {'enabled': _observabilityEnabled},
    };

    try {
      final success = await ref.read(workerSettingsActionNotifierProvider.notifier).updateSettings(
        scriptName: widget.worker.id,
        data: data,
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

  Future<void> _deleteWorker() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.workers_settings_deleteWorker),
        content: Text(l10n.workers_settings_deleteWorkerConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.common_cancel)),
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
      await ref.read(workersNotifierProvider.notifier).deleteWorker(widget.worker.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.common_deleted)),
        );
        // Navigate back to the list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(workerDetailsNotifierProvider(widget.worker.id));
    final actionState = ref.watch(workerSettingsActionNotifierProvider);

    ref.listen(workerDetailsNotifierProvider(widget.worker.id), (prev, next) {
      if (next.hasValue && !_hasChanges(next.value!) && !_isSaving) {
        _initializeLocalState(next.value!);
      }
    });

    return settingsAsync.when(
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => CloudflareErrorView(
        error: err,
        onRetry: () => ref.refresh(workerDetailsNotifierProvider(widget.worker.id)),
      ),
      data: (settings) {
        if (!_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeLocalState(settings);
          });
        }
        
        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_isSaving || actionState.isLoading || _isDeleting)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(),
                ),

              _buildDomainsRoutesSection(context, l10n),
              
              _buildSectionCard(
                context: context, 
                title: l10n.workers_settings_variables, 
                icon: Symbols.variables,
                onAdd: () => _showAddBindingDialog(context, l10n),
                children: [
                  if (settings.bindings.isEmpty)
                    _buildEmptyBox(context, l10n.common_noData)
                  else
                    ..._buildGroupedBindings(context, settings.bindings, l10n),
                ],
              ),

              _buildSectionCard(
                context: context,
                title: l10n.workers_triggers_cron,
                icon: Symbols.schedule,
                children: [
                  Text(
                    l10n.workers_triggers_noSchedules,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),

              _buildObservabilitySection(context, l10n),
              _buildRuntimeSection(context, l10n),

              _buildSectionCard(
                context: context,
                title: 'Build',
                icon: Symbols.build,
                children: [
                  Text(
                    'Connect to Git repository',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),

              _buildDangerZone(context, l10n),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    VoidCallback? onAdd,
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
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (onAdd != null)
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Symbols.add, size: 20),
                    visualDensity: VisualDensity.compact,
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

  Widget _buildDomainsRoutesSection(BuildContext context, AppLocalizations l10n) {
    return _buildSectionCard(
      context: context,
      title: l10n.workers_settings_domainsAndRoutes,
      icon: Symbols.language,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Symbols.link, size: 20),
          title: Text(l10n.workers_triggers_customDomains),
          trailing: const Icon(Symbols.chevron_right, size: 20),
          onTap: () {
             // Navigation logic should be handled by the parent page or a route
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Symbols.route, size: 20),
          title: Text(l10n.workers_triggers_routes),
          trailing: const Icon(Symbols.chevron_right, size: 20),
          onTap: () {
             // Navigation logic
          },
        ),
      ],
    );
  }

  Widget _buildObservabilitySection(BuildContext context, AppLocalizations l10n) {
    return _buildSectionCard(
      context: context,
      title: l10n.workers_settings_observability,
      icon: Symbols.monitoring,
      children: [
        SwitchListTile(
          title: Text(l10n.workers_settings_logs),
          subtitle: Text(l10n.workers_settings_traces),
          value: _observabilityEnabled,
          onChanged: (val) {
            setState(() => _observabilityEnabled = val);
            _saveSettings();
          },
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.workers_settings_tail),
          subtitle: Text(l10n.workers_settings_noTail),
          trailing: const Icon(Symbols.chevron_right, size: 20),
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
          initialValue: _placementMode,
          items: const [
            DropdownMenuItem(value: 'default', child: Text('Default')),
            DropdownMenuItem(value: 'smart', child: Text('Smart')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() => _placementMode = val);
              _saveSettings();
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _compatibilityDateController,
          focusNode: _compatibilityDateFocusNode,
          decoration: InputDecoration(
            labelText: l10n.pages_compatibilityDate,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.pages_usageModel,
            border: const OutlineInputBorder(),
          ),
          initialValue: _usageModel,
          items: const [
            DropdownMenuItem(value: 'bundled', child: Text('Bundled')),
            DropdownMenuItem(value: 'standard', child: Text('Standard')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() => _usageModel = val);
              _saveSettings();
            }
          },
        ),
      ],
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
              l10n.workers_settings_deleteWorkerConfirm,
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
                onPressed: _isDeleting ? null : _deleteWorker,
                icon: const Icon(Symbols.delete),
                label: Text(l10n.workers_settings_deleteWorker),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBox(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> _buildGroupedBindings(
    BuildContext context, 
    List<WorkerBinding> bindings,
    AppLocalizations l10n,
  ) {
    final groups = <String, List<WorkerBinding>>{};
    for (final b in bindings) {
      groups.putIfAbsent(b.type, () => []).add(b);
    }

    final widgets = <Widget>[];
    for (final type in groups.keys) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _getBindingTypeLabel(type, l10n).toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ));
      
      widgets.add(Card(
        child: Column(
          children: groups[type]!.map((b) => _buildBindingTile(context, b, l10n)).toList(),
        ),
      ));
    }
    return widgets;
  }

  Widget _buildBindingTile(BuildContext context, WorkerBinding binding, AppLocalizations l10n) {
    final isSecret = binding.type == 'secret_text';
    final isVariable = binding.type == 'plain_text';
    
    return ListTile(
      dense: true,
      leading: Icon(_getBindingIcon(binding.type), size: 18),
      title: Text(binding.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: isSecret 
          ? const Text('••••••••', style: TextStyle(color: Colors.orange))
          : isVariable && _localVariables != null
              ? Text(_localVariables![binding.name] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)
              : Text(binding.namespaceId ?? binding.bucketName ?? binding.id ?? binding.text ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isVariable)
            IconButton(
              icon: const Icon(Symbols.edit, size: 18),
              onPressed: () => _showEditVariableDialog(context, binding.name, l10n),
            ),
          if (isSecret)
            IconButton(
              icon: const Icon(Symbols.lock_reset, size: 18),
              onPressed: () => _showUpdateSecretDialog(context, binding.name, l10n),
            ),
          if (isVariable)
            IconButton(
              icon: const Icon(Symbols.close, size: 18),
              onPressed: () => _removeVariable(binding.name),
            ),
        ],
      ),
    );
  }

  void _removeVariable(String name) {
    setState(() {
      _localVariables?.remove(name);
    });
    _saveSettings();
  }

  void _showEditVariableDialog(BuildContext context, String name, AppLocalizations l10n) {
    final controller = TextEditingController(text: _localVariables?[name]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.pages_variableValue),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.common_cancel)),
          TextButton(
            onPressed: () {
              setState(() {
                _localVariables?[name] = controller.text.trim();
              });
              Navigator.pop(context);
              _saveSettings();
            },
            child: Text(l10n.common_save),
          ),
        ],
      ),
    );
  }

  void _showUpdateSecretDialog(BuildContext context, String name, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.workers_settings_updateSecret),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.workers_settings_secretValue,
                hintText: l10n.workers_settings_secretHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.common_cancel)),
          FilledButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              final success = await ref.read(workerSettingsActionNotifierProvider.notifier).updateSecret(
                scriptName: widget.worker.id,
                name: name,
                text: controller.text.trim(),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.pages_settingsUpdated)),
                );
              }
            },
            child: Text(l10n.common_save),
          ),
        ],
      ),
    );
  }

  void _showAddBindingDialog(BuildContext context, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    bool isSecret = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.workers_settings_addBinding),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.pages_variableName),
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
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.common_cancel)),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isEmpty || valueController.text.isEmpty) return;
                Navigator.pop(context);
                
                if (isSecret) {
                  await ref.read(workerSettingsActionNotifierProvider.notifier).updateSecret(
                    scriptName: widget.worker.id,
                    name: nameController.text.trim(),
                    text: valueController.text.trim(),
                  );
                } else {
                  setState(() {
                    _localVariables?[nameController.text.trim()] = valueController.text.trim();
                  });
                  _saveSettings();
                }
              },
              child: Text(l10n.common_add),
            ),
          ],
        ),
      ),
    );
  }

  String _getBindingTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'kv_namespace': return l10n.workers_bindings_kv;
      case 'r2_bucket': return l10n.workers_bindings_r2;
      case 'd1': return l10n.workers_bindings_d1;
      case 'durable_object_namespace': return l10n.workers_bindings_do;
      case 'plain_text': return l10n.workers_settings_variables;
      case 'secret_text': return l10n.workers_settings_variables;
      case 'service': return l10n.workers_bindings_service;
      case 'queue': return l10n.workers_bindings_queue;
      default: return type;
    }
  }

  IconData _getBindingIcon(String type) {
    switch (type) {
      case 'kv_namespace': return Symbols.database;
      case 'r2_bucket': return Symbols.inventory_2;
      case 'd1': return Symbols.storage;
      case 'durable_object_namespace': return Symbols.extension;
      case 'plain_text': return Symbols.token;
      case 'secret_text': return Symbols.key;
      case 'service': return Symbols.hub;
      case 'queue': return Symbols.queue;
      default: return Symbols.data_object;
    }
  }
}