import 'dart:async';
import 'package:cf/core/api/client/cloudflare_api.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/auth/providers/account_provider.dart';
import 'package:cf/features/workers/domain/models/worker.dart';
import 'package:cf/features/workers/domain/models/worker_schedule.dart';
import 'package:cf/features/workers/domain/models/worker_domain.dart';
import 'package:cf/features/workers/presentation/widgets/worker_triggers_tab.dart';
import 'package:cf/features/workers/providers/workers_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cf/l10n/app_localizations.dart';

class MockCloudflareApi extends Mock implements CloudflareApi {}

class MockWorkerSchedulesNotifier extends WorkerSchedulesNotifier {
  MockWorkerSchedulesNotifier(this.schedules);
  final List<WorkerSchedule> schedules;
  @override
  FutureOr<List<WorkerSchedule>> build(String scriptName) => schedules;
}

class MockWorkerDomainsNotifier extends WorkerDomainsNotifier {
  MockWorkerDomainsNotifier(this.domains);
  final List<WorkerDomain> domains;
  @override
  FutureOr<List<WorkerDomain>> build() => domains;
}

void main() {
  late MockCloudflareApi mockApi;

  setUp(() {
    mockApi = MockCloudflareApi();
  });

  final mockWorker = Worker(
    id: 'test-worker',
    createdOn: DateTime.now(),
    modifiedOn: DateTime.now(),
  );

  final mockSchedules = [
    const WorkerSchedule(cron: '*/5 * * * *'),
  ];

  testWidgets('WorkerTriggersTab renders Cron Triggers and Add button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cloudflareApiProvider.overrideWithValue(mockApi),
          selectedAccountIdProvider.overrideWith((ref) => 'account1'),
          workerSchedulesNotifierProvider(mockWorker.id).overrideWith(() => MockWorkerSchedulesNotifier(mockSchedules)),
          workerDomainsNotifierProvider.overrideWith(() => MockWorkerDomainsNotifier([])),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: WorkerTriggersTab(worker: mockWorker)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Check for Cron Triggers section
    expect(find.text('Cron Triggers'), findsOneWidget);
    
    // 2. Check for the existing schedule
    expect(find.text('*/5 * * * *'), findsOneWidget);
    expect(find.text('Every 5 minutes'), findsOneWidget);

    // 3. Check for the Add button in the Cron header
    // Find the header by text and then find the Add icon nearby
    final cronHeader = find.text('Cron Triggers');
    final addButton = find.descendant(
      of: find.ancestor(of: cronHeader, matching: find.byType(Row)),
      matching: find.byIcon(Symbols.add),
    );
    expect(addButton, findsOneWidget);
  });

  testWidgets('WorkerTriggersTab shows delete confirmation for Cron Trigger', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cloudflareApiProvider.overrideWithValue(mockApi),
          selectedAccountIdProvider.overrideWith((ref) => 'account1'),
          workerSchedulesNotifierProvider(mockWorker.id).overrideWith(() => MockWorkerSchedulesNotifier(mockSchedules)),
          workerDomainsNotifierProvider.overrideWith(() => MockWorkerDomainsNotifier([])),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: WorkerTriggersTab(worker: mockWorker)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap the delete icon on the schedule card
    final deleteIcon = find.byIcon(Symbols.delete);
    expect(deleteIcon, findsAtLeastNWidgets(1));
    await tester.tap(deleteIcon.last); // Last one is likely the cron one
    await tester.pumpAndSettle();

    // Check for confirmation dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('remove this cron trigger'), findsOneWidget);
  });
}
