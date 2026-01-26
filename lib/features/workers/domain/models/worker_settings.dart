import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_settings.freezed.dart';
part 'worker_settings.g.dart';

/// Worker settings including bindings and compatibility.
@freezed
sealed class WorkerSettings with _$WorkerSettings {
  const factory WorkerSettings({
    @Default([]) List<WorkerBinding> bindings,
    @JsonKey(name: 'compatibility_date') String? compatibilityDate,
    @JsonKey(name: 'compatibility_flags')
    @Default([])
    List<String> compatibilityFlags,
    @JsonKey(name: 'usage_model') @Default('bundled') String usageModel,
    @JsonKey(name: 'placement') Placement? placement,
    @JsonKey(name: 'observability') Observability? observability,
  }) = _WorkerSettings;

  factory WorkerSettings.fromJson(Map<String, dynamic> json) =>
      _$WorkerSettingsFromJson(json);
}

/// Placement configuration for Workers
@freezed
sealed class Placement with _$Placement {
  const factory Placement({
    @Default('default') String mode,
  }) = _Placement;

  factory Placement.fromJson(Map<String, dynamic> json) =>
      _$PlacementFromJson(json);
}

/// Observability configuration for Workers
@freezed
sealed class Observability with _$Observability {
  const factory Observability({
    @Default(false) bool enabled,
    @JsonKey(name: 'head_sampling_rate') double? headSamplingRate,
  }) = _Observability;

  factory Observability.fromJson(Map<String, dynamic> json) =>
      _$ObservabilityFromJson(json);
}

/// Worker binding model (KV, R2, D1, DO, Secrets, etc.)
@freezed
sealed class WorkerBinding with _$WorkerBinding {
  const factory WorkerBinding({
    required String type,
    required String name,
    // KV
    @JsonKey(name: 'namespace_id') String? namespaceId,
    // R2
    @JsonKey(name: 'bucket_name') String? bucketName,
    // D1 / Hyperdrive
    String? id,
    // Durable Objects
    @JsonKey(name: 'class_name') String? className,
    @JsonKey(name: 'script_name') String? scriptName,
    // Plain text / Environment variables
    String? text,
    // Service binding
    String? service,
    String? environment,
    // Queue
    @JsonKey(name: 'queue_name') String? queueName,
    // AI
    @JsonKey(name: 'project_name') String? projectName,
  }) = _WorkerBinding;

  factory WorkerBinding.fromJson(Map<String, dynamic> json) =>
      _$WorkerBindingFromJson(json);
}
