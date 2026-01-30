import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/models/dns_record.dart';
import '../../providers/dns_records_provider.dart';
import '../../providers/zone_provider.dart';

/// Dialog para configurar Email Security (SPF, DKIM, DMARC)
class EmailSecurityDialog extends ConsumerStatefulWidget {
  const EmailSecurityDialog({super.key});

  @override
  ConsumerState<EmailSecurityDialog> createState() =>
      _EmailSecurityDialogState();
}

class _EmailSecurityDialogState extends ConsumerState<EmailSecurityDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // SPF Controllers
  final _spfIncludesController = TextEditingController();
  final _spfPolicyController = TextEditingController(text: '~all');

  // DKIM Controllers
  final _dkimSelectorController = TextEditingController(text: 'default');
  final _dkimPublicKeyController = TextEditingController();

  // DMARC Controllers
  String _dmarcPolicy = 'none';
  final _dmarcRuaController = TextEditingController();
  final _dmarcRufController = TextEditingController();
  int _dmarcPct = 100;

  DnsRecord? _existingSpf;
  DnsRecord? _existingDkim;
  DnsRecord? _existingDmarc;

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadExistingRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _spfIncludesController.dispose();
    _spfPolicyController.dispose();
    _dkimSelectorController.dispose();
    _dkimPublicKeyController.dispose();
    _dmarcRuaController.dispose();
    _dmarcRufController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingRecords() async {
    final recordsState = ref.read(dnsRecordsNotifierProvider).value;
    if (recordsState == null) return;

    final records = recordsState.records;
    final zone = ref.read(selectedZoneNotifierProvider);
    if (zone == null) return;

    // Detect existing records
    _existingSpf = records.firstWhere(
      (r) => r.type == 'TXT' && r.name == zone.name && r.content.startsWith('v=spf1'),
      orElse: () => DnsRecord(id: '', type: '', name: ''),
    );
    if (_existingSpf?.id.isEmpty ?? true) _existingSpf = null;

    _existingDkim = records.firstWhere(
      (r) => r.type == 'TXT' && r.name.contains('._domainkey') && r.content.startsWith('v=DKIM1'),
      orElse: () => DnsRecord(id: '', type: '', name: ''),
    );
    if (_existingDkim?.id.isEmpty ?? true) _existingDkim = null;

    _existingDmarc = records.firstWhere(
      (r) => r.type == 'TXT' && r.name == '_dmarc.${zone.name}' && r.content.startsWith('v=DMARC1'),
      orElse: () => DnsRecord(id: '', type: '', name: ''),
    );
    if (_existingDmarc?.id.isEmpty ?? true) _existingDmarc = null;

    // Parse existing values
    if (_existingSpf != null) {
      _parseSpf(_existingSpf!.content);
    }
    if (_existingDkim != null) {
      _parseDkim(_existingDkim!.name, _existingDkim!.content);
    }
    if (_existingDmarc != null) {
      _parseDmarc(_existingDmarc!.content);
    }

    if (mounted) setState(() {});
  }

  void _parseSpf(String content) {
    // Parse: v=spf1 include:_spf.google.com ~all
    final parts = content.split(' ');
    final includes = parts
        .where((p) => p.startsWith('include:'))
        .map((p) => p.substring(8))
        .join(' ');
    final policy = parts.lastWhere((p) => p.contains('all'), orElse: () => '~all');

    _spfIncludesController.text = includes;
    _spfPolicyController.text = policy;
  }

  void _parseDkim(String name, String content) {
    // Parse: selector._domainkey.domain.com → selector
    final parts = name.split('.');
    if (parts.isNotEmpty) {
      _dkimSelectorController.text = parts.first;
    }

    // Parse: v=DKIM1; k=rsa; p=MIGf...
    final pubKeyMatch = RegExp(r'p=([^;]+)').firstMatch(content);
    if (pubKeyMatch != null) {
      _dkimPublicKeyController.text = pubKeyMatch.group(1) ?? '';
    }
  }

  void _parseDmarc(String content) {
    // Parse: v=DMARC1; p=quarantine; rua=mailto:dmarc@domain.com
    final policyMatch = RegExp(r'p=(\w+)').firstMatch(content);
    if (policyMatch != null) {
      _dmarcPolicy = policyMatch.group(1) ?? 'none';
    }

    final ruaMatch = RegExp(r'rua=mailto:([^;]+)').firstMatch(content);
    if (ruaMatch != null) {
      _dmarcRuaController.text = ruaMatch.group(1) ?? '';
    }

    final rufMatch = RegExp(r'ruf=mailto:([^;]+)').firstMatch(content);
    if (rufMatch != null) {
      _dmarcRufController.text = rufMatch.group(1) ?? '';
    }

    final pctMatch = RegExp(r'pct=(\d+)').firstMatch(content);
    if (pctMatch != null) {
      _dmarcPct = int.tryParse(pctMatch.group(1) ?? '100') ?? 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Symbols.email, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    l10n.dnsSettings_emailSecurity,
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Symbols.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // TabBar
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'SPF', icon: const Icon(Symbols.add_circle, fill: 1)),
                Tab(text: 'DKIM', icon: const Icon(Symbols.add_circle, fill: 1)),
                Tab(text: 'DMARC', icon: const Icon(Symbols.add_circle, fill: 1)),
              ],
            ),

            // TabView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSpfTab(l10n),
                  _buildDkimTab(l10n),
                  _buildDmarcTab(l10n),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.common_cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saveCurrentTab,
                    child: Text(l10n.common_save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpfTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_existingSpf != null)
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Symbols.check_circle, color: Colors.green, fill: 1),
                title: Text(l10n.emailSecurity_spfExists),
                subtitle: Text(_existingSpf!.content),
              ),
            )
          else
            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: const Icon(Symbols.warning, color: Colors.orange, fill: 1),
                title: Text(l10n.emailSecurity_spfNotConfigured),
              ),
            ),
          const SizedBox(height: 16),

          Text(
            l10n.emailSecurity_spfDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _spfIncludesController,
            decoration: InputDecoration(
              labelText: l10n.emailSecurity_spfIncludes,
              helperText: l10n.emailSecurity_spfIncludesHint,
              helperMaxLines: 2,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _spfPolicyController,
            decoration: InputDecoration(
              labelText: l10n.emailSecurity_spfPolicy,
              helperText: l10n.emailSecurity_spfPolicyHint,
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            '${l10n.emailSecurity_preview}:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _buildSpfRecord(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDkimTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_existingDkim != null)
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Symbols.check_circle, color: Colors.green, fill: 1),
                title: Text(l10n.emailSecurity_dkimExists),
                subtitle: Text(_existingDkim!.name),
              ),
            )
          else
            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: const Icon(Symbols.warning, color: Colors.orange, fill: 1),
                title: Text(l10n.emailSecurity_dkimNotConfigured),
              ),
            ),
          const SizedBox(height: 16),

          Text(
            l10n.emailSecurity_dkimDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _dkimSelectorController,
            decoration: InputDecoration(
              labelText: l10n.emailSecurity_dkimSelector,
              helperText: l10n.emailSecurity_dkimSelectorHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _dkimPublicKeyController,
            decoration: InputDecoration(
              labelText: l10n.emailSecurity_dkimPublicKey,
              helperText: l10n.emailSecurity_dkimPublicKeyHint,
              helperMaxLines: 2,
              border: const OutlineInputBorder(),
            ),
            maxLines: 5,
          ),

          const SizedBox(height: 24),
          Text(
            '${l10n.emailSecurity_recordName}:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _buildDkimName(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDmarcTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_existingDmarc != null)
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Symbols.check_circle, color: Colors.green, fill: 1),
                title: Text(l10n.emailSecurity_dmarcExists),
                subtitle: Text(_existingDmarc!.content),
              ),
            )
          else
            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: const Icon(Symbols.warning, color: Colors.orange, fill: 1),
                title: Text(l10n.emailSecurity_dmarcNotConfigured),
              ),
            ),
          const SizedBox(height: 16),

          Text(
            l10n.emailSecurity_dmarcDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            initialValue: _dmarcPolicy,
            decoration: InputDecoration(
              labelText: l10n.emailSecurity_dmarcPolicy,
              helperText: l10n.emailSecurity_dmarcPolicyHint,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'none', child: Text(l10n.emailSecurity_dmarcPolicyNone)),
              DropdownMenuItem(value: 'quarantine', child: Text(l10n.emailSecurity_dmarcPolicyQuarantine)),
              DropdownMenuItem(value: 'reject', child: Text(l10n.emailSecurity_dmarcPolicyReject)),
            ],
            onChanged: (value) => setState(() => _dmarcPolicy = value ?? 'none'),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _dmarcRuaController,
            decoration: InputDecoration(
              labelText: l10n.emailSecurity_dmarcRua,
              helperText: l10n.emailSecurity_dmarcRuaHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _dmarcRufController,
            decoration: InputDecoration(
              labelText: l10n.emailSecurity_dmarcRuf,
              helperText: l10n.emailSecurity_dmarcRufHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          Text('${l10n.emailSecurity_dmarcPct}: $_dmarcPct%'),
          Slider(
            value: _dmarcPct.toDouble(),
            min: 0,
            max: 100,
            divisions: 10,
            label: '$_dmarcPct%',
            onChanged: (value) => setState(() => _dmarcPct = value.toInt()),
          ),

          const SizedBox(height: 24),
          Text(
            '${l10n.emailSecurity_preview}:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _buildDmarcRecord(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSpfRecord() {
    final includes = _spfIncludesController.text.trim();
    final policy = _spfPolicyController.text.trim();

    final parts = ['v=spf1'];
    if (includes.isNotEmpty) {
      for (final include in includes.split(' ')) {
        if (include.trim().isNotEmpty) {
          parts.add('include:${include.trim()}');
        }
      }
    }
    parts.add(policy.isEmpty ? '~all' : policy);

    return parts.join(' ');
  }

  String _buildDkimName() {
    final zone = ref.read(selectedZoneNotifierProvider);
    if (zone == null) return '';

    final selector = _dkimSelectorController.text.trim();
    return '$selector._domainkey.${zone.name}';
  }

  String _buildDkimRecord() {
    final pubKey = _dkimPublicKeyController.text.trim();
    return 'v=DKIM1; k=rsa; p=$pubKey';
  }

  String _buildDmarcRecord() {
    final parts = ['v=DMARC1', 'p=$_dmarcPolicy'];

    if (_dmarcRuaController.text.trim().isNotEmpty) {
      parts.add('rua=mailto:${_dmarcRuaController.text.trim()}');
    }
    if (_dmarcRufController.text.trim().isNotEmpty) {
      parts.add('ruf=mailto:${_dmarcRufController.text.trim()}');
    }
    if (_dmarcPct < 100) {
      parts.add('pct=$_dmarcPct');
    }

    return parts.join('; ');
  }

  Future<void> _saveCurrentTab() async {
    final index = _tabController.index;

    switch (index) {
      case 0:
        await _saveSPF();
        break;
      case 1:
        await _saveDKIM();
        break;
      case 2:
        await _saveDMARC();
        break;
    }
  }

  Future<void> _saveSPF() async {
    final zone = ref.read(selectedZoneNotifierProvider);
    if (zone == null) return;

    final content = _buildSpfRecord();
    final notifier = ref.read(dnsRecordsNotifierProvider.notifier);

    try {
      final record = _existingSpf ?? DnsRecord(
        id: '',
        type: 'TXT',
        name: zone.name,
        content: content,
        ttl: 1,
        proxied: false,
      );

      await notifier.saveRecord(
        record.copyWith(
          name: zone.name,
          content: content,
          ttl: 1,
          proxied: false,
        ),
        isNew: _existingSpf == null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).emailSecurity_spfSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _saveDKIM() async {
    final zone = ref.read(selectedZoneNotifierProvider);
    if (zone == null) return;

    if (_dkimPublicKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).emailSecurity_dkimPublicKeyRequired)),
      );
      return;
    }

    final name = _buildDkimName();
    final content = _buildDkimRecord();
    final notifier = ref.read(dnsRecordsNotifierProvider.notifier);

    try {
      final record = _existingDkim ?? DnsRecord(
        id: '',
        type: 'TXT',
        name: name,
        content: content,
        ttl: 1,
        proxied: false,
      );

      await notifier.saveRecord(
        record.copyWith(
          name: name,
          content: content,
          ttl: 1,
          proxied: false,
        ),
        isNew: _existingDkim == null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).emailSecurity_dkimSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _saveDMARC() async {
    final zone = ref.read(selectedZoneNotifierProvider);
    if (zone == null) return;

    final name = '_dmarc.${zone.name}';
    final content = _buildDmarcRecord();
    final notifier = ref.read(dnsRecordsNotifierProvider.notifier);

    try {
      final record = _existingDmarc ?? DnsRecord(
        id: '',
        type: 'TXT',
        name: name,
        content: content,
        ttl: 1,
        proxied: false,
      );

      await notifier.saveRecord(
        record.copyWith(
          name: name,
          content: content,
          ttl: 1,
          proxied: false,
        ),
        isNew: _existingDmarc == null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).emailSecurity_dmarcSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
