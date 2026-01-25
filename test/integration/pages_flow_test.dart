import 'dart:async';
import 'dart:convert';
import 'package:cf/features/auth/providers/settings_provider.dart';
import 'package:cf/features/auth/providers/account_provider.dart';
import 'package:cf/features/pages/providers/pages_provider.dart';
import 'package:cf/features/pages/domain/models/pages_project.dart';
import 'package:cf/features/pages/domain/models/pages_deployment.dart';
import 'package:cf/features/pages/domain/models/pages_domain.dart';
import 'package:cf/core/router/app_router.dart';
import 'package:cf/main.dart';
import 'package:cf/core/widgets/main_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../fixtures/fixture_reader.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorage();
    when(() => mockSecureStorage.read(key: 'cloudflare_api_token'))
        .thenAnswer((_) async => 'a' * 45);
  });

  testWidgets('Pages Full Flow Integration Test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final projectsJson = jsonDecode(fixture('pages/projects.json'));
    final projects = (projectsJson['result'] as List).map((e) => PagesProject.fromJson(e)).toList();
    final firstProjectName = projects[0].name;

    final deploymentsJson = jsonDecode(fixture('pages/deployments.json'));
    final deployments = (deploymentsJson['result'] as List).map((e) => PagesDeployment.fromJson(e)).toList();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          secureStorageProvider.overrideWithValue(mockSecureStorage),
          selectedAccountIdProvider.overrideWith((ref) => 'account1'),
          hasValidTokenProvider.overrideWith((ref) => true),
          // Override Pages Notifiers to avoid network delays in integration test
          pagesProjectsNotifierProvider.overrideWith(() => _MockPagesProjectsNotifier(projects)),
          pagesProjectDetailsNotifierProvider(firstProjectName).overrideWith(() => _MockProjectDetailsNotifier(projects[0])),
          pagesDeploymentsNotifierProvider(firstProjectName).overrideWith(() => _MockDeploymentsNotifier(deployments)),
          pagesDomainsNotifierProvider(firstProjectName).overrideWith(() => _MockDomainsNotifier([])),
        ],
        child: const DashForCloudflareApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    // 1. Navigate to Pages programmatically
    final mainLayoutFinder = find.byType(MainLayout);
    if (mainLayoutFinder.evaluate().isNotEmpty) {
      final context = tester.element(mainLayoutFinder);
      context.go(AppRoutes.pages);
    }
    await tester.pumpAndSettle();

    // 2. Verify Projects List
    expect(find.textContaining(firstProjectName), findsWidgets);

    // 3. Go to Project Details
    await tester.tap(find.textContaining(firstProjectName).first);
    await tester.pumpAndSettle();

    // 4. Verify Tab: Deployments
    expect(find.textContaining('Deployments'), findsWidgets);
    
    // 5. Verify Tab: Custom Domains
    await tester.tap(find.byIcon(Symbols.language));
    await tester.pumpAndSettle();
    expect(find.textContaining('Domains'), findsWidgets);

    // Final cleanup
    await tester.pump(const Duration(seconds: 5));
  });
}

// Simple Mock Classes for Integration Test
class _MockPagesProjectsNotifier extends PagesProjectsNotifier {
  _MockPagesProjectsNotifier(this.projects);
  final List<PagesProject> projects;
  @override
  FutureOr<PagesProjectsState> build() => PagesProjectsState(projects: projects);
}

class _MockProjectDetailsNotifier extends PagesProjectDetailsNotifier {
  _MockProjectDetailsNotifier(this.project);
  final PagesProject project;
  @override
  FutureOr<PagesProject> build(String projectName) => project;
}

class _MockDeploymentsNotifier extends PagesDeploymentsNotifier {
  _MockDeploymentsNotifier(this.deployments);
  final List<PagesDeployment> deployments;
  @override
  FutureOr<List<PagesDeployment>> build(String projectName) => deployments;
}

class _MockDomainsNotifier extends PagesDomainsNotifier {
  _MockDomainsNotifier(this.domains);
  final List<PagesDomain> domains;
  @override
  FutureOr<List<PagesDomain>> build(String projectName) => domains;
}