import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dns/providers/zone_provider.dart';
import '../../features/dns/domain/models/zone.dart';
import '../router/app_router.dart';

/// Main layout with AppBar and optional Drawer
class MainLayout extends ConsumerWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash for Cloudflare'),
        actions: [
          // Zone selector
          _ZoneSelector(),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, ref),
      body: child,
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.cloud,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'Dash for Cloudflare',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('DNS'),
            onTap: () {
              Navigator.pop(context);
              // Navigate handled by router
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.settings);
            },
          ),
        ],
      ),
    );
  }
}

/// Zone selector dropdown
class _ZoneSelector extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ZoneSelector> createState() => _ZoneSelectorState();
}

class _ZoneSelectorState extends ConsumerState<_ZoneSelector> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(zonesNotifierProvider);
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final filteredZones = ref.watch(filteredZonesProvider);

    return zonesAsync.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, _) => IconButton(
        icon: const Icon(Icons.error_outline),
        onPressed: () => ref.read(zonesNotifierProvider.notifier).refresh(),
        tooltip: 'Error loading zones. Tap to retry.',
      ),
      data: (zones) {
        if (zones.isEmpty) {
          return const Text('No zones');
        }

        return PopupMenuButton<Zone>(
          tooltip: 'Select zone',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    selectedZone?.name ?? 'Select zone',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          itemBuilder: (context) {
            return [
              // Search field
              PopupMenuItem<Zone>(
                enabled: false,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search zones...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    ref.read(zoneFilterProvider.notifier).setFilter(value);
                  },
                ),
              ),
              // Zone list
              ...filteredZones.map(
                (zone) => PopupMenuItem<Zone>(
                  value: zone,
                  child: Row(
                    children: [
                      Icon(
                        zone.id == selectedZone?.id
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 20,
                        color: zone.id == selectedZone?.id
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(zone.name, overflow: TextOverflow.ellipsis),
                      ),
                      _StatusBadge(status: zone.status),
                    ],
                  ),
                ),
              ),
            ];
          },
          onSelected: (zone) {
            ref.read(selectedZoneNotifierProvider.notifier).selectZone(zone);
            _searchController.clear();
            ref.read(zoneFilterProvider.notifier).clear();
          },
          onCanceled: () {
            _searchController.clear();
            ref.read(zoneFilterProvider.notifier).clear();
          },
        );
      },
    );
  }
}

/// Status badge for zone
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'active' => Colors.green,
      'pending' => Colors.orange,
      'moved' => Colors.blue,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
