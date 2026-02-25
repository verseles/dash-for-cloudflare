import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/update_provider.dart';
import 'pwa_update_provider.dart';
import 'pwa_update_service.dart' as pwa;

/// Wraps the app to display update banners/snackbars.
///
/// On web: shows a [MaterialBanner] when a PWA service-worker update is ready.
/// On native (Android, desktop): shows a startup [SnackBar] when a GitHub
/// release update is available, and reacts to install state changes.
class UpdateBanner extends ConsumerStatefulWidget {
  const UpdateBanner({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<UpdateBanner> {
  // Guards so each install-state snackbar shows only once per install cycle.
  bool _shownProgressSnackBar = false;
  bool _shownDoneSnackBar = false;
  bool _shownFailedSnackBar = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Trigger silent startup check after the first frame so the UI is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(updateProvider.notifier).performStartupCheck();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // Listen for startup toast on native platforms.
      ref.listen(
        updateProvider.select((s) => s.pendingStartupToast),
        (_, isPending) {
          if (isPending && mounted) {
            ref.read(updateProvider.notifier).acknowledgeStartupToast();
            final version =
                ref.read(updateProvider).result?.latestVersion ?? '';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Update available: v$version'),
                  duration: const Duration(seconds: 8),
                  action: SnackBarAction(
                    label: 'Install',
                    onPressed: () =>
                        ref.read(updateProvider.notifier).startInstall(),
                  ),
                ),
              );
            });
          }
        },
      );

      // Listen for install state transitions.
      ref.listen(
        updateProvider.select((s) => s.installState),
        (_, installState) {
          if (!mounted) return;
          switch (installState) {
            case UpdateInstallState.idle:
              _shownProgressSnackBar = false;
              _shownDoneSnackBar = false;
              _shownFailedSnackBar = false;
            case UpdateInstallState.downloading:
              if (!_shownProgressSnackBar) {
                _shownProgressSnackBar = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Downloading update…'),
                    duration: Duration(days: 1), // dismissed programmatically
                  ),
                );
              }
            case UpdateInstallState.done:
              if (!_shownDoneSnackBar) {
                _shownDoneSnackBar = true;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Update installed. Restart to apply.'),
                    duration: Duration(seconds: 8),
                  ),
                );
              }
            case UpdateInstallState.failed:
              if (!_shownFailedSnackBar) {
                _shownFailedSnackBar = true;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Install failed.'),
                    duration: const Duration(seconds: 8),
                    action: SnackBarAction(
                      label: 'Retry',
                      onPressed: () =>
                          ref.read(updateProvider.notifier).startInstall(),
                    ),
                  ),
                );
              }
            default:
              break;
          }
        },
      );

      return widget.child;
    }

    // Web: PWA service-worker update banner.
    final updateAsync = ref.watch(pwaUpdateAvailableProvider);

    return Column(
      children: [
        updateAsync.when(
          data: (hasUpdate) {
            if (!hasUpdate) return const SizedBox.shrink();
            final l10n = AppLocalizations.of(context);
            return MaterialBanner(
              content: Text(l10n.pwa_updateAvailable),
              actions: [
                TextButton(
                  onPressed: pwa.PwaUpdateService.instance.reloadForUpdate,
                  child: Text(l10n.pwa_updateNow),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
