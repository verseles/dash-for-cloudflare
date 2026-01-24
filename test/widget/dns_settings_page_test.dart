import 'dart:async';

import 'package:cf/features/dns/domain/models/dns_settings.dart';
import 'package:cf/features/dns/domain/models/zone.dart';
import 'package:cf/features/dns/presentation/pages/dns_settings_page.dart';
import 'package:cf/features/dns/providers/dns_settings_provider.dart';
import 'package:cf/features/dns/providers/zone_provider.dart';
import 'package:cf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Test implementation of the DNS settings notifier
class TestDnsSettingsNotifier extends DnsSettingsNotifier {
  TestDnsSettingsNotifier(this.initialValue);
  final AsyncValue<DnsZoneSettingsState> initialValue;

  @override
  FutureOr<DnsZoneSettingsState> build() async {
    return initialValue.value!;
  }
}

// Another test implementation for loading state
class LoadingDnsSettingsNotifier extends DnsSettingsNotifier {
  @override
  FutureOr<DnsZoneSettingsState> build() async {
    // Return a never completing future to stay in loading state
    return Completer<DnsZoneSettingsState>().future;
  }
}

// Test implementation of the zone notifier
class TestSelectedZoneNotifier extends SelectedZoneNotifier {
  TestSelectedZoneNotifier(this.initialZone);
  final Zone? initialZone;

  @override
  Zone? build() => initialZone;
}

void main() {
  group('DnsSettingsPage Widget Tests', () {
    const mockZone = Zone(
      id: 'zone1',
      name: 'example.com',
      status: 'active',
    );

    testWidgets('renders settings cards correctly', (tester) async {
      const state = DnsZoneSettingsState(
        dnssec: DnssecDetails(status: 'active'),
        dnsSettings: DnsZoneSettings(multiProvider: true),
        zoneSettings: [
          DnsSetting(id: 'cname_flattening', value: 'flatten_at_root'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedZoneIdProvider.overrideWith((ref) => 'zone1'),
            selectedZoneNotifierProvider.overrideWith(() => TestSelectedZoneNotifier(mockZone)),
            dnsSettingsNotifierProvider.overrideWith(() => TestDnsSettingsNotifier(const AsyncData(state))),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: DnsSettingsPage()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('DNSSEC'), findsOneWidget);
      // The English translation for active DNSSEC is "DNSSEC is active"
      expect(find.text('DNSSEC is active'), findsOneWidget);
      expect(find.text('Multi-provider DNS'), findsOneWidget);
      expect(find.text('CNAME Flattening'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedZoneIdProvider.overrideWith((ref) => 'zone1'),
            selectedZoneNotifierProvider.overrideWith(() => TestSelectedZoneNotifier(mockZone)),
            dnsSettingsNotifierProvider.overrideWith(() => LoadingDnsSettingsNotifier()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: DnsSettingsPage()),
          ),
        ),
      );

      // Verify that the CircularProgressIndicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
