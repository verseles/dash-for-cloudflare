import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

/// Centralized error view for pages and major components
class CloudflareErrorView extends StatelessWidget {
  const CloudflareErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.showDashboardLink = true,
  });

  final Object error;
  final VoidCallback? onRetry;
  final bool showDashboardLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Parse error
    int? statusCode;
    String message = error.toString();
    String? details;

    if (error is DioException) {
      final dioError = error as DioException;
      statusCode = dioError.response?.statusCode;
      
      final data = dioError.response?.data;
      if (data is Map) {
        if (data.containsKey('errors')) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) {
            // Priority 1: Cloudflare-specific error message
            message = errors.map((e) => e['message']).join('\n');
            details = dioError.toString();
          }
        } else if (data.containsKey('message')) {
          message = data['message'].toString();
        }
      } else {
        message = dioError.message ?? message;
      }
    }

    final isForbidden = statusCode == 403;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isForbidden ? Symbols.lock : Symbols.error,
              size: 64,
              color: isForbidden ? Colors.orange : theme.colorScheme.error,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .shake(hz: 3, duration: 400.ms, offset: const Offset(2, 0)),
            const SizedBox(height: 24),
            Text(
              isForbidden ? l10n.error_permissionsRequired : l10n.common_error,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isForbidden ? l10n.error_permissionsDescription : message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (details != null && !isForbidden) ...[
              const SizedBox(height: 8),
              Text(
                details,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (isForbidden) ...[
              const SizedBox(height: 24),
              _buildPermissionsList(context, l10n),
            ],

            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (onRetry != null)
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Symbols.refresh),
                    label: Text(l10n.common_retry),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _copyError(context, error, details, l10n),
                  icon: const Icon(Symbols.content_copy),
                  label: Text(l10n.common_copy),
                ),
                if (isForbidden && showDashboardLink)
                  TextButton.icon(
                    onPressed: _openCloudflareDashboard,
                    icon: const Icon(Symbols.open_in_new),
                    label: Text(l10n.error_checkCloudflareDashboard),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsList(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final permissions = [
      'Account.Account Settings (Read)',
      'Zone.Zone (Read)',
      'Zone.DNS (Read/Edit)',
      'Zone.Analytics (Read)',
      'Account.Workers Scripts (Read/Edit)',
      'Account.Cloudflare Pages (Read/Edit)',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.error_commonPermissionsTitle,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...permissions.map((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Symbols.check_circle, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(p, style: theme.textTheme.bodySmall),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _copyError(BuildContext context, Object error, String? details, AppLocalizations l10n) {
    final fullError = 'Error: $error\nDetails: ${details ?? "None"}';
    Clipboard.setData(ClipboardData(text: fullError));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.common_copied)),
    );
  }

  Future<void> _openCloudflareDashboard() async {
    final url = Uri.parse('https://dash.cloudflare.com/profile/api-tokens');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
