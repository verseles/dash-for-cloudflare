import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dns_settings_provider.dart';
import '../../providers/zone_provider.dart';

/// DNS Settings page for DNSSEC, multi-provider, etc.
class DnsSettingsPage extends ConsumerWidget {
  const DnsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final settingsAsync = ref.watch(dnsSettingsNotifierProvider);

    if (selectedZone == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.domain, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.dns_selectZoneFirst),
          ],
        ),
      );
    }

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(l10n.error_prefix(error.toString())),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(l10n.common_retry),
              onPressed: () =>
                  ref.read(dnsSettingsNotifierProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
      data: (state) => _buildContent(context, ref, state, selectedZone, l10n),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DnsZoneSettingsState state,
    dynamic zone,
    AppLocalizations l10n,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // DNSSEC Card
        _buildDnssecCard(context, ref, state, zone, l10n),
        const SizedBox(height: 16),

        // Multi-provider DNS
        _buildSettingCard(
          context,
          title: l10n.dnsSettings_multiProviderDns,
          subtitle: l10n.dnsSettings_multiProviderDescription,
          icon: Icons.dns,
          value: state.dnsSettings?.multiProvider ?? false,
          isLoading: state.isLoading,
          onChanged: (value) {
            ref
                .read(dnsSettingsNotifierProvider.notifier)
                .toggleMultiProvider(enable: value);
          },
        ),
        const SizedBox(height: 16),

        // CNAME Flattening
        _buildCnameFlatteningCard(context, ref, state, l10n),
        const SizedBox(height: 16),

        // Email Security (placeholder)
        _buildEmailSecurityCard(context, l10n),
      ],
    );
  }

  Widget _buildDnssecCard(
    BuildContext context,
    WidgetRef ref,
    DnsZoneSettingsState state,
    dynamic zone,
    AppLocalizations l10n,
  ) {
    final dnssec = state.dnssec;
    final status = dnssec?.status ?? 'disabled';

    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'active':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = l10n.dnsSettings_dnssecActive;
        break;
      case 'pending':
        statusIcon = Icons.hourglass_top;
        statusColor = Colors.orange;
        statusText = l10n.dnsSettings_dnssecPending;
        break;
      case 'pending-disabled':
        statusIcon = Icons.hourglass_top;
        statusColor = Colors.orange;
        statusText = l10n.dnsSettings_dnssecPendingDisable;
        break;
      default:
        statusIcon = Icons.shield_outlined;
        statusColor = Colors.grey;
        statusText = l10n.dnsSettings_dnssecDisabled;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.dnsSettings_dnssec,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (state.isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(statusText),
              ],
            ),
            const SizedBox(height: 16),

            if (status == 'disabled') ...[
              Text(
                l10n.dnsSettings_dnssecDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                          .read(dnsSettingsNotifierProvider.notifier)
                          .toggleDnssec(enable: true),
                child: Text(l10n.dnsSettings_enableDnssec),
              ),
            ],

            if (status == 'pending' && dnssec != null) ...[
              if (zone?.registrar?.name?.toLowerCase() == 'cloudflare') ...[
                Text(
                  l10n.dnsSettings_dnssecPendingCf,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else ...[
                Text(
                  l10n.dnsSettings_addDsToRegistrar,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (dnssec.ds != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dnssec.ds!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: dnssec.ds!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.dnsSettings_dsRecordCopied),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                          .read(dnsSettingsNotifierProvider.notifier)
                          .toggleDnssec(enable: false),
                child: Text(l10n.common_cancel),
              ),
            ],

            if (status == 'active') ...[
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.dnsSettings_multiSignerDnssec),
                      subtitle: Text(l10n.dnsSettings_multiSignerDescription),
                      value: dnssec?.dnssecMultiSigner ?? false,
                      onChanged: state.isLoading
                          ? null
                          : (value) => ref
                                .read(dnsSettingsNotifierProvider.notifier)
                                .toggleMultiSignerDnssec(enable: value),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: Text(l10n.dnsSettings_viewDetails),
                    onPressed: () => _showDnssecDetails(context, dnssec, l10n),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: state.isLoading
                        ? null
                        : () => _confirmDisableDnssec(context, ref, l10n),
                    child: Text(l10n.common_disable),
                  ),
                ],
              ),
            ],

            if (status == 'pending-disabled') ...[
              Text(
                l10n.dnsSettings_dnssecPendingDisable,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                          .read(dnsSettingsNotifierProvider.notifier)
                          .toggleDnssec(enable: true),
                child: Text(l10n.dnsSettings_cancelDeactivation),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool isLoading,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: isLoading ? null : onChanged,
      ),
    );
  }

  Widget _buildCnameFlatteningCard(
    BuildContext context,
    WidgetRef ref,
    DnsZoneSettingsState state,
    AppLocalizations l10n,
  ) {
    final value = state.cnameFlattening ?? 'flatten_at_root';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.dnsSettings_cnameFlattening,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dnsSettings_cnameFlatteningDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'flatten_at_root',
                  label: Text(l10n.common_rootOnly),
                ),
                ButtonSegment(
                  value: 'flatten_all',
                  label: Text(l10n.common_all),
                ),
                ButtonSegment(
                  value: 'flatten_none',
                  label: Text(l10n.common_none),
                ),
              ],
              selected: {value},
              onSelectionChanged: state.isLoading
                  ? null
                  : (selection) {
                      ref
                          .read(dnsSettingsNotifierProvider.notifier)
                          .toggleCnameFlattening(value: selection.first);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSecurityCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.email,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(l10n.dnsSettings_emailSecurity),
        subtitle: Text(l10n.dnsSettings_emailSecurityDescription),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.common_workInProgress)));
        },
      ),
    );
  }

  void _showDnssecDetails(
    BuildContext context,
    dynamic dnssec,
    AppLocalizations l10n,
  ) {
    if (dnssec == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dnssecDetails_title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                context,
                l10n.dnssecDetails_dsRecord,
                dnssec.ds,
                l10n,
              ),
              _buildDetailRow(
                context,
                l10n.dnssecDetails_digest,
                dnssec.digest,
                l10n,
              ),
              _buildDetailRow(
                context,
                l10n.dnssecDetails_digestType,
                dnssec.digestType,
                l10n,
              ),
              _buildDetailRow(
                context,
                l10n.dnssecDetails_algorithm,
                dnssec.algorithm,
                l10n,
              ),
              _buildDetailRow(
                context,
                l10n.dnssecDetails_publicKey,
                dnssec.publicKey,
                l10n,
              ),
              _buildDetailRow(
                context,
                l10n.dnssecDetails_keyTag,
                dnssec.keyTag?.toString(),
                l10n,
              ),
              _buildDetailRow(
                context,
                l10n.dnssecDetails_flags,
                dnssec.flags?.toString(),
                l10n,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String? value,
    AppLocalizations l10n,
  ) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.common_copied)));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Icon(Icons.copy, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDisableDnssec(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dnsSettings_disableDnssecTitle),
        content: Text(l10n.dnsSettings_dnssecDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(dnsSettingsNotifierProvider.notifier)
                  .toggleDnssec(enable: false);
            },
            child: Text(l10n.common_disable),
          ),
        ],
      ),
    );
  }
}
