import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Web',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon: Icon(Icons.security),
            label: 'Security',
          ),
          NavigationDestination(
            icon: Icon(Icons.cached_outlined),
            selectedIcon: Icon(Icons.cached),
            label: 'Cache',
          ),
        ],
      ),
    );
  }
}
