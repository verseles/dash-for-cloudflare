import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_domain.freezed.dart';
part 'worker_domain.g.dart';

/// Worker Custom Domain model (Account-scoped).
@freezed
sealed class WorkerDomain with _$WorkerDomain {
  const factory WorkerDomain({
    required String id,
    required String hostname,
    required String service,
    required String environment,
    @JsonKey(name: 'zone_id') required String zoneId,
    @JsonKey(name: 'zone_name') required String zoneName,
  }) = _WorkerDomain;

  factory WorkerDomain.fromJson(Map<String, dynamic> json) =>
      _$WorkerDomainFromJson(json);
}
