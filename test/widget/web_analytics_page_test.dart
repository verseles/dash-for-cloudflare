import 'dart:async';
import 'package:cf/features/analytics/presentation/pages/web_analytics_page.dart';
import 'package:cf/features/analytics/providers/web_analytics_provider.dart';
import 'package:cf/features/dns/domain/models/zone.dart';
import 'package:cf/features/dns/providers/zone_provider.dart';
import 'package:cf/l10n/app_localizations.dart';
import 'package:cf/features/analytics/domain/models/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock Notifier
class TestWebAnalyticsNotifier extends WebAnalyticsNotifier {
  TestWebAnalyticsNotifier(this.initialValue);

  final AsyncValue<WebAnalyticsData?> initialValue;

  @override
  FutureOr<WebAnalyticsData?> build() async {
    return initialValue.value;
  }
}

// Mock Zone Notifier
class TestSelectedZoneNotifier extends SelectedZoneNotifier {
  TestSelectedZoneNotifier(this.initialZone);

  final Zone? initialZone;

  @override
  Zone? build() => initialZone;
}

void main() {
  group('WebAnalyticsPage Widget Tests', () {
    const mockZone = Zone(
      id: 'zone1',
      name: 'example.com',
      status: 'active',
    );

    const mockData = WebAnalyticsData(
      totalRequests: 5000,
      totalBytes: 1024 * 1024 * 10, // 10 MB
      totalVisits: 1200,
      timeSeries: [],
      byStatus: [],
      byCountry: [],
      byContentType: [],
      byBrowser: [],
      byPath: [],
    );

    testWidgets('renders overview stats correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedZoneIdProvider.overrideWith((ref) => 'zone1'),
            selectedZoneNotifierProvider.overrideWith(() => TestSelectedZoneNotifier(mockZone)),
            webAnalyticsNotifierProvider.overrideWith(() => TestWebAnalyticsNotifier(const AsyncData(mockData))),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WebAnalyticsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for stats (formatted)
      expect(find.text('5.0K'), findsOneWidget); // Requests
      expect(find.text('10.0 MB'), findsOneWidget); // Bandwidth
      expect(find.text('1.2K'), findsOneWidget); // Visitors
    });

    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedZoneIdProvider.overrideWith((ref) => 'zone1'),
            selectedZoneNotifierProvider.overrideWith(() => TestSelectedZoneNotifier(mockZone)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WebAnalyticsPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Clear pending timers from ADR-024 tab preloading
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
