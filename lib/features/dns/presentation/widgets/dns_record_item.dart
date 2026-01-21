import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/models/dns_record.dart';
import '../../../../core/theme/app_theme.dart';
import 'cloudflare_proxy_toggle.dart';

/// DNS Record list item with swipe-to-delete
class DnsRecordItem extends StatelessWidget {
  const DnsRecordItem({
    super.key,
    required this.record,
    required this.isSaving,
    required this.isNew,
    required this.isDeleting,
    required this.onTap,
    required this.onDelete,
    required this.onProxyToggle,
  });

  final DnsRecord record;
  final bool isSaving;
  final bool isNew;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool> onProxyToggle;

  @override
  Widget build(BuildContext context) {
    final canProxy = ['A', 'AAAA', 'CNAME'].contains(record.type);
    final theme = Theme.of(context);

    final Widget card = Card(
      color: isNew
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : isDeleting
          ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Type chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getRecordTypeColor(
                    record.type,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  record.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: getRecordTypeColor(record.type),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name and content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecordName(context),
                    const SizedBox(height: 4),
                    Text(
                      record.content,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // TTL
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTtl(record.ttl),
                    style: theme.textTheme.bodySmall,
                  ),
                  if (canProxy) ...[
                    const SizedBox(height: 4),
                    CloudflareProxyToggle(
                      value: record.proxied,
                      isLoading: isSaving,
                      onChanged: onProxyToggle,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with Dismissible for swipe-to-delete
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      child: card,
    );
  }

  Widget _buildRecordName(BuildContext context) {
    final theme = Theme.of(context);

    // Check if name is root
    if (record.name == record.zoneName) {
      return Text(
        '@',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Check if name ends with zone name
    final suffix = '.${record.zoneName}';
    if (record.name.endsWith(suffix)) {
      final prefix = record.name.substring(
        0,
        record.name.length - suffix.length,
      );
      return Row(
        children: [
          Text(
            prefix,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            suffix,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.outline),
          ),
        ],
      );
    }

    // Full name
    return Text(
      record.name,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  String _formatTtl(int ttl) {
    if (ttl == 1) return 'Auto';
    if (ttl < 60) return '${ttl}s';
    if (ttl < 3600) return '${ttl ~/ 60}m';
    if (ttl < 86400) return '${ttl ~/ 3600}h';
    return '${ttl ~/ 86400}d';
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dns_deleteRecordConfirmTitle),
        content: Text(l10n.dns_deleteRecordConfirmMessage(record.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
