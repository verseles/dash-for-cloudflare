import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cf/features/pages/presentation/widgets/pages_settings_tab.dart';
import 'package:cf/features/pages/domain/models/pages_project.dart';
import 'package:cf/features/pages/providers/pages_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cf/l10n/app_localizations.dart';

class FakePagesSettingsNotifier extends PagesSettingsNotifier {
// ... (apenas ajustando imports agora)

  Function(Map<String, dynamic>? buildConfig)? onUpdate;

  @override
  FutureOr<void> build() {}

  @override
  Future<bool> updateProject({
    required String projectName,
    Map<String, dynamic>? buildConfig,
    Map<String, dynamic>? deploymentConfigs,
  }) async {
    if (onUpdate != null) onUpdate!(buildConfig);
    return true;
  }
}

class FakePagesProjectDetailsNotifier extends PagesProjectDetailsNotifier {
  FakePagesProjectDetailsNotifier(this.project);
  final PagesProject project;

  @override
  FutureOr<PagesProject> build(String projectName) => project;
}

void main() {
  late FakePagesSettingsNotifier fakeSettingsNotifier;
  late PagesProject mockProject;

  setUp(() {
    mockProject = PagesProject(
      id: 'test-id',
      name: 'test-project',
      subdomain: 'test.pages.dev',
      createdOn: DateTime.now(),
      buildConfig: const BuildConfig(buildCommand: 'npm run build'),
      deploymentConfigs: const DeploymentConfigs(
        production: DeploymentConfig(envVars: {}, compatibilityDate: '2024-01-01', compatibilityFlags: []),
        preview: DeploymentConfig(envVars: {}, compatibilityDate: '2024-01-01', compatibilityFlags: []),
      ),
    );
    
    fakeSettingsNotifier = FakePagesSettingsNotifier();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        pagesSettingsNotifierProvider.overrideWith(() => fakeSettingsNotifier),
        pagesProjectDetailsNotifierProvider('test-project').overrideWith(() => FakePagesProjectDetailsNotifier(mockProject)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: PagesSettingsTab(project: mockProject),
        ),
      ),
    );
  }

  testWidgets('Should trigger save when build command field loses focus (blur)', (tester) async {
    // Arrange
    Map<String, dynamic>? capturedBuildConfig;
    fakeSettingsNotifier.onUpdate = (config) => capturedBuildConfig = config;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final buildCommandFinder = find.byType(TextFormField).first;
    final otherFieldFinder = find.byType(TextFormField).at(1); // Destination Dir

    // Act
    // 1. Focus and type
    await tester.tap(buildCommandFinder);
    await tester.enterText(buildCommandFinder, 'new build command');
    await tester.pump();
    
    // 2. Blur by tapping another field
    // In Flutter tests, focusing another field is the most reliable way to blur the previous one
    await tester.tap(otherFieldFinder);
    await tester.pumpAndSettle();

    // Assert
    expect(capturedBuildConfig, isNotNull);
    expect(capturedBuildConfig!['build_command'], 'new build command');
  });
}
