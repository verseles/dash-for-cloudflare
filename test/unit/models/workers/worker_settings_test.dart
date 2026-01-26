import 'package:cf/features/workers/domain/models/worker_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkerSettings Model', () {
    test('should create a WorkerSettings instance from JSON with various bindings', () {
      final json = {
        'bindings': [
          {
            'type': 'kv_namespace',
            'name': 'MY_KV',
            'namespace_id': 'kv-id-123'
          },
          {
            'type': 'plain_text',
            'name': 'API_URL',
            'text': 'https://api.example.com'
          },
          {
            'type': 'secret_text',
            'name': 'API_KEY'
          }
        ],
        'compatibility_date': '2024-01-01',
        'compatibility_flags': ['nodejs_compat'],
        'usage_model': 'bundled',
        'placement': {'mode': 'smart'},
        'observability': {
          'enabled': true,
          'head_sampling_rate': 0.1
        }
      };

      final settings = WorkerSettings.fromJson(json);

      expect(settings.bindings.length, 3);
      expect(settings.bindings[0].type, 'kv_namespace');
      expect(settings.bindings[0].name, 'MY_KV');
      expect(settings.bindings[0].namespaceId, 'kv-id-123');
      
      expect(settings.bindings[1].type, 'plain_text');
      expect(settings.bindings[1].text, 'https://api.example.com');
      
      expect(settings.bindings[2].type, 'secret_text');
      
      expect(settings.compatibilityDate, '2024-01-01');
      expect(settings.compatibilityFlags, ['nodejs_compat']);
      expect(settings.usageModel, 'bundled');
      expect(settings.placement?.mode, 'smart');
      expect(settings.observability?.enabled, true);
      expect(settings.observability?.headSamplingRate, 0.1);
    });
  });

  group('WorkerBinding Model', () {
    test('should handle AI bindings', () {
      final json = {
        'type': 'ai',
        'name': 'AI',
        'project_name': 'my-ai-project'
      };

      final binding = WorkerBinding.fromJson(json);
      expect(binding.type, 'ai');
      expect(binding.projectName, 'my-ai-project');
    });

    test('should handle service bindings', () {
      final json = {
        'type': 'service',
        'name': 'AUTH_SERVICE',
        'service': 'auth-worker',
        'environment': 'production'
      };

      final binding = WorkerBinding.fromJson(json);
      expect(binding.type, 'service');
      expect(binding.service, 'auth-worker');
      expect(binding.environment, 'production');
    });

    test('should handle R2 bindings', () {
      final json = {
        'type': 'r2_bucket',
        'name': 'FILES',
        'bucket_name': 'my-bucket'
      };

      final binding = WorkerBinding.fromJson(json);
      expect(binding.type, 'r2_bucket');
      expect(binding.bucketName, 'my-bucket');
    });
  });
}
