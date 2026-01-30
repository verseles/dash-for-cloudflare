import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/worker.dart';
import '../../domain/models/worker_settings.dart';
import '../../providers/workers_provider.dart';
import '../../../../core/providers/resource_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/providers/account_provider.dart';
import '../pages/worker_tail_page.dart';

class WorkerSettingsTab extends ConsumerStatefulWidget {
  const WorkerSettingsTab({super.key, required this.worker});

  final Worker worker;

  @override
  ConsumerState<WorkerSettingsTab> createState() => _WorkerSettingsTabState();
}

class _WorkerSettingsTabState extends ConsumerState<WorkerSettingsTab> {
  // Local state for all bindings
  List<WorkerBinding>? _localBindings;
  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  // Runtime Controllers
  late TextEditingController _compatibilityDateController;
  String _usageModel = 'bundled';
  String _placementMode = 'default';
  
  // Observability
  bool _observabilityEnabled = false;

  // Focus Nodes
  late FocusNode _compatibilityDateFocusNode;

  @override
  void initState() {
    super.initState();
    _compatibilityDateController = TextEditingController();
    _usageModel = 'bundled';
    _placementMode = 'default';
    _observabilityEnabled = false;
    _compatibilityDateFocusNode = FocusNode()..addListener(() {
      if (!_compatibilityDateFocusNode.hasFocus) {
        unawaited(_saveSettings());
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
    setState(() {
      _localBindings = List.from(settings.bindings);
      _compatibilityDateController.text = settings.compatibilityDate ?? '';
      _usageModel = settings.usageModel;
      _placementMode = settings.placement?.mode ?? 'default';
      _observabilityEnabled = settings.observability?.enabled ?? false;
      _isInitialized = true;
    });
  }

  bool _hasChanges(WorkerSettings original) {
    if (_localBindings == null) return false;
    
    if (_localBindings!.length != original.bindings.length) return true;
    for (int i = 0; i < _localBindings!.length; i++) {
      if (_localBindings![i] != original.bindings[i]) return true;
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

    final data = {
      'bindings': _localBindings?.map((b) => b.toJson()).toList(),
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
          _initializeLocalState(settings);
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
                  if (_localBindings == null || _localBindings!.isEmpty)
                    _buildEmptyBox(context, l10n.common_noData)
                  else
                    ..._buildGroupedBindings(context, _localBindings!, l10n),
                ],
              ),

              _buildSectionCard(
                context: context,
                title: l10n.workers_triggers_cron,
                icon: Symbols.schedule,
                onAdd: () => DefaultTabController.of(context).animateTo(1),
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

              _buildGitBuildSection(context, l10n),

              _buildDangerZone(context, l10n),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGitBuildSection(BuildContext context, AppLocalizations l10n) {
    return _buildSectionCard(
      context: context,
      title: l10n.workers_settings_build,
      icon: Symbols.build,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Symbols.integration_instructions, size: 20),
          title: Text(l10n.workers_settings_gitIntegration),
          subtitle: Text(l10n.workers_settings_gitIntegrationDescription),
          trailing: const Icon(Symbols.open_in_new, size: 20),
          onTap: () => _openGitBuildDashboard(context),
        ),
      ],
    );
  }

  Future<void> _openGitBuildDashboard(BuildContext context) async {
    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).workers_settings_noAccountSelected)),
      );
      return;
    }

    final url = Uri.parse(
      'https://dash.cloudflare.com/$accountId/workers/services/view/${widget.worker.id}/builds',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).common_error)),
      );
    }
  }

  void _openTailPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkerTailPage(worker: widget.worker),
      ),
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
            DefaultTabController.of(context).animateTo(1);
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Symbols.route, size: 20),
          title: Text(l10n.workers_triggers_routes),
          trailing: const Icon(Symbols.chevron_right, size: 20),
          onTap: () {
            DefaultTabController.of(context).animateTo(1);
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
            unawaited(_saveSettings());
          },
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Symbols.terminal, size: 20),
          title: Text(l10n.workers_settings_tail),
          subtitle: Text(l10n.workers_settings_tailDescription),
          trailing: const Icon(Symbols.chevron_right, size: 20),
          onTap: () => _openTailPage(context),
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
              unawaited(_saveSettings());
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
              unawaited(_saveSettings());
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
      subtitle: Text(
        isSecret ? '••••••••' : (binding.text ?? binding.namespaceId ?? binding.bucketName ?? binding.id ?? ''),
        maxLines: 1, 
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: isSecret ? null : 'monospace',
          color: isSecret ? Colors.orange : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isVariable)
            IconButton(
              icon: const Icon(Symbols.edit, size: 18),
              onPressed: () => _showEditVariableDialog(context, binding, l10n),
            ),
          if (isSecret)
            IconButton(
              icon: const Icon(Symbols.lock_reset, size: 18),
              onPressed: () => _showUpdateSecretDialog(context, binding.name, l10n),
            ),
          IconButton(
            icon: const Icon(Symbols.close, size: 18),
            onPressed: () => _removeBinding(binding.name),
          ),
        ],
      ),
    );
  }

  void _removeBinding(String name) {
    setState(() {
      _localBindings?.removeWhere((b) => b.name == name);
    });
    unawaited(_saveSettings());
  }

  void _showEditVariableDialog(BuildContext context, WorkerBinding binding, AppLocalizations l10n) {
    final controller = TextEditingController(text: binding.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(binding.name),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.pages_variableValue),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.common_cancel)),
          TextButton(
            onPressed: () {
              final index = _localBindings?.indexWhere((b) => b.name == binding.name);
              if (index != null && index != -1) {
                setState(() {
                  _localBindings![index] = binding.copyWith(text: controller.text.trim());
                });
                Navigator.pop(context);
                unawaited(_saveSettings());
              }
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
    String selectedType = 'plain_text';
    String? selectedResourceId;

    final kvAsync = ref.read(kvNamespacesProvider);
    final r2Async = ref.read(r2BucketsProvider);
    final d1Async = ref.read(d1DatabasesProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.workers_settings_addBinding),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: l10n.workers_settings_bindingType),
                  value: selectedType,
                  items: [
                    DropdownMenuItem(value: 'plain_text', child: Text(l10n.workers_settings_envVariable)),
                    DropdownMenuItem(value: 'secret_text', child: Text(l10n.workers_settings_bindingSecret)),
                    DropdownMenuItem(value: 'kv_namespace', child: Text(l10n.workers_bindings_kv)),
                    DropdownMenuItem(value: 'r2_bucket', child: Text(l10n.workers_bindings_r2)),
                    DropdownMenuItem(value: 'd1', child: Text(l10n.workers_bindings_d1)),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.record_name,
                    hintText: 'MY_BINDING',
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedType == 'plain_text' || selectedType == 'secret_text')
                  TextField(
                    controller: valueController,
                    decoration: InputDecoration(labelText: l10n.pages_variableValue),
                    obscureText: selectedType == 'secret_text',
                  )
                else if (selectedType == 'kv_namespace')
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: l10n.workers_bindings_kv),
                    items: kvAsync.valueOrNull?.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title))).toList() ?? [],
                    onChanged: (val) => setDialogState(() => selectedResourceId = val),
                  )
                else if (selectedType == 'r2_bucket')
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: l10n.workers_bindings_r2),
                    items: r2Async.valueOrNull?.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList() ?? [],
                    onChanged: (val) => setDialogState(() => selectedResourceId = val),
                  )
                else if (selectedType == 'd1')
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: l10n.workers_bindings_d1),
                    items: d1Async.valueOrNull?.map((e) => DropdownMenuItem(value: e.uuid, child: Text(e.name))).toList() ?? [],
                    onChanged: (val) => setDialogState(() => selectedResourceId = val),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.common_cancel)),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                if (selectedType == 'secret_text') {
                  Navigator.pop(context);
                  await ref.read(workerSettingsActionNotifierProvider.notifier).updateSecret(
                    scriptName: widget.worker.id,
                    name: name,
                    text: valueController.text.trim(),
                  );
                  return;
                }

                WorkerBinding? newBinding;
                if (selectedType == 'plain_text') {
                  newBinding = WorkerBinding(type: 'plain_text', name: name, text: valueController.text.trim());
                } else if (selectedType == 'kv_namespace' && selectedResourceId != null) {
                  newBinding = WorkerBinding(type: 'kv_namespace', name: name, namespaceId: selectedResourceId);
                } else if (selectedType == 'r2_bucket' && selectedResourceId != null) {
                  newBinding = WorkerBinding(type: 'r2_bucket', name: name, bucketName: selectedResourceId);
                } else if (selectedType == 'd1' && selectedResourceId != null) {
                  newBinding = WorkerBinding(type: 'd1', name: name, id: selectedResourceId);
                }

                if (newBinding != null) {
                  setState(() {
                    _localBindings = [...(_localBindings ?? []), newBinding!];
                  });
                  Navigator.pop(context);
                  unawaited(_saveSettings());
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