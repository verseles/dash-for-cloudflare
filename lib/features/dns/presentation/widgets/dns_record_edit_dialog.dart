import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/dns_record.dart';
import '../../providers/dns_records_provider.dart';
import '../../providers/zone_provider.dart';
import 'cloudflare_proxy_toggle.dart';

/// DNS Record edit/create dialog
class DnsRecordEditDialog extends ConsumerStatefulWidget {
  final DnsRecord? record;

  const DnsRecordEditDialog({super.key, this.record});

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

  static const _ttlOptions = [
    (label: 'Auto', value: 1),
    (label: '2 minutes', value: 120),
    (label: '5 minutes', value: 300),
    (label: '10 minutes', value: 600),
    (label: '15 minutes', value: 900),
    (label: '30 minutes', value: 1800),
    (label: '1 hour', value: 3600),
    (label: '2 hours', value: 7200),
    (label: '5 hours', value: 18000),
    (label: '12 hours', value: 43200),
    (label: '1 day', value: 86400),
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
          SnackBar(content: Text(_isNew ? 'Record created' : 'Record updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isNew ? 'Create DNS Record' : 'Edit DNS Record'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type dropdown
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
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
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., www or @ for root',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Content field
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  hintText: _contentPlaceholders[_type] ?? 'Enter value',
                ),
                maxLines: _type == 'TXT' ? 3 : 1,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Content is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // TTL dropdown
              DropdownButtonFormField<int>(
                value: _ttl,
                decoration: const InputDecoration(labelText: 'TTL'),
                items: _ttlOptions
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
                    const Text('Proxy'),
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isNew ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
