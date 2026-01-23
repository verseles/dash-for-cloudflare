import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_settings.freezed.dart';
part 'worker_settings.g.dart';

/// Worker settings including bindings and compatibility.
@freezed
sealed class WorkerSettings with _$WorkerSettings {
  const factory WorkerSettings({
    @Default([]) List<WorkerBinding> bindings,
    @JsonKey(name: 'compatibility_date') String? compatibilityDate,
    @JsonKey(name: 'compatibility_flags') @Default([]) List<String> compatibilityFlags,
    @JsonKey(name: 'usage_model') @Default('bundled') String usageModel,
  }) = _WorkerSettings;

  factory WorkerSettings.fromJson(Map<String, dynamic> json) =>
      _$WorkerSettingsFromJson(json);
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
  }) = _WorkerBinding;

  factory WorkerBinding.fromJson(Map<String, dynamic> json) =>
      _$WorkerBindingFromJson(json);
}
