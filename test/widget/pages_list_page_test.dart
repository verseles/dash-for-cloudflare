import 'dart:async';
import 'package:cf/features/pages/domain/models/pages_project.dart';
import 'package:cf/features/pages/presentation/pages/pages_list_page.dart';
import 'package:cf/features/pages/providers/pages_provider.dart';
import 'package:cf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import '../fixtures/fixture_reader.dart';

// Mock Notifier
class TestPagesProjectsNotifier extends PagesProjectsNotifier {
  TestPagesProjectsNotifier(this.initialValue);
  final AsyncValue<PagesProjectsState> initialValue;

  @override
  FutureOr<PagesProjectsState> build() async {
    return initialValue.value!;
  }
}

void main() {
  group('PagesListPage Widget Tests', () {
    testWidgets('renders list of projects correctly', (tester) async {
      final projectsJson = jsonDecode(fixture('pages/projects.json'));
      final projects = (projectsJson['result'] as List)
          .map((e) => PagesProject.fromJson(e))
          .toList();
      
      final state = PagesProjectsState(projects: projects);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pagesProjectsNotifierProvider.overrideWith(() => TestPagesProjectsNotifier(AsyncData(state))),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PagesListPage()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for first project name
      expect(find.text(projects[0].name), findsOneWidget);
      // Check for second project name
      expect(find.text(projects[1].name), findsOneWidget);
      
      // Check for success status icons using Symbols
      expect(find.byIcon(Symbols.check_circle), findsWidgets);
    });

    testWidgets('shows empty state when no projects', (tester) async {
      const state = PagesProjectsState(projects: []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pagesProjectsNotifierProvider.overrideWith(() => TestPagesProjectsNotifier(const AsyncData(state))),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PagesListPage()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Pages projects found'), findsOneWidget);
    });
  });
}