import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';

/// DNS page container with bottom navigation
class DnsPage extends StatelessWidget {
  const DnsPage({super.key, required this.navigationShell});

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
            icon: const Icon(Symbols.graph_3, fill: 0),
            selectedIcon: const Icon(Symbols.graph_3, fill: 1),
            label: l10n.tabs_records,
          ),
          NavigationDestination(
            icon: const Icon(Symbols.finance_mode, fill: 0),
            selectedIcon: const Icon(Symbols.finance_mode, fill: 1),
            label: l10n.tabs_analytics,
          ),
          NavigationDestination(
            icon: const Icon(Symbols.settings, fill: 0),
            selectedIcon: const Icon(Symbols.settings, fill: 1),
            label: l10n.tabs_settings,
          ),
        ],
      ),
    );
  }
}
