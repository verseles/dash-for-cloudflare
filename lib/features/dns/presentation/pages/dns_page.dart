import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// DNS page container with bottom navigation
class DnsPage extends StatelessWidget {
  const DnsPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Symbols.graph_3, fill: 0),
            selectedIcon: Icon(Symbols.graph_3, fill: 1),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Symbols.finance_mode, fill: 0),
            selectedIcon: Icon(Symbols.finance_mode, fill: 1),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Symbols.settings, fill: 0),
            selectedIcon: Icon(Symbols.settings, fill: 1),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
