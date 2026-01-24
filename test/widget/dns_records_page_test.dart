import 'package:cf/features/dns/domain/models/dns_record.dart';
import 'package:cf/features/dns/domain/models/zone.dart';
import 'package:cf/features/dns/presentation/pages/dns_records_page.dart';
import 'package:cf/features/dns/presentation/widgets/dns_record_item.dart';
import 'package:cf/features/dns/providers/dns_records_provider.dart';
import 'package:cf/features/dns/providers/zone_provider.dart';
import 'package:cf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

// Test implementation of the DNS records notifier
class TestDnsRecordsNotifier extends DnsRecordsNotifier {
  TestDnsRecordsNotifier(this.initialState);
  final DnsRecordsState initialState;

  @override
  Future<DnsRecordsState> build() async => initialState;

  @override
  void setFilter(String filter) {
    state = AsyncData(state.value!.copyWith(activeFilter: filter));
  }

  @override
  void setSearchQuery(String query) {
    state = AsyncData(state.value!.copyWith(searchQuery: query));
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
  group('DnsRecordsPage Widget Tests', () {
    const mockZone = Zone(
      id: 'zone1',
      name: 'example.com',
      status: 'active',
    );

    final mockRecords = [
      const DnsRecord(
        id: '1',
        name: 'api.example.com',
        type: 'A',
        content: '1.1.1.1',
        proxied: true,
        proxiable: true,
        ttl: 1,
        zoneId: 'zone1',
        zoneName: 'example.com',
      ),
      const DnsRecord(
        id: '2',
        name: 'www.example.com',
        type: 'CNAME',
        content: 'example.com',
        proxied: false,
        proxiable: true,
        ttl: 1,
        zoneId: 'zone1',
        zoneName: 'example.com',
      ),
    ];

    testWidgets('renders list of records correctly', (tester) async {
      final state = DnsRecordsState(records: mockRecords);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedZoneIdProvider.overrideWith((ref) => 'zone1'),
            selectedZoneNotifierProvider.overrideWith(() => TestSelectedZoneNotifier(mockZone)),
            dnsRecordsNotifierProvider.overrideWith(() => TestDnsRecordsNotifier(state)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: DnsRecordsPage()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DnsRecordItem), findsNWidgets(2));
      expect(find.text('api'), findsOneWidget);
      expect(find.text('.example.com'), findsNWidgets(2));
    });

    testWidgets('filtering by type updates the list visibility', (tester) async {
      final state = DnsRecordsState(records: mockRecords);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedZoneIdProvider.overrideWith((ref) => 'zone1'),
            selectedZoneNotifierProvider.overrideWith(() => TestSelectedZoneNotifier(mockZone)),
            dnsRecordsNotifierProvider.overrideWith(() => TestDnsRecordsNotifier(state)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: DnsRecordsPage()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final filterChip = find.widgetWithText(FilterChip, 'A');
      await tester.tap(filterChip);
      await tester.pumpAndSettle();

      expect(find.text('api'), findsOneWidget);
      expect(find.text('www'), findsNothing);
    });

    testWidgets('searching for a record filters the list', (tester) async {
      final state = DnsRecordsState(records: mockRecords);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedZoneIdProvider.overrideWith((ref) => 'zone1'),
            selectedZoneNotifierProvider.overrideWith(() => TestSelectedZoneNotifier(mockZone)),
            dnsRecordsNotifierProvider.overrideWith(() => TestDnsRecordsNotifier(state)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: DnsRecordsPage()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Symbols.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'api');
      await tester.pumpAndSettle();
      
      expect(find.descendant(
        of: find.byType(DnsRecordItem),
        matching: find.text('api'),
      ), findsOneWidget);
      expect(find.text('www'), findsNothing);
    });
  });
}
