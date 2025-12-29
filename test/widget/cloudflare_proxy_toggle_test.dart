import 'package:cf/features/dns/presentation/widgets/cloudflare_proxy_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudflareProxyToggle', () {
    Widget buildTestWidget({
      required bool value,
      required bool isLoading,
      required ValueChanged<bool> onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CloudflareProxyToggle(
            value: value,
            isLoading: isLoading,
            onChanged: onChanged,
          ),
        ),
      );
    }

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(value: true, isLoading: true, onChanged: (_) {}),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Proxied'), findsNothing);
      expect(find.text('DNS only'), findsNothing);
    });

    testWidgets('shows "Proxied" text when value is true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(value: true, isLoading: false, onChanged: (_) {}),
      );

      expect(find.text('Proxied'), findsOneWidget);
      expect(find.text('DNS only'), findsNothing);
      expect(find.byIcon(Icons.cloud), findsOneWidget);
    });

    testWidgets('shows "DNS only" text when value is false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(value: false, isLoading: false, onChanged: (_) {}),
      );

      expect(find.text('DNS only'), findsOneWidget);
      expect(find.text('Proxied'), findsNothing);
      expect(find.byIcon(Icons.cloud), findsOneWidget);
    });

    testWidgets('calls onChanged with toggled value when tapped', (
      tester,
    ) async {
      bool? receivedValue;
      await tester.pumpWidget(
        buildTestWidget(
          value: false,
          isLoading: false,
          onChanged: (value) => receivedValue = value,
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(receivedValue, isTrue);
    });

    testWidgets('calls onChanged with false when currently true', (
      tester,
    ) async {
      bool? receivedValue;
      await tester.pumpWidget(
        buildTestWidget(
          value: true,
          isLoading: false,
          onChanged: (value) => receivedValue = value,
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(receivedValue, isFalse);
    });

    testWidgets('has Tooltip with correct message when proxied', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(value: true, isLoading: false, onChanged: (_) {}),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, equals('Proxied through Cloudflare'));
    });

    testWidgets('has Tooltip with correct message when DNS only', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(value: false, isLoading: false, onChanged: (_) {}),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, equals('DNS only'));
    });

    testWidgets('uses Cloudflare orange color when proxied', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(value: true, isLoading: false, onChanged: (_) {}),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.cloud));
      expect(icon.color, equals(const Color(0xFFF38020)));
    });

    testWidgets('uses grey color when DNS only', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(value: false, isLoading: false, onChanged: (_) {}),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.cloud));
      expect(icon.color, equals(Colors.grey));
    });
  });
}
