import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/pages/domain/models/pages_project.dart';
import 'package:cf/features/pages/domain/models/pages_deployment.dart';

void main() {
  group('PagesProject', () {
    group('fromJson', () {
      test('parses minimal project', () {
        final json = {
          'id': 'proj123',
          'name': 'my-site',
          'subdomain': 'my-site-abc',
          'created_on': '2025-01-15T10:00:00Z',
        };

        final project = PagesProject.fromJson(json);

        expect(project.id, 'proj123');
        expect(project.name, 'my-site');
        expect(project.subdomain, 'my-site-abc');
        expect(project.createdOn, DateTime.utc(2025, 1, 15, 10, 0, 0));
        expect(project.domains, isEmpty);
        expect(project.buildConfig, isNull);
        expect(project.source, isNull);
      });

      test('parses project with domains', () {
        final json = {
          'id': 'proj123',
          'name': 'my-site',
          'subdomain': 'my-site-abc',
          'created_on': '2025-01-15T10:00:00Z',
          'domains': ['example.com', 'www.example.com'],
        };

        final project = PagesProject.fromJson(json);

        expect(project.domains, hasLength(2));
        expect(project.domains, contains('example.com'));
      });

      test('parses project with build config', () {
        final json = {
          'id': 'proj123',
          'name': 'my-site',
          'subdomain': 'my-site-abc',
          'created_on': '2025-01-15T10:00:00Z',
          'build_config': {
            'build_command': 'npm run build',
            'destination_dir': 'dist',
            'root_dir': '/',
          },
        };

        final project = PagesProject.fromJson(json);

        expect(project.buildConfig, isNotNull);
        expect(project.buildConfig!.buildCommand, 'npm run build');
        expect(project.buildConfig!.destinationDir, 'dist');
      });

      test('parses project with GitHub source', () {
        final json = {
          'id': 'proj123',
          'name': 'my-site',
          'subdomain': 'my-site-abc',
          'created_on': '2025-01-15T10:00:00Z',
          'source': {
            'type': 'github',
            'config': {
              'owner': 'myuser',
              'repo_name': 'my-repo',
              'production_branch': 'main',
            },
          },
        };

        final project = PagesProject.fromJson(json);

        expect(project.source, isNotNull);
        expect(project.source!.type, 'github');
        expect(project.source!.config, isNotNull);
        expect(project.source!.config!.owner, 'myuser');
        expect(project.source!.config!.repoName, 'my-repo');
        expect(project.source!.config!.productionBranch, 'main');
      });

      test('parses project with latest deployment', () {
        final json = {
          'id': 'proj123',
          'name': 'my-site',
          'subdomain': 'my-site-abc',
          'created_on': '2025-01-15T10:00:00Z',
          'latest_deployment': {
            'id': 'deploy123',
            'url': 'https://abc123.my-site.pages.dev',
            'environment': 'production',
            'created_on': '2025-01-20T15:00:00Z',
            'stages': [],
          },
        };

        final project = PagesProject.fromJson(json);

        expect(project.latestDeployment, isNotNull);
        expect(project.latestDeployment!.id, 'deploy123');
        expect(project.latestDeployment!.environment, 'production');
      });
    });

    group('toJson', () {
      test('serializes project correctly', () {
        final project = PagesProject(
          id: 'proj123',
          name: 'my-site',
          subdomain: 'my-site-abc',
          createdOn: DateTime.utc(2025, 1, 15, 10, 0, 0),
          domains: ['example.com'],
        );

        final json = project.toJson();

        expect(json['id'], 'proj123');
        expect(json['name'], 'my-site');
        expect(json['subdomain'], 'my-site-abc');
        expect(json['domains'], contains('example.com'));
      });
    });

    group('equality', () {
      test('equal projects are equal', () {
        final project1 = PagesProject(
          id: 'proj123',
          name: 'my-site',
          subdomain: 'my-site-abc',
          createdOn: DateTime.utc(2025, 1, 15),
        );
        final project2 = PagesProject(
          id: 'proj123',
          name: 'my-site',
          subdomain: 'my-site-abc',
          createdOn: DateTime.utc(2025, 1, 15),
        );

        expect(project1, equals(project2));
      });
    });
  });

  group('PagesProjectExtension', () {
    test('productionUrl returns correct URL', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
      );

      expect(project.productionUrl, 'https://my-site-abc.pages.dev');
    });

    test('hasCustomDomains returns false for empty domains', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
      );

      expect(project.hasCustomDomains, false);
    });

    test('hasCustomDomains returns false for only pages.dev domains', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
        domains: ['my-site-abc.pages.dev'],
      );

      expect(project.hasCustomDomains, false);
    });

    test('hasCustomDomains returns true for custom domain', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
        domains: ['example.com', 'my-site-abc.pages.dev'],
      );

      expect(project.hasCustomDomains, true);
    });

    test('hasGitSource returns true for GitHub', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
        source: const PagesSource(type: 'github'),
      );

      expect(project.hasGitSource, true);
    });

    test('hasGitSource returns true for GitLab', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
        source: const PagesSource(type: 'gitlab'),
      );

      expect(project.hasGitSource, true);
    });

    test('hasGitSource returns false for direct upload', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
        source: const PagesSource(type: 'upload'),
      );

      expect(project.hasGitSource, false);
    });

    test('primaryUrl returns custom domain when available', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
        domains: ['example.com', 'my-site-abc.pages.dev'],
      );

      expect(project.primaryUrl, 'https://example.com');
    });

    test('primaryUrl returns pages.dev when no custom domain', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
        domains: ['my-site-abc.pages.dev'],
      );

      expect(project.primaryUrl, 'https://my-site-abc.pages.dev');
    });

    test('primaryUrl returns pages.dev when domains empty', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
      );

      expect(project.primaryUrl, 'https://my-site-abc.pages.dev');
    });

    test(
      'isAutoDeployPaused returns true when deploymentsEnabled is false',
      () {
        final project = PagesProject(
          id: 'proj123',
          name: 'my-site',
          subdomain: 'my-site-abc',
          createdOn: DateTime.utc(2025, 1, 15),
          source: const PagesSource(
            type: 'github',
            config: PagesSourceConfig(deploymentsEnabled: false),
          ),
        );

        expect(project.isAutoDeployPaused, true);
      },
    );

    test(
      'isAutoDeployPaused returns false when deploymentsEnabled is true',
      () {
        final project = PagesProject(
          id: 'proj123',
          name: 'my-site',
          subdomain: 'my-site-abc',
          createdOn: DateTime.utc(2025, 1, 15),
          source: const PagesSource(
            type: 'github',
            config: PagesSourceConfig(deploymentsEnabled: true),
          ),
        );

        expect(project.isAutoDeployPaused, false);
      },
    );

    test('isAutoDeployPaused returns false when no source', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
      );

      expect(project.isAutoDeployPaused, false);
    });

    test('lastDeploymentStatus returns status from latest deployment', () {
      final project = PagesProject(
        id: 'proj123',
        name: 'my-site',
        subdomain: 'my-site-abc',
        createdOn: DateTime.utc(2025, 1, 15),
        latestDeployment: PagesDeployment(
          id: 'deploy123',
          url: 'https://abc.pages.dev',
          environment: 'production',
          createdOn: DateTime.utc(2025, 1, 20),
          stages: const [
            DeploymentStage(name: 'build', status: 'success'),
            DeploymentStage(name: 'deploy', status: 'success'),
          ],
        ),
      );

      expect(project.lastDeploymentStatus, 'success');
    });
  });

  group('BuildConfig', () {
    test('fromJson parses correctly', () {
      final json = {
        'build_command': 'flutter build web',
        'destination_dir': 'build/web',
        'root_dir': '/',
        'web_analytics_tag': 'tag123',
      };

      final config = BuildConfig.fromJson(json);

      expect(config.buildCommand, 'flutter build web');
      expect(config.destinationDir, 'build/web');
      expect(config.rootDir, '/');
      expect(config.webAnalyticsTag, 'tag123');
    });
  });

  group('PagesSource', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'github',
        'config': {
          'owner': 'myorg',
          'repo_name': 'myrepo',
          'production_branch': 'main',
          'pr_comments_enabled': true,
          'deployments_enabled': true,
        },
      };

      final source = PagesSource.fromJson(json);

      expect(source.type, 'github');
      expect(source.config, isNotNull);
      expect(source.config!.owner, 'myorg');
      expect(source.config!.repoName, 'myrepo');
      expect(source.config!.productionBranch, 'main');
      expect(source.config!.prCommentsEnabled, true);
    });
  });
}
