import 'package:freezed_annotation/freezed_annotation.dart';
import 'pages_deployment.dart';

part 'pages_project.freezed.dart';
part 'pages_project.g.dart';

/// Cloudflare Pages Project model.
@freezed
sealed class PagesProject with _$PagesProject {
  const factory PagesProject({
    required String id,
    required String name,
    required String subdomain,
    @Default([]) List<String> domains,
    @JsonKey(name: 'created_on') required DateTime createdOn,
    @JsonKey(name: 'build_config') BuildConfig? buildConfig,
    @JsonKey(name: 'deployment_configs') DeploymentConfigs? deploymentConfigs,
    @JsonKey(name: 'source') PagesSource? source,
    @JsonKey(name: 'latest_deployment') PagesDeployment? latestDeployment,
    @JsonKey(name: 'canonical_deployment') PagesDeployment? canonicalDeployment,
  }) = _PagesProject;

  factory PagesProject.fromJson(Map<String, dynamic> json) =>
      _$PagesProjectFromJson(json);
}

/// Deployment configurations (production/preview)
@freezed
sealed class DeploymentConfigs with _$DeploymentConfigs {
  const factory DeploymentConfigs({
    required DeploymentConfig production,
    required DeploymentConfig preview,
  }) = _DeploymentConfigs;

  factory DeploymentConfigs.fromJson(Map<String, dynamic> json) =>
      _$DeploymentConfigsFromJson(json);
}

/// Configuration for a specific deployment environment
@freezed
sealed class DeploymentConfig with _$DeploymentConfig {
  @JsonSerializable(includeIfNull: true)
  const factory DeploymentConfig({
    @JsonKey(name: 'env_vars') Map<String, EnvVar>? envVars,
    @JsonKey(name: 'kv_namespaces') Map<String, PagesBinding>? kvNamespaces,
    @JsonKey(name: 'd1_databases') Map<String, PagesBinding>? d1Databases,
    @JsonKey(name: 'r2_buckets') Map<String, PagesBinding>? r2Buckets,
    @JsonKey(name: 'durable_object_namespaces')
    Map<String, PagesBinding>? durableObjectNamespaces,
    @JsonKey(name: 'services') Map<String, PagesBinding>? services,
    @JsonKey(name: 'ai_bindings') Map<String, PagesBinding>? aiBindings,
    @JsonKey(name: 'compatibility_date') String? compatibilityDate,
    @JsonKey(name: 'compatibility_flags') List<String>? compatibilityFlags,
    @JsonKey(name: 'build_watch_paths') List<String>? buildWatchPaths,
    @JsonKey(name: 'usage_model') String? usageModel,
    @JsonKey(name: 'placement') Placement? placement,
  }) = _DeploymentConfig;

  factory DeploymentConfig.fromJson(Map<String, dynamic> json) =>
      _$DeploymentConfigFromJson(json);
}

/// Binding model for Pages (KV, D1, R2, etc.)
@freezed
sealed class PagesBinding with _$PagesBinding {
  @JsonSerializable(includeIfNull: true)
  const factory PagesBinding({
    @JsonKey(name: 'namespace_id') String? namespaceId,
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'bucket_name') String? bucketName,
    @JsonKey(name: 'service') String? service,
    @JsonKey(name: 'environment') String? environment,
    @JsonKey(name: 'project_name') String? projectName,
  }) = _PagesBinding;

  factory PagesBinding.fromJson(Map<String, dynamic> json) =>
      _$PagesBindingFromJson(json);
}

/// Placement configuration
@freezed
sealed class Placement with _$Placement {
  const factory Placement({
    @Default('default') String mode,
  }) = _Placement;

  factory Placement.fromJson(Map<String, dynamic> json) =>
      _$PlacementFromJson(json);
}

/// Environment variable model
@freezed
sealed class EnvVar with _$EnvVar {
  @JsonSerializable(includeIfNull: true)
  const factory EnvVar({
    String? value,
    String? type, // e.g. "plain_text" or "secret"
  }) = _EnvVar;

  factory EnvVar.fromJson(Map<String, dynamic> json) => _$EnvVarFromJson(json);
}

/// Build configuration for a Pages project
@freezed
sealed class BuildConfig with _$BuildConfig {
  @JsonSerializable(includeIfNull: true)
  const factory BuildConfig({
    @JsonKey(name: 'build_command') String? buildCommand,
    @JsonKey(name: 'destination_dir') String? destinationDir,
    @JsonKey(name: 'root_dir') String? rootDir,
    @JsonKey(name: 'web_analytics_tag') String? webAnalyticsTag,
    @JsonKey(name: 'web_analytics_token') String? webAnalyticsToken,
    @JsonKey(name: 'build_system_version') String? buildSystemVersion,
    @JsonKey(name: 'build_cache') bool? buildCache,
  }) = _BuildConfig;

  factory BuildConfig.fromJson(Map<String, dynamic> json) =>
      _$BuildConfigFromJson(json);
}

/// Source configuration (git repo connection)
@freezed
sealed class PagesSource with _$PagesSource {
  const factory PagesSource({String? type, PagesSourceConfig? config}) =
      _PagesSource;

  factory PagesSource.fromJson(Map<String, dynamic> json) =>
      _$PagesSourceFromJson(json);
}

/// Source config details
@freezed
sealed class PagesSourceConfig with _$PagesSourceConfig {
  const factory PagesSourceConfig({
    String? owner,
    @JsonKey(name: 'repo_name') String? repoName,
    @JsonKey(name: 'production_branch') String? productionBranch,
    @JsonKey(name: 'pr_comments_enabled') bool? prCommentsEnabled,
    @JsonKey(name: 'deployments_enabled') bool? deploymentsEnabled,
    @JsonKey(name: 'production_deployments_enabled')
    bool? productionDeploymentsEnabled,
  }) = _PagesSourceConfig;

  factory PagesSourceConfig.fromJson(Map<String, dynamic> json) =>
      _$PagesSourceConfigFromJson(json);
}

/// Extension for PagesProject
extension PagesProjectExtension on PagesProject {
  /// Production URL (subdomain.pages.dev)
  String get productionUrl => 'https://$subdomain.pages.dev';

  /// Primary URL: custom domain if available, otherwise pages.dev
  String get primaryUrl {
    final customDomain = domains
        .where((d) => !d.endsWith('.pages.dev'))
        .firstOrNull;
    return customDomain != null ? 'https://$customDomain' : productionUrl;
  }

  /// Check if auto-deploy is paused (either preview or production)
  bool get isAutoDeployPaused =>
      hasGitSource &&
      (source?.config?.deploymentsEnabled == false ||
          source?.config?.productionDeploymentsEnabled == false);

  /// Check if project has custom domains
  bool get hasCustomDomains =>
      domains.isNotEmpty && domains.any((d) => !d.endsWith('.pages.dev'));

  /// Get the effective deployment for status display.
  /// Uses canonical_deployment when latest_deployment was skipped.
  PagesDeployment? get effectiveDeployment {
    // If latest deployment was skipped, use canonical (the one actually serving)
    if (latestDeployment?.isSkipped == true) {
      return canonicalDeployment;
    }
    // Otherwise use latest, falling back to canonical
    return latestDeployment ?? canonicalDeployment;
  }

  /// Get the last deployment status (uses effective deployment)
  String? get lastDeploymentStatus => effectiveDeployment?.status;

  /// Check if connected to a git repo
  bool get hasGitSource => source?.type == 'github' || source?.type == 'gitlab';
}
