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
    @JsonKey(name: 'is_skipped') @Default(false) bool isSkipped,
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
  bool get isIdle => status == 'idle';
}

/// Extension to get overall deployment status
extension PagesDeploymentStatus on PagesDeployment {
  /// Returns the current status of the deployment based on stages.
  /// Handles ad_hoc deploys where intermediate stages remain idle.
  String get status {
    // Check if deployment was explicitly skipped by Cloudflare
    // Access the model field directly (not the stage extension)
    if (isSkipped == true) return 'skipped';

    if (stages.isEmpty) return 'unknown';

    // Check for any failed stage first
    if (stages.any((s) => s.isFailed)) return 'failure';

    // Get the deploy stage (final stage) - this is the authoritative status
    final deployStage = stages.where((s) => s.name == 'deploy').firstOrNull;

    // If deploy stage is success, the whole deployment is success
    // (even if earlier stages are idle/skipped for ad_hoc deploys)
    if (deployStage?.isSuccess == true) return 'success';

    // Check for any active stage (still building/deploying)
    if (stages.any((s) => s.isActive)) return 'building';

    // If ALL stages are idle and deploy didn't succeed, it was likely skipped
    // This handles cases where is_skipped might not be set but all stages are idle
    if (stages.every((s) => s.isIdle)) return 'skipped';

    // If deploy stage hasn't started but no failures, it's still queued/pending
    if (deployStage?.isIdle == true || deployStage == null) return 'queued';

    return 'unknown';
  }

  bool get isProduction => environment == 'production';
  bool get isPreview => environment == 'preview';

  /// Check if deployment is currently building (any stage is active)
  bool get isBuilding => status == 'building' || status == 'queued';
}
