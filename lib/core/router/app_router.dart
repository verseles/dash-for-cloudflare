import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/providers/settings_provider.dart';
import '../../features/auth/presentation/pages/settings_page.dart';
import '../../features/dns/presentation/pages/dns_page.dart';
import '../../features/dns/presentation/pages/dns_records_page.dart';
import '../../features/dns/presentation/pages/dns_analytics_page.dart';
import '../../features/dns/presentation/pages/dns_settings_page.dart';
import '../widgets/main_layout.dart';

part 'app_router.g.dart';

/// Route paths
class AppRoutes {
  static const String settings = '/settings';
  static const String dns = '/dns';
  static const String dnsRecords = '/dns/records';
  static const String dnsAnalytics = '/dns/analytics';
  static const String dnsSettings = '/dns/settings';
}

/// Navigation shell key for preserving state
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router provider
@riverpod
GoRouter appRouter(Ref ref) {
  final hasValidToken = ref.watch(hasValidTokenProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dnsRecords,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isSettingsRoute = state.matchedLocation == AppRoutes.settings;

      // If no valid token and not on settings, redirect to settings
      if (!hasValidToken && !isSettingsRoute) {
        return AppRoutes.settings;
      }

      // If on root, redirect to DNS records
      if (state.matchedLocation == '/') {
        return AppRoutes.dnsRecords;
      }

      return null;
    },
    routes: [
      // Settings page (outside shell)
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // Main shell with layout
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // DNS shell with bottom navigation
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return DnsPage(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.dnsRecords,
                    builder: (context, state) => const DnsRecordsPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.dnsAnalytics,
                    builder: (context, state) => const DnsAnalyticsPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.dnsSettings,
                    builder: (context, state) => const DnsSettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
