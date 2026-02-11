import 'package:cf/core/logging/log_entry.dart';
import 'package:cf/core/logging/log_level.dart';
import 'package:cf/core/logging/log_provider.dart';
import 'package:cf/core/logging/presentation/debug_logs_page.dart';
import 'package:cf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLogViewer extends LogViewer {
  final LogViewerState _state;
  MockLogViewer(this._state);

  @override
  LogViewerState build() => _state;
}

void main() {
  testWidgets('DebugLogsPage details expand on tap', (tester) async {
    // 1. Setup initial state with a long log entry
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

    // 2. Pump widget with overridden provider
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

    // 3. Verify initial state (maxLines: 5)
    final detailsFinder = find.text('→ $longDetails');
    expect(detailsFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(detailsFinder);
    expect(textWidget.maxLines, 5, reason: 'Details should be initially collapsed to 5 lines');

    // 4. Tap to expand
    // We need to tap the tile. The tile is a Container with GestureDetector.
    // The details text is inside the tile.
    await tester.tap(detailsFinder);
    await tester.pumpAndSettle();

    // 5. Verify expanded state (maxLines: null)
    final textWidgetExpanded = tester.widget<Text>(detailsFinder);
    expect(textWidgetExpanded.maxLines, null, reason: 'Details should be expanded after tap');
  });
}
