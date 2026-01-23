import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker.freezed.dart';
part 'worker.g.dart';

/// Cloudflare Worker Script model.
@freezed
sealed class Worker with _$Worker {
  const factory Worker({
    required String id,
    String? etag,
    @Default([]) List<String> handlers,
    @JsonKey(name: 'created_on') required DateTime createdOn,
    @JsonKey(name: 'modified_on') required DateTime modifiedOn,
    @JsonKey(name: 'usage_model') @Default('bundled') String usageModel,
    @JsonKey(name: 'last_deployed_from') String? lastDeployedFrom,
  }) = _Worker;

  factory Worker.fromJson(Map<String, dynamic> json) => _$WorkerFromJson(json);
}

extension WorkerExtension on Worker {
  bool get hasFetchHandler => handlers.contains('fetch');
  bool get hasScheduledHandler => handlers.contains('scheduled');
}
