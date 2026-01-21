import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dns/providers/zone_provider.dart';
import '../../features/dns/providers/tab_preloader_provider.dart';
import '../../features/dns/domain/models/zone.dart';
import '../router/app_router.dart';

/// Main layout with AppBar and optional Drawer
class MainLayout extends ConsumerWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Activate tab preloader - listens to zone changes and preloads data
    ref.watch(tabPreloaderProvider);

    final location = GoRouterState.of(context).matchedLocation;
    final title = _getTitleForLocation(location, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Zone selector
          _ZoneSelector(),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, ref, l10n),
      body: child,
    );
  }

  String _getTitleForLocation(String location, AppLocalizations l10n) {
    if (location.startsWith('/dns')) return l10n.menu_dns;
    if (location.startsWith('/analytics')) return l10n.menu_analytics;
    if (location.startsWith('/settings')) return l10n.menu_settings;
    if (location.startsWith('/debug-logs')) return l10n.menu_debugLogs;
    return 'Cloudflare';
  }

  Widget _buildDrawer(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
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
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dns),
            title: Text(l10n.menu_dns),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.dnsRecords);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: Text(l10n.menu_analytics),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.analyticsWeb);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.menu_settings),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.settings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: Text(l10n.menu_debugLogs),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.debugLogs);
            },
          ),
        ],
      ),
    );
  }
}

/// Zone selector dropdown
class _ZoneSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final zonesAsync = ref.watch(zonesNotifierProvider);
    final selectedZone = ref.watch(selectedZoneNotifierProvider);

    return zonesAsync.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, _) => IconButton(
        icon: const Icon(Icons.error_outline),
        onPressed: () => ref.read(zonesNotifierProvider.notifier).refresh(),
        tooltip: l10n.error_network,
      ),
      data: (state) {
        final zones = state.zones;
        if (zones.isEmpty) {
          return Text(l10n.menu_noZones);
        }

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showZoneDialog(context, ref, zones, selectedZone, l10n),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    selectedZone?.name ?? l10n.zone_selectZone,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showZoneDialog(
    BuildContext context,
    WidgetRef ref,
    List<Zone> zones,
    Zone? selectedZone,
    AppLocalizations l10n,
  ) {
    final searchController = TextEditingController();
    var filteredZones = zones;

    showDialog<Zone>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.menu_selectZone),
              contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: l10n.zone_searchZones,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredZones = zones
                                .where(
                                  (z) => z.name.toLowerCase().contains(
                                    value.toLowerCase(),
                                  ),
                                )
                                .toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Zone list
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredZones.length,
                        itemBuilder: (context, index) {
                          final zone = filteredZones[index];
                          final isSelected = zone.id == selectedZone?.id;
                          return ListTile(
                            leading: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            title: Text(
                              zone.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: _StatusBadge(status: zone.status),
                            onTap: () {
                              ref
                                  .read(selectedZoneNotifierProvider.notifier)
                                  .selectZone(zone);
                              Navigator.of(dialogContext).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.common_cancel),
                ),
              ],
            );
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
