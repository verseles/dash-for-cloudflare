import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/models/dns_record.dart';
import '../../providers/dns_records_provider.dart';
import '../../providers/zone_provider.dart';
import 'cloudflare_proxy_toggle.dart';

/// DNS Record edit/create dialog
class DnsRecordEditDialog extends ConsumerStatefulWidget {
  const DnsRecordEditDialog({super.key, this.record});

  final DnsRecord? record;

  @override
  ConsumerState<DnsRecordEditDialog> createState() =>
      _DnsRecordEditDialogState();
}

class _DnsRecordEditDialogState extends ConsumerState<DnsRecordEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  late int _ttl;
  late bool _proxied;
  bool _isSaving = false;

  bool get _isNew => widget.record == null;
  bool get _canProxy => ['A', 'AAAA', 'CNAME'].contains(_type);

  List<({String label, int value})> _getTtlOptions(AppLocalizations l10n) => [
    (label: l10n.dnsRecord_ttlAuto, value: 1),
    (label: l10n.dnsRecord_ttl2min, value: 120),
    (label: l10n.dnsRecord_ttl5min, value: 300),
    (label: l10n.dnsRecord_ttl10min, value: 600),
    (label: l10n.dnsRecord_ttl15min, value: 900),
    (label: l10n.dnsRecord_ttl30min, value: 1800),
    (label: l10n.dnsRecord_ttl1hour, value: 3600),
    (label: l10n.dnsRecord_ttl2hours, value: 7200),
    (label: l10n.dnsRecord_ttl5hours, value: 18000),
    (label: l10n.dnsRecord_ttl12hours, value: 43200),
    (label: l10n.dnsRecord_ttl1day, value: 86400),
  ];

  static const _contentPlaceholders = {
    'A': '192.168.1.1',
    'AAAA': '2001:db8::1',
    'CNAME': 'example.com',
    'TXT': '"v=spf1 include:_spf.google.com ~all"',
    'MX': 'mail.example.com',
    'SRV': '10 5 443 target.example.com',
    'NS': 'ns1.example.com',
    'PTR': 'example.com',
  };

  @override
  void initState() {
    super.initState();
    _type = widget.record?.type ?? 'A';
    _nameController = TextEditingController(text: widget.record?.name ?? '');
    _contentController = TextEditingController(
      text: widget.record?.content ?? '',
    );
    _ttl = widget.record?.ttl ?? 1;
    _proxied = widget.record?.proxied ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);

    try {
      final zone = ref.read(selectedZoneNotifierProvider);
      if (zone == null) throw Exception('No zone selected');

      final record = DnsRecord(
        id: widget.record?.id ?? '',
        type: _type,
        name: _nameController.text.trim(),
        content: _contentController.text.trim(),
        ttl: _ttl,
        proxied: _canProxy ? _proxied : false,
        zoneId: zone.id,
        zoneName: zone.name,
      );

      await ref
          .read(dnsRecordsNotifierProvider.notifier)
          .saveRecord(record, isNew: _isNew);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isNew
                  ? l10n.dnsRecord_recordCreated
                  : l10n.dnsRecord_recordUpdated,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10nErr = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10nErr.error_prefix(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ttlOptions = _getTtlOptions(l10n);

    return AlertDialog(
      title: Text(
        _isNew ? l10n.dnsRecord_createTitle : l10n.dnsRecord_editTitle,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type dropdown
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.record_type),
                items: recordTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: _isNew
                    ? (value) {
                        if (value != null) {
                          setState(() {
                            _type = value;
                            if (!_canProxy) _proxied = false;
                          });
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.record_name,
                  hintText: l10n.record_nameHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.record_nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Content field
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: l10n.record_content,
                  hintText:
                      _contentPlaceholders[_type] ?? l10n.dnsRecord_enterValue,
                ),
                maxLines: _type == 'TXT' ? 3 : 1,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.record_contentRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // TTL dropdown
              DropdownButtonFormField<int>(
                initialValue: _ttl,
                decoration: InputDecoration(labelText: l10n.record_ttl),
                items: ttlOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option.value,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _ttl = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Proxy toggle
              if (_canProxy) ...[
                Row(
                  children: [
                    Text(l10n.common_proxy),
                    const Spacer(),
                    CloudflareProxyToggle(
                      value: _proxied,
                      isLoading: false,
                      onChanged: (value) => setState(() => _proxied = value),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isNew ? l10n.common_create : l10n.common_save),
        ),
      ],
    );
  }
}
