import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../providers/settings_provider.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/logging/log_provider.dart';
import '../../../../core/providers/data_centers_provider.dart';
import '../../../dns/providers/dns_records_provider.dart';
import '../../../analytics/providers/analytics_provider.dart';

/// Settings page for API token, theme, and language
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _tokenController = TextEditingController();
  bool _obscureToken = true;
  String? _tokenError;

  @override
  void initState() {
    super.initState();
    // Load existing token
    final settings = ref.read(settingsNotifierProvider).valueOrNull;
    _tokenController.text = settings?.cloudflareApiToken ?? '';
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _validateAndSaveToken() {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      setState(() => _tokenError = null);
      ref.read(settingsNotifierProvider.notifier).setApiToken(null);
      return;
    }

    if (!ApiConfig.isValidToken(token)) {
      setState(
        () => _tokenError =
            'Token must be at least ${ApiConfig.minTokenLength} characters',
      );
      return;
    }

    setState(() => _tokenError = null);
    ref.read(settingsNotifierProvider.notifier).setApiToken(token);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && ApiConfig.isValidToken(data!.text)) {
      _tokenController.text = data.text!;
      _validateAndSaveToken();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token pasted from clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final hasValidToken = ref.watch(hasValidTokenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: hasValidToken
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(AppRoutes.dnsRecords),
              )
            : null,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // API Token Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.key,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cloudflare API Token',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tokenController,
                      obscureText: _obscureToken,
                      decoration: InputDecoration(
                        labelText: 'API Token',
                        hintText: 'Enter your Cloudflare API token',
                        errorText: _tokenError,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.content_paste),
                              tooltip: 'Paste from clipboard',
                              onPressed: _pasteFromClipboard,
                            ),
                            IconButton(
                              icon: Icon(
                                _obscureToken
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                () => _obscureToken = !_obscureToken,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: _validateAndSaveToken,
                            ),
                          ],
                        ),
                      ),
                      onSubmitted: (_) => _validateAndSaveToken(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Required permissions: Zone:Read, DNS:Read, DNS:Edit',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Create token on Cloudflare'),
                      onPressed: () {
                        // TODO: Launch URL
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Theme Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.palette,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Theme',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto),
                          label: Text('Auto'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (selection) {
                        ref
                            .read(settingsNotifierProvider.notifier)
                            .setThemeMode(selection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Language Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.language,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Language',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      // Using value instead of initialValue is required for dynamic updates
                      // ignore: deprecated_member_use
                      value: settings.locale,
                      decoration: const InputDecoration(
                        labelText: 'Select language',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(
                          value: 'pt',
                          child: Text('Português (Brasil)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsNotifierProvider.notifier)
                              .setLocale(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Storage Card
            _buildStorageCard(context),

            const SizedBox(height: 16),

            // Debug Card (only on non-web platforms)
            if (!kIsWeb) _buildDebugCard(context),

            const SizedBox(height: 24),

            // Go to DNS button
            if (hasValidToken)
              FilledButton.icon(
                icon: const Icon(Icons.dns),
                label: const Text('Go to DNS Management'),
                onPressed: () => context.go(AppRoutes.dnsRecords),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugCard(BuildContext context) {
    final fileLoggingEnabled = ref.watch(fileLoggingEnabledProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bug_report,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Debug',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Save logs to file'),
              subtitle: const Text('Persists logs for later analysis'),
              value: fileLoggingEnabled,
              onChanged: (value) {
                ref.read(fileLoggingEnabledProvider.notifier).setEnabled(value);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('View Debug Logs'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.debugLogs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Storage',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear Cache'),
              subtitle: const Text('DNS records, analytics, and data centers'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearCacheDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data including DNS records, analytics, and data center information.\n\n'
          'Data will be reloaded from the API on next access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    // Clear DNS records cache
    ref.invalidate(dnsRecordsNotifierProvider);
    // Clear analytics cache
    ref.invalidate(analyticsNotifierProvider);
    // Clear data centers cache
    ref.invalidate(dataCentersNotifierProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
