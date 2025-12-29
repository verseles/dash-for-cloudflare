import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dns_settings_provider.dart';
import '../../providers/zone_provider.dart';

/// DNS Settings page for DNSSEC, multi-provider, etc.
class DnsSettingsPage extends ConsumerWidget {
  const DnsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final settingsAsync = ref.watch(dnsSettingsNotifierProvider);

    if (selectedZone == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.domain, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Select a zone to view settings'),
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
            Text('Error: $error'),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () =>
                  ref.read(dnsSettingsNotifierProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
      data: (state) => _buildContent(context, ref, state, selectedZone),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DnsZoneSettingsState state,
    dynamic zone,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // DNSSEC Card
        _buildDnssecCard(context, ref, state, zone),
        const SizedBox(height: 16),

        // Multi-provider DNS
        _buildSettingCard(
          context,
          title: 'Multi-Provider DNS',
          subtitle: 'Allow multiple DNS providers to be used for this zone',
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
        _buildCnameFlatteningCard(context, ref, state),
        const SizedBox(height: 16),

        // Email Security (placeholder)
        _buildEmailSecurityCard(context),
      ],
    );
  }

  Widget _buildDnssecCard(
    BuildContext context,
    WidgetRef ref,
    DnsZoneSettingsState state,
    dynamic zone,
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
        statusText = 'DNSSEC is active';
        break;
      case 'pending':
        statusIcon = Icons.hourglass_top;
        statusColor = Colors.orange;
        statusText = 'DNSSEC pending activation';
        break;
      case 'pending-disabled':
        statusIcon = Icons.hourglass_top;
        statusColor = Colors.orange;
        statusText = 'DNSSEC pending deactivation';
        break;
      default:
        statusIcon = Icons.shield_outlined;
        statusColor = Colors.grey;
        statusText = 'DNSSEC is disabled';
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
                Text('DNSSEC', style: Theme.of(context).textTheme.titleMedium),
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
                'Enable DNSSEC to add an extra layer of authentication to your DNS records.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                          .read(dnsSettingsNotifierProvider.notifier)
                          .toggleDnssec(enable: true),
                child: const Text('Enable DNSSEC'),
              ),
            ],

            if (status == 'pending' && dnssec != null) ...[
              if (zone?.registrar?.name?.toLowerCase() == 'cloudflare') ...[
                Text(
                  'DS record will be added automatically since you\'re using Cloudflare as your registrar.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else ...[
                Text(
                  'Copy the DS record below and add it to your domain registrar.',
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
                              const SnackBar(
                                content: Text('DS record copied!'),
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
                child: const Text('Cancel'),
              ),
            ],

            if (status == 'active') ...[
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Multi-signer DNSSEC'),
                      subtitle: const Text('Allow multiple DNSSEC signers'),
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
                    label: const Text('View Details'),
                    onPressed: () => _showDnssecDetails(context, dnssec),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: state.isLoading
                        ? null
                        : () => _confirmDisableDnssec(context, ref),
                    child: const Text('Disable'),
                  ),
                ],
              ),
            ],

            if (status == 'pending-disabled') ...[
              Text(
                'DNSSEC is being disabled. This may take some time.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: state.isLoading
                    ? null
                    : () => ref
                          .read(dnsSettingsNotifierProvider.notifier)
                          .toggleDnssec(enable: true),
                child: const Text('Cancel Deactivation'),
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
                  'CNAME Flattening',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Flatten CNAMEs to A/AAAA records to improve performance',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'flatten_at_root',
                  label: Text('Root only'),
                ),
                ButtonSegment(value: 'flatten_all', label: Text('All')),
                ButtonSegment(value: 'flatten_none', label: Text('None')),
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

  Widget _buildEmailSecurityCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.email,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Email Security'),
        subtitle: const Text('Configure email authentication records'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Work in progress. This feature will be available soon!',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDnssecDetails(BuildContext context, dynamic dnssec) {
    if (dnssec == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DNSSEC Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(context, 'DS Record', dnssec.ds),
              _buildDetailRow(context, 'Digest', dnssec.digest),
              _buildDetailRow(context, 'Digest Type', dnssec.digestType),
              _buildDetailRow(context, 'Algorithm', dnssec.algorithm),
              _buildDetailRow(context, 'Public Key', dnssec.publicKey),
              _buildDetailRow(context, 'Key Tag', dnssec.keyTag?.toString()),
              _buildDetailRow(context, 'Flags', dnssec.flags?.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
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
              ).showSnackBar(SnackBar(content: Text('$label copied!')));
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

  void _confirmDisableDnssec(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable DNSSEC?'),
        content: const Text(
          'Disabling DNSSEC will remove the extra layer of authentication from your DNS records. '
          'You will need to remove the DS record from your registrar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(dnsSettingsNotifierProvider.notifier)
                  .toggleDnssec(enable: false);
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }
}
