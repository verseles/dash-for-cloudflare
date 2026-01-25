import 'dart:async';
import 'dart:convert';
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
import 'package:material_symbols_icons/symbols.dart';
import 'package:cf/core/api/models/cloudflare_response.dart';
import '../fixtures/fixture_reader.dart';

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

    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getString(any())).thenReturn(null);
  });

  testWidgets('PagesSettingsTab sends simple string map for env_vars', (
    tester,
  ) async {
    final projectsJson = jsonDecode(fixture('pages/projects.json'));
    final project = PagesProject.fromJson(projectsJson['result'][0]);

    final mockProject = project.copyWith(
      deploymentConfigs: project.deploymentConfigs!.copyWith(
        production: project.deploymentConfigs!.production.copyWith(
          envVars: {
            'KEEP': const EnvVar(value: 'original', type: 'plain_text'),
            'DELETE': const EnvVar(value: 'remove-me', type: 'plain_text'),
          },
        ),
      ),
    );

    Map<String, dynamic>? capturedPayload;

    when(() => mockApi.patchPagesProject(any(), any(), any())).thenAnswer((
      invocation,
    ) async {
      capturedPayload = invocation.positionalArguments[2];
      return CloudflareResponse(
        result: mockProject,
        success: true,
        errors: [],
        messages: [],
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cloudflareApiProvider.overrideWithValue(mockApi),
          sharedPreferencesProvider.overrideWith((ref) async => mockPrefs),
          selectedAccountIdProvider.overrideWith((ref) => 'account1'),
          pagesProjectDetailsNotifierProvider(
            mockProject.name,
          ).overrideWith(() => MockProjectDetailsNotifier(mockProject)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PagesSettingsTab(project: mockProject),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the close icon for the 'DELETE' variable
    final deleteButton = find.descendant(
      of: find.ancestor(
        of: find.text('DELETE'),
        matching: find.byType(ListTile),
      ),
      matching: find.byIcon(Symbols.close),
    );

    await tester.tap(deleteButton);
    await tester.pump(const Duration(seconds: 1));

    // Verify payload
    expect(capturedPayload, isNotNull);
    final envVars =
        capturedPayload!['deployment_configs']['production']['env_vars'];

    // IMPORTANT: Check that it's an object with type/value, as required by Cloudflare API
    expect(envVars['KEEP'], isA<Map>());
    expect(envVars['KEEP']['type'], equals('plain_text'));
    expect(envVars['KEEP']['value'], equals('original'));
    // Check that deleted one is null
    expect(envVars.containsKey('DELETE'), isTrue);
    expect(envVars['DELETE'], isNull);
  });
}
