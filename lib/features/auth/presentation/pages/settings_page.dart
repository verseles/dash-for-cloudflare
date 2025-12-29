import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../providers/settings_provider.dart';
import '../../../../core/api/api_config.dart';

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
}
