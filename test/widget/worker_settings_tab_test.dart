import 'dart:async';
import 'package:cf/core/api/client/cloudflare_api.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/auth/providers/account_provider.dart';
import 'package:cf/features/auth/providers/settings_provider.dart';
import 'package:cf/features/workers/domain/models/worker.dart';
import 'package:cf/features/workers/domain/models/worker_settings.dart';
import 'package:cf/features/workers/presentation/widgets/worker_settings_tab.dart';
import 'package:cf/features/workers/providers/workers_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cf/l10n/app_localizations.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockCloudflareApi extends Mock implements CloudflareApi {}

class MockWorkerDetailsNotifier extends WorkerDetailsNotifier {
  MockWorkerDetailsNotifier(this.settings);
  final WorkerSettings settings;
  @override
  FutureOr<WorkerSettings> build(String scriptName) => settings;
}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockCloudflareApi mockApi;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockApi = MockCloudflareApi();
    when(() => mockPrefs.getString(any())).thenReturn(null);
  });

  final mockWorker = Worker(
    id: 'test-worker',
    createdOn: DateTime.now(),
    modifiedOn: DateTime.now(),
  );

  final mockSettings = const WorkerSettings(
    bindings: [],
    compatibilityDate: '2024-01-01',
    usageModel: 'bundled',
  );

  testWidgets('WorkerSettingsTab renders all sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cloudflareApiProvider.overrideWithValue(mockApi),
          sharedPreferencesProvider.overrideWith((ref) async => mockPrefs),
          selectedAccountIdProvider.overrideWith((ref) => 'account1'),
          workerDetailsNotifierProvider(mockWorker.id).overrideWith(() => MockWorkerDetailsNotifier(mockSettings)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkerSettingsTab(worker: mockWorker),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Check sections (using symbols since text might be tricky with l10n in tests)
    expect(find.byIcon(Symbols.monitoring), findsOneWidget); // Observability icon
    
    await tester.dragUntilVisible(
      find.byIcon(Symbols.bolt),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.byIcon(Symbols.bolt), findsOneWidget); // Runtime icon

    await tester.dragUntilVisible(
      find.byIcon(Symbols.warning),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.byIcon(Symbols.warning), findsOneWidget); // Danger Zone icon

    // 2. Check for a known text in one of the sections
    expect(find.textContaining('Worker'), findsAtLeastNWidgets(1));
  });

  testWidgets('Delete worker shows confirmation dialog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cloudflareApiProvider.overrideWithValue(mockApi),
          sharedPreferencesProvider.overrideWith((ref) async => mockPrefs),
          selectedAccountIdProvider.overrideWith((ref) => 'account1'),
          workerDetailsNotifierProvider(mockWorker.id).overrideWith(() => MockWorkerDetailsNotifier(mockSettings)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkerSettingsTab(worker: mockWorker),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Scroll to find Danger Zone / Delete button
    final deleteButtonFinder = find.byIcon(Symbols.delete);
    await tester.dragUntilVisible(
      deleteButtonFinder,
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    // Check dialog presence by looking for common dialog buttons
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsAtLeastNWidgets(1));
  });
}
