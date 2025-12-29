import 'package:cf/features/dns/domain/models/dns_record.dart';
import 'package:cf/features/dns/presentation/widgets/dns_record_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DnsRecordItem', () {
    DnsRecord createTestRecord({
      String id = 'record-123',
      String type = 'A',
      String name = 'www.example.com',
      String content = '192.168.1.1',
      bool proxied = false,
      int ttl = 300,
      String zoneName = 'example.com',
    }) {
      return DnsRecord(
        id: id,
        type: type,
        name: name,
        content: content,
        proxied: proxied,
        ttl: ttl,
        zoneId: 'zone-123',
        zoneName: zoneName,
      );
    }

    Widget buildTestWidget({
      required DnsRecord record,
      bool isSaving = false,
      bool isNew = false,
      bool isDeleting = false,
      VoidCallback? onTap,
      VoidCallback? onDelete,
      ValueChanged<bool>? onProxyToggle,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DnsRecordItem(
            record: record,
            isSaving: isSaving,
            isNew: isNew,
            isDeleting: isDeleting,
            onTap: onTap ?? () {},
            onDelete: onDelete ?? () {},
            onProxyToggle: onProxyToggle ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('displays record type', (tester) async {
      final record = createTestRecord(type: 'A');
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('displays record content', (tester) async {
      final record = createTestRecord(content: '192.168.1.100');
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('192.168.1.100'), findsOneWidget);
    });

    testWidgets('displays @ for root record', (tester) async {
      final record = createTestRecord(
        name: 'example.com',
        zoneName: 'example.com',
      );
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('@'), findsOneWidget);
    });

    testWidgets('displays subdomain prefix correctly', (tester) async {
      final record = createTestRecord(
        name: 'www.example.com',
        zoneName: 'example.com',
      );
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('www'), findsOneWidget);
      expect(find.text('.example.com'), findsOneWidget);
    });

    testWidgets('displays Auto TTL for ttl=1', (tester) async {
      final record = createTestRecord(ttl: 1);
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('Auto'), findsOneWidget);
    });

    testWidgets('displays TTL in minutes', (tester) async {
      final record = createTestRecord(ttl: 300);
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('5m'), findsOneWidget);
    });

    testWidgets('displays TTL in hours', (tester) async {
      final record = createTestRecord(ttl: 7200);
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('2h'), findsOneWidget);
    });

    testWidgets('displays TTL in days', (tester) async {
      final record = createTestRecord(ttl: 86400);
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('1d'), findsOneWidget);
    });

    testWidgets('displays TTL in seconds for small values', (tester) async {
      final record = createTestRecord(ttl: 30);
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('30s'), findsOneWidget);
    });

    testWidgets('shows proxy toggle for A record', (tester) async {
      final record = createTestRecord(type: 'A');
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('DNS only'), findsOneWidget);
    });

    testWidgets('shows proxy toggle for AAAA record', (tester) async {
      final record = createTestRecord(type: 'AAAA');
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('DNS only'), findsOneWidget);
    });

    testWidgets('shows proxy toggle for CNAME record', (tester) async {
      final record = createTestRecord(type: 'CNAME');
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('DNS only'), findsOneWidget);
    });

    testWidgets('does not show proxy toggle for TXT record', (tester) async {
      final record = createTestRecord(type: 'TXT', content: 'v=spf1 ...');
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('DNS only'), findsNothing);
      expect(find.text('Proxied'), findsNothing);
    });

    testWidgets('does not show proxy toggle for MX record', (tester) async {
      final record = createTestRecord(type: 'MX', content: 'mail.example.com');
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.text('DNS only'), findsNothing);
      expect(find.text('Proxied'), findsNothing);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      bool tapped = false;
      final record = createTestRecord();
      await tester.pumpWidget(
        buildTestWidget(record: record, onTap: () => tapped = true),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onProxyToggle when proxy toggle is tapped', (
      tester,
    ) async {
      bool? receivedValue;
      final record = createTestRecord(type: 'A', proxied: false);
      await tester.pumpWidget(
        buildTestWidget(
          record: record,
          onProxyToggle: (value) => receivedValue = value,
        ),
      );

      await tester.tap(find.text('DNS only'));
      await tester.pump();

      expect(receivedValue, isTrue);
    });

    testWidgets('is wrapped in Dismissible for swipe-to-delete', (
      tester,
    ) async {
      final record = createTestRecord();
      await tester.pumpWidget(buildTestWidget(record: record));

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('Dismissible uses record id as key', (tester) async {
      final record = createTestRecord(id: 'unique-record-id');
      await tester.pumpWidget(buildTestWidget(record: record));

      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.key, equals(const Key('unique-record-id')));
    });

    testWidgets('shows delete confirmation dialog on swipe', (tester) async {
      final record = createTestRecord(name: 'test.example.com');
      await tester.pumpWidget(buildTestWidget(record: record));

      // Swipe left
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Delete Record?'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete "test.example.com"?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('dismiss is cancelled when Cancel is pressed', (tester) async {
      bool deleted = false;
      final record = createTestRecord();
      await tester.pumpWidget(
        buildTestWidget(record: record, onDelete: () => deleted = true),
      );

      // Swipe left
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Press Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(deleted, isFalse);
    });
  });
}
