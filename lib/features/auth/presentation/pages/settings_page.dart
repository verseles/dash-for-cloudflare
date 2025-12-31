import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
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
  bool _clipboardHasValidToken = false;
  bool _justPasted = false;

  @override
  void initState() {
    super.initState();
    // Load existing token
    final settings = ref.read(settingsNotifierProvider).valueOrNull;
    _tokenController.text = settings?.cloudflareApiToken ?? '';
    _checkClipboard();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _checkClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final hasValidToken =
          data?.text != null && ApiConfig.isValidToken(data!.text);
      if (mounted) {
        setState(() {
          _clipboardHasValidToken = hasValidToken;
          // Reset justPasted if clipboard changed
          if (!hasValidToken) {
            _justPasted = false;
          }
        });
      }
    } catch (_) {
      // Clipboard access might fail on some platforms
    }
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
        setState(() {
          _justPasted = true;
          _clipboardHasValidToken = false; // Hide button after paste
        });
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
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final hasValidToken = ref.watch(hasValidTokenProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_title),
        leading: hasValidToken
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(AppRoutes.dnsRecords),
              )
            : null,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${l10n.common_error}: $error')),
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
                          l10n.settings_cloudflareApiToken,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tokenController,
                      obscureText: _obscureToken,
                      decoration: InputDecoration(
                        labelText: l10n.settings_apiToken,
                        hintText: l10n.settings_apiTokenHint,
                        errorText: _tokenError,
                        prefixIcon: _buildPasteButton(),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                      onTap: _checkClipboard, // Re-check clipboard on focus
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.settings_requiredPermissions,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(l10n.settings_createTokenOnCloudflare),
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
                          l10n.settings_theme,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode),
                          label: Text(l10n.settings_themeLight),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto),
                          label: Text(l10n.settings_themeSystem),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode),
                          label: Text(l10n.settings_themeDark),
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
                          l10n.settings_language,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: settings.locale,
                      decoration: InputDecoration(
                        labelText: l10n.settings_language,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(l10n.settings_languageEn),
                        ),
                        DropdownMenuItem(
                          value: 'pt',
                          child: Text(l10n.settings_languagePt),
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
            _buildStorageCard(context, l10n),

            const SizedBox(height: 16),

            // Debug Card (only on non-web platforms)
            if (!kIsWeb) _buildDebugCard(context, l10n),

            const SizedBox(height: 24),

            // Go to DNS button
            if (hasValidToken)
              FilledButton.icon(
                icon: const Icon(Icons.dns),
                label: Text(l10n.settings_goToDnsManagement),
                onPressed: () => context.go(AppRoutes.dnsRecords),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildPasteButton() {
    // Only show if clipboard has valid token and we haven't just pasted
    if (!_clipboardHasValidToken || _justPasted) {
      return null;
    }

    return IconButton(
      icon: Icon(
        Icons.content_paste,
        color: Colors.green.shade600,
      ),
      tooltip: 'Paste from clipboard',
      onPressed: _pasteFromClipboard,
    );
  }

  Widget _buildDebugCard(BuildContext context, AppLocalizations l10n) {
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
                  l10n.settings_debug,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.settings_saveLogsToFile),
              subtitle: Text(l10n.settings_saveLogsDescription),
              value: fileLoggingEnabled,
              onChanged: (value) {
                ref.read(fileLoggingEnabledProvider.notifier).setEnabled(value);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l10n.settings_viewDebugLogs),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.debugLogs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context, AppLocalizations l10n) {
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
                  l10n.settings_storage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.settings_clearCache),
              subtitle: Text(l10n.settings_clearCacheDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearCacheDialog(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearCacheDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    // Save messenger before async gap
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settings_clearCacheTitle),
        content: Text(l10n.settings_clearCacheMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.settings_clearCache),
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
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.settings_cacheCleared),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
