import 'dart:async';
import 'package:cf/core/api/client/cloudflare_api.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/features/auth/providers/account_provider.dart';
import 'package:cf/features/auth/providers/settings_provider.dart';
import 'package:cf/features/pages/domain/models/pages_project.dart';
import 'package:cf/features/pages/presentation/widgets/pages_settings_tab.dart';
import 'package:cf/features/pages/providers/pages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cf/l10n/app_localizations.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockCloudflareApi extends Mock implements CloudflareApi {}

class MockProjectDetailsNotifier extends PagesProjectDetailsNotifier {
  MockProjectDetailsNotifier(this.project);
  final PagesProject project;
  @override
  FutureOr<PagesProject> build(String projectName) => project;
}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockCloudflareApi mockApi;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockApi = MockCloudflareApi();
    when(() => mockPrefs.getString(any())).thenReturn(null);
  });

  final mockProject = PagesProject(
    id: 'id',
    name: 'test-project',
    subdomain: 'test',
    createdOn: DateTime.now(),
    source: const PagesSource(
      type: 'github',
      config: PagesSourceConfig(
        productionBranch: 'main',
        deploymentsEnabled: true,
        prCommentsEnabled: true,
      ),
    ),
    buildConfig: const BuildConfig(
      buildCommand: 'npm run build',
      destinationDir: 'dist',
      buildSystemVersion: '2',
    ),
  );

  testWidgets('PagesSettingsTab renders all new sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cloudflareApiProvider.overrideWithValue(mockApi),
          sharedPreferencesProvider.overrideWith((ref) async => mockPrefs),
          selectedAccountIdProvider.overrideWith((ref) => 'account1'),
          pagesProjectDetailsNotifierProvider(mockProject.name).overrideWith(() => MockProjectDetailsNotifier(mockProject)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PagesSettingsTab(project: mockProject),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Git Repository Section
    expect(find.text('Git Repository'), findsOneWidget);
    // Finds 'main' in the text field controller. Might find more if hint text is also visible or rendered elsewhere.
    expect(find.text('main'), findsAtLeastNWidgets(1)); 
    expect(find.text('Preview Deployments'), findsOneWidget);
    expect(find.text('Production Deployments'), findsOneWidget);
    expect(find.text('PR Comments'), findsOneWidget);

    // 2. Build Settings Section
    expect(find.text('Build Settings'), findsOneWidget);
    // Finds text in controller (EditableText) and potentially decoration/semantics.
    expect(find.text('npm run build'), findsAtLeastNWidgets(1));
    
    // Scroll to find Dropdown
    await tester.dragUntilVisible(
      find.text('Build System Version'),
      find.byType(ListView),
      const Offset(0, -500),
    );
    expect(find.text('Build System Version'), findsOneWidget);
    // Dropdown value might be rendered as text
    expect(find.text('Version 2'), findsAtLeastNWidgets(1));

    // 3. Danger Zone
    // Scroll deep to find Danger Zone
    await tester.dragUntilVisible(
      find.text('Danger Zone'),
      find.byType(ListView),
      const Offset(0, -500),
    );
    expect(find.text('Danger Zone'), findsOneWidget);
    expect(find.text('Delete Project'), findsOneWidget);
  });

  testWidgets('Delete project shows confirmation dialog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cloudflareApiProvider.overrideWithValue(mockApi),
          sharedPreferencesProvider.overrideWith((ref) async => mockPrefs),
          selectedAccountIdProvider.overrideWith((ref) => 'account1'),
          pagesProjectDetailsNotifierProvider(mockProject.name).overrideWith(() => MockProjectDetailsNotifier(mockProject)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PagesSettingsTab(project: mockProject),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Scroll deep to find the specific Delete Project button text
    await tester.dragUntilVisible(
      find.text('Delete Project'),
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    // Now tap the button label
    await tester.tap(find.text('Delete Project'));
    await tester.pumpAndSettle();

    // Check dialog
    expect(find.text('Delete Project?'), findsOneWidget);
    expect(find.textContaining('Are you sure you want to delete test-project?'), findsOneWidget);
    
    // Check buttons
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget); // ONLY in dialog now
    expect(find.text('Delete Project'), findsAtLeastNWidgets(1)); // Button label
  });
}
