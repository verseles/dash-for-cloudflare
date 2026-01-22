import 'package:freezed_annotation/freezed_annotation.dart';

part 'pages_deployment.freezed.dart';
part 'pages_deployment.g.dart';

/// Cloudflare Pages Deployment model.
@freezed
sealed class PagesDeployment with _$PagesDeployment {
  const factory PagesDeployment({
    required String id,
    required String url,
    required String environment,
    @JsonKey(name: 'short_id') String? shortId,
    @JsonKey(name: 'project_id') String? projectId,
    @JsonKey(name: 'project_name') String? projectName,
    @JsonKey(name: 'deployment_trigger') DeploymentTrigger? deploymentTrigger,
    @Default([]) List<DeploymentStage> stages,
    @JsonKey(name: 'created_on') required DateTime createdOn,
    @JsonKey(name: 'modified_on') DateTime? modifiedOn,
  }) = _PagesDeployment;

  factory PagesDeployment.fromJson(Map<String, dynamic> json) =>
      _$PagesDeploymentFromJson(json);
}

/// Deployment trigger information (branch, commit, etc.)
@freezed
sealed class DeploymentTrigger with _$DeploymentTrigger {
  const factory DeploymentTrigger({
    required String type,
    DeploymentTriggerMetadata? metadata,
  }) = _DeploymentTrigger;

  factory DeploymentTrigger.fromJson(Map<String, dynamic> json) =>
      _$DeploymentTriggerFromJson(json);
}

/// Metadata for deployment trigger
@freezed
sealed class DeploymentTriggerMetadata with _$DeploymentTriggerMetadata {
  const factory DeploymentTriggerMetadata({
    String? branch,
    @JsonKey(name: 'commit_hash') String? commitHash,
    @JsonKey(name: 'commit_message') String? commitMessage,
    @JsonKey(name: 'commit_dirty') bool? commitDirty,
  }) = _DeploymentTriggerMetadata;

  factory DeploymentTriggerMetadata.fromJson(Map<String, dynamic> json) =>
      _$DeploymentTriggerMetadataFromJson(json);
}

/// Stage of a deployment (queued, initialize, clone_repo, build, deploy)
@freezed
sealed class DeploymentStage with _$DeploymentStage {
  const factory DeploymentStage({
    required String name,
    required String status,
    @JsonKey(name: 'started_on') DateTime? startedOn,
    @JsonKey(name: 'ended_on') DateTime? endedOn,
  }) = _DeploymentStage;

  factory DeploymentStage.fromJson(Map<String, dynamic> json) =>
      _$DeploymentStageFromJson(json);
}

/// Extension to check deployment status
extension DeploymentStageStatus on DeploymentStage {
  bool get isSuccess => status == 'success';
  bool get isActive => status == 'active';
  bool get isFailed => status == 'failure';
  bool get isQueued => status == 'queued';
  bool get isSkipped => status == 'skipped';
}

/// Extension to get overall deployment status
extension PagesDeploymentStatus on PagesDeployment {
  /// Returns the current status of the deployment based on stages
  String get status {
    if (stages.isEmpty) return 'unknown';

    // Check for any failed stage
    if (stages.any((s) => s.isFailed)) return 'failure';

    // Check for any active stage
    if (stages.any((s) => s.isActive)) return 'building';

    // Check if all stages are success
    if (stages.every((s) => s.isSuccess || s.isSkipped)) return 'success';

    // Check if still queued
    if (stages.first.isQueued) return 'queued';

    return 'unknown';
  }

  bool get isProduction => environment == 'production';
  bool get isPreview => environment == 'preview';
}
