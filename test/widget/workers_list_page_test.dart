import 'dart:async';
import 'package:cf/features/workers/domain/models/worker.dart';
import 'package:cf/features/workers/presentation/pages/workers_list_page.dart';
import 'package:cf/features/workers/providers/workers_provider.dart';
import 'package:cf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import '../fixtures/fixture_reader.dart';

// Mock Notifier
class TestWorkersNotifier extends WorkersNotifier {
  TestWorkersNotifier(this.initialValue);
  final AsyncValue<WorkersState> initialValue;
  @override
  FutureOr<WorkersState> build() async => initialValue.value!;
}

void main() {
  group('Workers Feature Tests', () {
    testWidgets('renders workers list correctly', (tester) async {
      final scriptsJson = jsonDecode(fixture('workers/scripts.json'));
      final workers = (scriptsJson['result'] as List).map((e) => Worker.fromJson(e)).toList();
      final state = WorkersState(workers: workers);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workersNotifierProvider.overrideWith(() => TestWorkersNotifier(AsyncData(state))),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WorkersListPage(),
          ),
        ),
      );

      await tester.pump();
      expect(find.textContaining(workers[0].id), findsWidgets);
    });
  });
}