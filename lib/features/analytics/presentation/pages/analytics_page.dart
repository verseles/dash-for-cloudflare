import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Symbols.public, fill: 0),
            selectedIcon: const Icon(Symbols.public, fill: 1),
            label: l10n.tabs_web,
          ),
          NavigationDestination(
            icon: const Icon(Symbols.security, fill: 0),
            selectedIcon: const Icon(Symbols.security, fill: 1),
            label: l10n.tabs_security,
          ),
          NavigationDestination(
            icon: const Icon(Symbols.cached, fill: 0),
            selectedIcon: const Icon(Symbols.cached, fill: 1),
            label: l10n.tabs_cache,
          ),
        ],
      ),
    );
  }
}
