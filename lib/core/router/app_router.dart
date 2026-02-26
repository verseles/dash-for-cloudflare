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
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/analytics/presentation/pages/web_analytics_page.dart';
import '../../features/analytics/presentation/pages/security_analytics_page.dart';
import '../../features/analytics/presentation/pages/performance_analytics_page.dart';
import '../../features/pages/presentation/pages/pages_list_page.dart';
import '../../features/pages/presentation/pages/pages_project_page.dart';
import '../../features/pages/presentation/pages/deployment_details_page.dart';
import '../../features/workers/presentation/pages/workers_list_page.dart';
import '../../features/workers/presentation/pages/worker_details_page.dart';
import '../widgets/main_layout.dart';
import '../logging/presentation/debug_logs_page.dart';

part 'app_router.g.dart';

/// Route paths
class AppRoutes {
  static const String settings = '/settings';
  static const String dns = '/dns';
  static const String dnsRecords = '/dns/records';
  static const String dnsAnalytics = '/dns/analytics';
  static const String dnsSettings = '/dns/settings';
  static const String analytics = '/analytics';
  static const String analyticsWeb = '/analytics/web';
  static const String analyticsSecurity = '/analytics/security';
  static const String analyticsPerformance = '/analytics/performance';
  static const String pages = '/pages';
  static const String pagesProject = 'pagesProject';
  static const String pagesDeployment = 'pagesDeployment';
  static const String workers = '/workers';
  static const String workerDetails = 'workerDetails';
  static const String debugLogs = '/debug-logs';
}

/// Navigation shell key for preserving state
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router provider
@riverpod
GoRouter appRouter(Ref ref) {
  final hasValidToken = ref.watch(hasValidTokenProvider);
  final lastVisitedRoute = ref.read(currentLastVisitedRouteProvider);
  final initialLocation = lastVisitedRoute ?? AppRoutes.dnsRecords;

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isSettingsRoute = state.matchedLocation == AppRoutes.settings;
      final isDebugLogsRoute = state.matchedLocation == AppRoutes.debugLogs;

      // If no valid token and not on settings or debug logs, redirect to settings
      if (!hasValidToken && !isSettingsRoute && !isDebugLogsRoute) {
        return AppRoutes.settings;
      }

      // If on root, redirect to initial location (last visited or DNS records)
      if (state.matchedLocation == '/') {
        return initialLocation;
      }

      return null;
    },
    routes: [
      // Settings page (outside shell)
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // Debug logs page (outside shell)
      GoRoute(
        path: AppRoutes.debugLogs,
        builder: (context, state) => const DebugLogsPage(),
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

          // Analytics shell with bottom navigation
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return AnalyticsPage(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.analyticsWeb,
                    builder: (context, state) => const WebAnalyticsPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.analyticsSecurity,
                    builder: (context, state) => const SecurityAnalyticsPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.analyticsPerformance,
                    builder: (context, state) =>
                        const PerformanceAnalyticsPage(),
                  ),
                ],
              ),
            ],
          ),

          // Pages routes
          GoRoute(
            path: AppRoutes.pages,
            builder: (context, state) => const PagesListPage(),
            routes: [
              GoRoute(
                path: ':projectName',
                name: AppRoutes.pagesProject,
                pageBuilder: (context, state) {
                  final projectName = state.pathParameters['projectName']!;
                  return _fadeSlideTransition(
                    state,
                    PagesProjectPage(projectName: projectName),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'deployment/:deploymentId',
                    name: AppRoutes.pagesDeployment,
                    pageBuilder: (context, state) {
                      final projectName = state.pathParameters['projectName']!;
                      final deploymentId =
                          state.pathParameters['deploymentId']!;
                      return _fadeSlideTransition(
                        state,
                        DeploymentDetailsPage(
                          projectName: projectName,
                          deploymentId: deploymentId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Workers routes
          GoRoute(
            path: AppRoutes.workers,
            builder: (context, state) => const WorkersListPage(),
            routes: [
              GoRoute(
                path: ':workerName',
                name: AppRoutes.workerDetails,
                pageBuilder: (context, state) {
                  final workerName = state.pathParameters['workerName']!;
                  return _fadeSlideTransition(
                    state,
                    WorkerDetailsPage(workerName: workerName),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Persist last visited route
  router.routerDelegate.addListener(() {
    final location =
        router.routerDelegate.currentConfiguration.last.matchedLocation;
    if (hasValidToken &&
        location != AppRoutes.settings &&
        location != AppRoutes.debugLogs &&
        location != '/') {
      ref.read(settingsNotifierProvider.notifier).setLastVisitedRoute(location);
    }
  });

  return router;
}

/// Fade + slide-from-right transition for detail pages
CustomTransitionPage<void> _fadeSlideTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
