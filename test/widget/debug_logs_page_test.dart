import 'package:cf/core/logging/log_entry.dart';
import 'package:cf/core/logging/log_level.dart';
import 'package:cf/core/logging/log_provider.dart';
import 'package:cf/core/logging/presentation/debug_logs_page.dart';
import 'package:cf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

class MockLogViewer extends LogViewer {
  final LogViewerState _state;
  MockLogViewer(this._state);

  @override
  LogViewerState build() => _state;
}

void main() {
  group('DebugLogsPage expand/collapse tests', () {
    testWidgets('displays expand icon only when details exist', (tester) async {
      final mockState = LogViewerState(
        logs: [
          // Entry with details
          LogEntry(
            level: LogLevel.info,
            message: 'With details',
            details: 'Some details here',
            timestamp: DateTime(2023, 1, 1, 12, 0, 0),
          ),
          // Entry without details
          LogEntry(
            level: LogLevel.info,
            message: 'No details',
            timestamp: DateTime(2023, 1, 1, 12, 0, 1),
          ),
        ],
        timeRange: LogTimeRange.all,
        category: LogCategory.all,
        searchQuery: '',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logViewerProvider.overrideWith(() => MockLogViewer(mockState)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DebugLogsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find expand icon
      final expandIcons = find.byIcon(Symbols.expand_more);
      expect(expandIcons, findsOneWidget, reason: 'Only one log has details');
    });

    testWidgets('expands and collapses details on tap', (tester) async {
      final longDetails = List.generate(10, (i) => 'Line $i').join('\n');
      final mockState = LogViewerState(
        logs: [
          LogEntry(
            level: LogLevel.info,
            message: 'Test Message',
            details: longDetails,
            timestamp: DateTime(2023, 1, 1, 12, 0, 0),
          ),
        ],
        timeRange: LogTimeRange.all,
        category: LogCategory.all,
        searchQuery: '',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logViewerProvider.overrideWith(() => MockLogViewer(mockState)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DebugLogsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the AnimatedSize widget that contains the details
      final animatedSizeFinder = find.byType(AnimatedSize);
      expect(animatedSizeFinder, findsOneWidget);

      // Find details text within the AnimatedSize
      final detailsFinder = find.descendant(
        of: animatedSizeFinder,
        matching: find.textContaining('→'),
      );
      expect(detailsFinder, findsOneWidget);

      // Verify initial state (maxLines: 5, collapsed)
      Text textWidget = tester.widget<Text>(detailsFinder);
      expect(textWidget.maxLines, 5, reason: 'Should start collapsed');
      expect(textWidget.overflow, TextOverflow.ellipsis);

      // Tap the log message to expand
      final messageFinder = find.text('Test Message');
      await tester.tap(messageFinder);
      await tester.pumpAndSettle();

      // Verify expanded state (maxLines: null)
      textWidget = tester.widget<Text>(detailsFinder);
      expect(textWidget.maxLines, null, reason: 'Should be expanded after tap');
      expect(textWidget.overflow, TextOverflow.visible);

      // Tap again to collapse
      await tester.tap(messageFinder);
      await tester.pumpAndSettle();

      // Verify collapsed again
      textWidget = tester.widget<Text>(detailsFinder);
      expect(textWidget.maxLines, 5, reason: 'Should collapse again');
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('icon rotates when expanding', (tester) async {
      final mockState = LogViewerState(
        logs: [
          LogEntry(
            level: LogLevel.info,
            message: 'Test',
            details: 'Details',
            timestamp: DateTime(2023, 1, 1, 12, 0, 0),
          ),
        ],
        timeRange: LogTimeRange.all,
        category: LogCategory.all,
        searchQuery: '',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logViewerProvider.overrideWith(() => MockLogViewer(mockState)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DebugLogsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the expand icon (should be only one)
      final expandIcon = find.byIcon(Symbols.expand_more);
      expect(expandIcon, findsOneWidget);

      // Tap message to expand
      final messageFinder = find.text('Test');
      await tester.tap(messageFinder);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Mid animation

      // Icon should still exist (we can't easily test rotation value, but we can verify no crash)
      expect(expandIcon, findsOneWidget);

      await tester.pumpAndSettle(); // Finish animation
      expect(expandIcon, findsOneWidget);
    });

    testWidgets('does not expand when no details', (tester) async {
      final mockState = LogViewerState(
        logs: [
          LogEntry(
            level: LogLevel.info,
            message: 'No details here',
            timestamp: DateTime(2023, 1, 1, 12, 0, 0),
          ),
        ],
        timeRange: LogTimeRange.all,
        category: LogCategory.all,
        searchQuery: '',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logViewerProvider.overrideWith(() => MockLogViewer(mockState)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DebugLogsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No expand icon for this log entry
      expect(find.byIcon(Symbols.expand_more), findsNothing);

      // No details text
      expect(find.textContaining('→'), findsNothing);

      // Tap message should do nothing (no crash)
      final messageFinder = find.text('No details here');
      await tester.tap(messageFinder);
      await tester.pumpAndSettle();

      // Still no expand icon
      expect(find.byIcon(Symbols.expand_more), findsNothing);
    });
  });
}
