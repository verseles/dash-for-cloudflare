import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_route.freezed.dart';
part 'worker_route.g.dart';

/// Worker route model (Zone-scoped).
@freezed
sealed class WorkerRoute with _$WorkerRoute {
  const factory WorkerRoute({
    required String id,
    required String pattern,
    required String script,
    @JsonKey(name: 'request_limit_fail_open') @Default(false) bool requestLimitFailOpen,
  }) = _WorkerRoute;

  factory WorkerRoute.fromJson(Map<String, dynamic> json) =>
      _$WorkerRouteFromJson(json);
}
