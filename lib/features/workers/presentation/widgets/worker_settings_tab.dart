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

  void _initializeLocalState(WorkerSettings settings) {
    final vars = <String, String>{};
    for (final b in settings.bindings) {
      if (b.type == 'plain_text' && b.text != null) {
        vars[b.name] = b.text!;
      }
    }
    setState(() {
      _localVariables = vars;
      _isInitialized = true;
    });
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(workerDetailsNotifierProvider(widget.worker.id));
    final actionState = ref.watch(workerSettingsActionNotifierProvider);

    // Sync local state when provider data changes (background refresh)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(
                    context, 
                    l10n.workers_settings_bindings, 
                    Symbols.rebase,
                    onAdd: () => _showAddBindingDialog(context, l10n),
                  ),
                  if (_isSaving || actionState.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (settings.bindings.isEmpty)
                _buildEmptyBox(context, l10n.common_noData)
              else
                ..._buildGroupedBindings(context, settings.bindings, l10n),
              
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.workers_settings_compatibility, Symbols.contract),
              const SizedBox(height: 8),
              _buildCompatibilityCard(context, settings, l10n),

              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
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
    
    return false;
  }

  Future<void> _saveChanges(WorkerSettings original) async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    final updatedBindings = <Map<String, dynamic>>[];
    
    // Keep non-variable bindings
    for (final b in original.bindings) {
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

    try {
      final success = await ref.read(workerSettingsActionNotifierProvider.notifier).updateSettings(
        scriptName: widget.worker.id,
        data: {'bindings': updatedBindings},
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {VoidCallback? onAdd}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (onAdd != null)
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Symbols.add, size: 20),
            visualDensity: VisualDensity.compact,
          ),
      ],
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
    final settings = ref.read(workerDetailsNotifierProvider(widget.worker.id)).valueOrNull;
    if (settings != null) _saveChanges(settings);
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
              final settings = ref.read(workerDetailsNotifierProvider(widget.worker.id)).valueOrNull;
              if (settings != null) _saveChanges(settings);
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
                  final settings = ref.read(workerDetailsNotifierProvider(widget.worker.id)).valueOrNull;
                  if (settings != null) _saveChanges(settings);
                }
              },
              child: Text(l10n.common_add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityCard(BuildContext context, WorkerSettings settings, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(context, l10n.pages_compatibilityDate, settings.compatibilityDate ?? '-'),
            if (settings.compatibilityFlags.isNotEmpty) ...[
              const Divider(),
              _buildInfoRow(context, l10n.pages_compatibilityFlags, settings.compatibilityFlags.join(', ')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
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
