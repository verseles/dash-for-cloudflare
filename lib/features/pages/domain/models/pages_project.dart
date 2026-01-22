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
    @JsonKey(name: 'source') PagesSource? source,
    @JsonKey(name: 'latest_deployment') PagesDeployment? latestDeployment,
    @JsonKey(name: 'canonical_deployment') PagesDeployment? canonicalDeployment,
  }) = _PagesProject;

  factory PagesProject.fromJson(Map<String, dynamic> json) =>
      _$PagesProjectFromJson(json);
}

/// Build configuration for a Pages project
@freezed
sealed class BuildConfig with _$BuildConfig {
  const factory BuildConfig({
    @JsonKey(name: 'build_command') String? buildCommand,
    @JsonKey(name: 'destination_dir') String? destinationDir,
    @JsonKey(name: 'root_dir') String? rootDir,
    @JsonKey(name: 'web_analytics_tag') String? webAnalyticsTag,
    @JsonKey(name: 'web_analytics_token') String? webAnalyticsToken,
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
  }) = _PagesSourceConfig;

  factory PagesSourceConfig.fromJson(Map<String, dynamic> json) =>
      _$PagesSourceConfigFromJson(json);
}

/// Extension for PagesProject
extension PagesProjectExtension on PagesProject {
  /// Production URL (subdomain.pages.dev)
  String get productionUrl => 'https://$subdomain.pages.dev';

  /// Check if project has custom domains
  bool get hasCustomDomains =>
      domains.isNotEmpty && domains.any((d) => !d.endsWith('.pages.dev'));

  /// Get the last deployment status
  String? get lastDeploymentStatus => latestDeployment?.status;

  /// Check if connected to a git repo
  bool get hasGitSource => source?.type == 'github' || source?.type == 'gitlab';
}
