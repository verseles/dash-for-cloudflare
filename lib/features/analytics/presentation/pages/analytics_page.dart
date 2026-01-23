import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key, required this.navigationShell});

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
            icon: Icon(Symbols.public, fill: 0),
            selectedIcon: Icon(Symbols.public, fill: 1),
            label: 'Web',
          ),
          NavigationDestination(
            icon: Icon(Symbols.security, fill: 0),
            selectedIcon: Icon(Symbols.security, fill: 1),
            label: 'Security',
          ),
          NavigationDestination(
            icon: Icon(Symbols.cached, fill: 0),
            selectedIcon: Icon(Symbols.cached, fill: 1),
            label: 'Cache',
          ),
        ],
      ),
    );
  }
}
