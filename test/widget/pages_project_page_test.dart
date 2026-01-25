import 'dart:async';
import 'package:cf/features/pages/domain/models/pages_project.dart';
import 'package:cf/features/pages/domain/models/pages_deployment.dart';
import 'package:cf/features/pages/domain/models/pages_domain.dart';
import 'package:cf/features/pages/presentation/pages/pages_project_page.dart';
import 'package:cf/features/pages/providers/pages_provider.dart';
import 'package:cf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import '../fixtures/fixture_reader.dart';

// Mock Notifiers
class TestProjectDetailsNotifier extends PagesProjectDetailsNotifier {
  TestProjectDetailsNotifier(this.initialValue);
  final AsyncValue<PagesProject> initialValue;

  @override
  FutureOr<PagesProject> build(String projectName) async {
    return initialValue.value!;
  }
}

class TestDeploymentsNotifier extends PagesDeploymentsNotifier {
  TestDeploymentsNotifier(this.initialValue);
  final AsyncValue<List<PagesDeployment>> initialValue;

  @override
  FutureOr<List<PagesDeployment>> build(String projectName) async {
    return initialValue.value!;
  }
}

class TestDomainsNotifier extends PagesDomainsNotifier {
  TestDomainsNotifier(this.initialValue);
  final AsyncValue<List<PagesDomain>> initialValue;

  @override
  FutureOr<List<PagesDomain>> build(String projectName) async {
    return initialValue.value!;
  }
}

void main() {
  group('PagesProjectPage Widget Tests', () {
    const projectName = 'test-project';

    testWidgets('renders project details and deployments tab correctly', (tester) async {
      final projectsJson = jsonDecode(fixture('pages/projects.json'));
      final project = PagesProject.fromJson(projectsJson['result'][0]);
      
      final deploymentsJson = jsonDecode(fixture('pages/deployments.json'));
      final deployments = (deploymentsJson['result'] as List)
          .map((e) => PagesDeployment.fromJson(e))
          .toList();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pagesProjectDetailsNotifierProvider(projectName)
                .overrideWith(() => TestProjectDetailsNotifier(AsyncData(project))),
            pagesDeploymentsNotifierProvider(projectName)
                .overrideWith(() => TestDeploymentsNotifier(AsyncData(deployments))),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PagesProjectPage(projectName: projectName),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      // Check project title
      expect(find.text(projectName), findsWidgets);
      
      // Check for primary URL
      expect(find.text(project.primaryUrl), findsOneWidget);
      
      // Cleanup
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('switches between tabs', (tester) async {
      final projectsJson = jsonDecode(fixture('pages/projects.json'));
      final project = PagesProject.fromJson(projectsJson['result'][0]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pagesProjectDetailsNotifierProvider(projectName)
                .overrideWith(() => TestProjectDetailsNotifier(AsyncData(project))),
            pagesDeploymentsNotifierProvider(projectName)
                .overrideWith(() => TestDeploymentsNotifier(const AsyncData([]))),
            pagesDomainsNotifierProvider(projectName)
                .overrideWith(() => TestDomainsNotifier(const AsyncData([]))),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PagesProjectPage(projectName: projectName),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      // Tap on Custom Domains tab
      await tester.tap(find.byIcon(Symbols.language));
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.textContaining('Domains'), findsWidgets);

      // Tap on Settings tab
      await tester.tap(find.byIcon(Symbols.settings));
      await tester.pump(const Duration(seconds: 1));
      
      // The text "Build Settings" is within PagesSettingsTab
      expect(find.textContaining('Settings'), findsWidgets);
      
      // Cleanup
      await tester.pump(const Duration(seconds: 5));
    });
  });
}