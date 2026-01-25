import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cf/features/pages/providers/pages_provider.dart';
import 'package:cf/core/providers/api_providers.dart';
import 'package:cf/core/api/client/cloudflare_api.dart';
import 'package:cf/core/api/models/cloudflare_response.dart';
import 'package:cf/features/auth/providers/account_provider.dart';
import 'package:cf/features/auth/providers/settings_provider.dart';

class MockCloudflareApi extends Mock implements CloudflareApi {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockCloudflareApi mockApi;
  late MockSharedPreferences mockPrefs;
  late ProviderContainer container;

  setUp(() {
    mockApi = MockCloudflareApi();
    mockPrefs = MockSharedPreferences();
    
    container = ProviderContainer(
      overrides: [
        cloudflareApiProvider.overrideWithValue(mockApi),
        sharedPreferencesProvider.overrideWith((ref) => Future.value(mockPrefs)),
        selectedAccountIdProvider.overrideWith((ref) => 'test-account'),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PagesSettingsNotifier Payload Validation', () {
    test('updateProject should remove null values but preserve them in build_config and env_vars', () async {
      // Arrange
      const projectName = 'test-project';

      when(() => mockApi.patchPagesProject(any(), any(), any())).thenAnswer(
        (_) async => const CloudflareResponse(result: null, success: true, errors: [], messages: []),
      );

      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

      // Act
      await container.read(pagesSettingsNotifierProvider.notifier).updateProject(
        projectName: projectName,
        buildConfig: {
          'build_command': 'npm run build',
          'root_dir': null, // Should be PRESERVED now
        },
        deploymentConfigs: {
          'production': {
            'compatibility_date': '2024-01-01',
            'env_vars': {
              'KEY_TO_DELETE': null, // Should be preserved
              'KEY_TO_KEEP': {'value': 'val', 'type': 'plain_text'},
            },
          }
        },
      );

      // Assert
      final verified = verify(() => mockApi.patchPagesProject(
        'test-account',
        projectName,
        captureAny(),
      ));
      
      final data = verified.captured.first as Map<String, dynamic>;

      // 1. root_dir should be PRESERVED (now required to clear the field)
      expect(data['build_config'].containsKey('root_dir'), isTrue);
      expect(data['build_config']['root_dir'], isNull);
      
      // 2. KEY_TO_DELETE should still be there with null value (required for deletion)
      final envVars = data['deployment_configs']['production']['env_vars'] as Map;
      expect(envVars.containsKey('KEY_TO_DELETE'), isTrue);
      expect(envVars['KEY_TO_DELETE'], isNull);
      
      expect(envVars['KEY_TO_KEEP']['value'], 'val');
    });
  });
}
