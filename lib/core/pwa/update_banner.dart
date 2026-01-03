import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'pwa_update_provider.dart';
import 'pwa_update_service.dart' as pwa;

class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb) return child;

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
        Expanded(child: child),
      ],
    );
  }
}
