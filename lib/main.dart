import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: DashForCloudflareApp()));
}

class DashForCloudflareApp extends StatelessWidget {
  const DashForCloudflareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dash for Cloudflare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF38020)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF38020),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pt', 'BR')],
      home: const Scaffold(
        body: Center(child: Text('Dash for Cloudflare - Setup Complete')),
      ),
    );
  }
}
