import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/pages/domain/models/pages_deployment.dart';

void main() {
  group('PagesDeployment', () {
    group('fromJson', () {
      test('parses minimal deployment', () {
        final json = {
          'id': 'deploy123',
          'url': 'https://abc123.my-site.pages.dev',
          'environment': 'production',
          'created_on': '2025-01-20T15:00:00Z',
        };

        final deployment = PagesDeployment.fromJson(json);

        expect(deployment.id, 'deploy123');
        expect(deployment.url, 'https://abc123.my-site.pages.dev');
        expect(deployment.environment, 'production');
        expect(deployment.createdOn, DateTime.utc(2025, 1, 20, 15, 0, 0));
        expect(deployment.stages, isEmpty);
      });

      test('parses deployment with short_id', () {
        final json = {
          'id': 'deploy123',
          'short_id': 'abc123',
          'url': 'https://abc123.my-site.pages.dev',
          'environment': 'preview',
          'created_on': '2025-01-20T15:00:00Z',
        };

        final deployment = PagesDeployment.fromJson(json);

        expect(deployment.shortId, 'abc123');
        expect(deployment.environment, 'preview');
      });

      test('parses deployment with trigger', () {
        final json = {
          'id': 'deploy123',
          'url': 'https://abc123.my-site.pages.dev',
          'environment': 'production',
          'created_on': '2025-01-20T15:00:00Z',
          'deployment_trigger': {
            'type': 'push',
            'metadata': {
              'branch': 'main',
              'commit_hash': 'abc123def456',
              'commit_message': 'feat: add new feature',
            },
          },
        };

        final deployment = PagesDeployment.fromJson(json);

        expect(deployment.deploymentTrigger, isNotNull);
        expect(deployment.deploymentTrigger!.type, 'push');
        expect(deployment.deploymentTrigger!.metadata, isNotNull);
        expect(deployment.deploymentTrigger!.metadata!.branch, 'main');
        expect(
          deployment.deploymentTrigger!.metadata!.commitHash,
          'abc123def456',
        );
        expect(
          deployment.deploymentTrigger!.metadata!.commitMessage,
          'feat: add new feature',
        );
      });

      test('parses deployment with stages', () {
        final json = {
          'id': 'deploy123',
          'url': 'https://abc123.my-site.pages.dev',
          'environment': 'production',
          'created_on': '2025-01-20T15:00:00Z',
          'stages': [
            {
              'name': 'queued',
              'status': 'success',
              'started_on': '2025-01-20T15:00:00Z',
              'ended_on': '2025-01-20T15:00:01Z',
            },
            {
              'name': 'initialize',
              'status': 'success',
              'started_on': '2025-01-20T15:00:01Z',
              'ended_on': '2025-01-20T15:00:05Z',
            },
            {
              'name': 'build',
              'status': 'success',
              'started_on': '2025-01-20T15:00:05Z',
              'ended_on': '2025-01-20T15:01:00Z',
            },
            {
              'name': 'deploy',
              'status': 'success',
              'started_on': '2025-01-20T15:01:00Z',
              'ended_on': '2025-01-20T15:01:05Z',
            },
          ],
        };

        final deployment = PagesDeployment.fromJson(json);

        expect(deployment.stages, hasLength(4));
        expect(deployment.stages[0].name, 'queued');
        expect(deployment.stages[2].name, 'build');
      });
    });

    group('toJson', () {
      test('serializes deployment correctly', () {
        final deployment = PagesDeployment(
          id: 'deploy123',
          url: 'https://abc123.pages.dev',
          environment: 'production',
          createdOn: DateTime.utc(2025, 1, 20, 15, 0, 0),
        );

        final json = deployment.toJson();

        expect(json['id'], 'deploy123');
        expect(json['url'], 'https://abc123.pages.dev');
        expect(json['environment'], 'production');
      });
    });

    group('equality', () {
      test('equal deployments are equal', () {
        final deployment1 = PagesDeployment(
          id: 'deploy123',
          url: 'https://abc.pages.dev',
          environment: 'production',
          createdOn: DateTime.utc(2025, 1, 20),
        );
        final deployment2 = PagesDeployment(
          id: 'deploy123',
          url: 'https://abc.pages.dev',
          environment: 'production',
          createdOn: DateTime.utc(2025, 1, 20),
        );

        expect(deployment1, equals(deployment2));
      });
    });
  });

  group('PagesDeploymentStatus extension', () {
    test('status returns success when all stages succeed', () {
      final deployment = PagesDeployment(
        id: 'deploy123',
        url: 'https://abc.pages.dev',
        environment: 'production',
        createdOn: DateTime.utc(2025, 1, 20),
        stages: const [
          DeploymentStage(name: 'queued', status: 'success'),
          DeploymentStage(name: 'build', status: 'success'),
          DeploymentStage(name: 'deploy', status: 'success'),
        ],
      );

      expect(deployment.status, 'success');
    });

    test('status returns failure when any stage fails', () {
      final deployment = PagesDeployment(
        id: 'deploy123',
        url: 'https://abc.pages.dev',
        environment: 'production',
        createdOn: DateTime.utc(2025, 1, 20),
        stages: const [
          DeploymentStage(name: 'queued', status: 'success'),
          DeploymentStage(name: 'build', status: 'failure'),
          DeploymentStage(name: 'deploy', status: 'queued'),
        ],
      );

      expect(deployment.status, 'failure');
    });

    test('status returns building when any stage is active', () {
      final deployment = PagesDeployment(
        id: 'deploy123',
        url: 'https://abc.pages.dev',
        environment: 'production',
        createdOn: DateTime.utc(2025, 1, 20),
        stages: const [
          DeploymentStage(name: 'queued', status: 'success'),
          DeploymentStage(name: 'build', status: 'active'),
          DeploymentStage(name: 'deploy', status: 'queued'),
        ],
      );

      expect(deployment.status, 'building');
    });

    test('status returns queued when first stage is queued', () {
      final deployment = PagesDeployment(
        id: 'deploy123',
        url: 'https://abc.pages.dev',
        environment: 'production',
        createdOn: DateTime.utc(2025, 1, 20),
        stages: const [
          DeploymentStage(name: 'queued', status: 'queued'),
          DeploymentStage(name: 'build', status: 'queued'),
        ],
      );

      expect(deployment.status, 'queued');
    });

    test('status returns unknown for empty stages', () {
      final deployment = PagesDeployment(
        id: 'deploy123',
        url: 'https://abc.pages.dev',
        environment: 'production',
        createdOn: DateTime.utc(2025, 1, 20),
      );

      expect(deployment.status, 'unknown');
    });

    test('status returns success when some stages are skipped', () {
      final deployment = PagesDeployment(
        id: 'deploy123',
        url: 'https://abc.pages.dev',
        environment: 'production',
        createdOn: DateTime.utc(2025, 1, 20),
        stages: const [
          DeploymentStage(name: 'queued', status: 'success'),
          DeploymentStage(name: 'clone_repo', status: 'skipped'),
          DeploymentStage(name: 'build', status: 'success'),
          DeploymentStage(name: 'deploy', status: 'success'),
        ],
      );

      expect(deployment.status, 'success');
    });

    test('isProduction returns true for production environment', () {
      final deployment = PagesDeployment(
        id: 'deploy123',
        url: 'https://abc.pages.dev',
        environment: 'production',
        createdOn: DateTime.utc(2025, 1, 20),
      );

      expect(deployment.isProduction, true);
      expect(deployment.isPreview, false);
    });

    test('isPreview returns true for preview environment', () {
      final deployment = PagesDeployment(
        id: 'deploy123',
        url: 'https://abc.pages.dev',
        environment: 'preview',
        createdOn: DateTime.utc(2025, 1, 20),
      );

      expect(deployment.isProduction, false);
      expect(deployment.isPreview, true);
    });
  });

  group('DeploymentStage', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'build',
        'status': 'success',
        'started_on': '2025-01-20T15:00:00Z',
        'ended_on': '2025-01-20T15:01:00Z',
      };

      final stage = DeploymentStage.fromJson(json);

      expect(stage.name, 'build');
      expect(stage.status, 'success');
      expect(stage.startedOn, DateTime.utc(2025, 1, 20, 15, 0, 0));
      expect(stage.endedOn, DateTime.utc(2025, 1, 20, 15, 1, 0));
    });

    test('status extensions work correctly', () {
      const successStage = DeploymentStage(name: 'build', status: 'success');
      const activeStage = DeploymentStage(name: 'build', status: 'active');
      const failedStage = DeploymentStage(name: 'build', status: 'failure');
      const queuedStage = DeploymentStage(name: 'build', status: 'queued');
      const skippedStage = DeploymentStage(name: 'build', status: 'skipped');

      expect(successStage.isSuccess, true);
      expect(successStage.isFailed, false);

      expect(activeStage.isActive, true);
      expect(activeStage.isSuccess, false);

      expect(failedStage.isFailed, true);
      expect(failedStage.isSuccess, false);

      expect(queuedStage.isQueued, true);
      expect(skippedStage.isSkipped, true);
    });
  });

  group('DeploymentTrigger', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'push',
        'metadata': {
          'branch': 'feature/test',
          'commit_hash': 'abc123',
          'commit_message': 'test commit',
          'commit_dirty': false,
        },
      };

      final trigger = DeploymentTrigger.fromJson(json);

      expect(trigger.type, 'push');
      expect(trigger.metadata, isNotNull);
      expect(trigger.metadata!.branch, 'feature/test');
      expect(trigger.metadata!.commitHash, 'abc123');
      expect(trigger.metadata!.commitMessage, 'test commit');
      expect(trigger.metadata!.commitDirty, false);
    });
  });
}
