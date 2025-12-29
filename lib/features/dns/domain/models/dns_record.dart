import 'package:freezed_annotation/freezed_annotation.dart';

part 'dns_record.freezed.dart';
part 'dns_record.g.dart';

@freezed
sealed class DnsRecord with _$DnsRecord {
  const factory DnsRecord({
    required String id,
    required String type,
    required String name,
    required String content,
    @Default(false) bool proxied,
    @Default(1) int ttl,
    @JsonKey(name: 'zone_id') required String zoneId,
    @JsonKey(name: 'zone_name') required String zoneName,
    int? priority,
    @JsonKey(name: 'created_on') String? createdOn,
    @JsonKey(name: 'modified_on') String? modifiedOn,
    bool? proxiable,
    bool? locked,
    Map<String, dynamic>? meta,
    Map<String, dynamic>? data,
  }) = _DnsRecord;

  factory DnsRecord.fromJson(Map<String, dynamic> json) =>
      _$DnsRecordFromJson(json);
}

@freezed
sealed class DnsRecordCreate with _$DnsRecordCreate {
  const factory DnsRecordCreate({
    required String type,
    required String name,
    required String content,
    @Default(false) bool proxied,
    @Default(1) int ttl,
    int? priority,
    Map<String, dynamic>? data,
  }) = _DnsRecordCreate;

  factory DnsRecordCreate.fromJson(Map<String, dynamic> json) =>
      _$DnsRecordCreateFromJson(json);
}
