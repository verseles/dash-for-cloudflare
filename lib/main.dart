import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/desktop/window_manager.dart';
import 'core/logging/log_service.dart';
import 'core/logging/log_level.dart';
import 'features/auth/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize log service
  await LogService.instance.initialize();

  // Set up global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log.error(
      'Flutter error: ${details.exceptionAsString()}',
      details: details.stack?.toString(),
    );
  };

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    log.error('Uncaught async error', error: error, stackTrace: stack);
    return true;
  };

  // Initialize desktop window manager
  await DesktopWindowManager.initialize();

  // Initialize system tray (optional, can be enabled later)
  // await DesktopTrayManager.instance.initialize();

  log.info('App started', category: LogCategory.state);

  runApp(const ProviderScope(child: DashForCloudflareApp()));
}

class DashForCloudflareApp extends ConsumerWidget {
  const DashForCloudflareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(currentThemeModeProvider);
    final locale = ref.watch(currentLocaleProvider);

    return MaterialApp.router(
      title: 'Dash for Cloudflare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: Locale(locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
