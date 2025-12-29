import 'package:freezed_annotation/freezed_annotation.dart';

part 'dns_settings.freezed.dart';
part 'dns_settings.g.dart';

@freezed
sealed class DnsSetting with _$DnsSetting {
  const factory DnsSetting({
    required String id,
    required dynamic value,
    @Default(true) bool editable,
    @JsonKey(name: 'modified_on') String? modifiedOn,
  }) = _DnsSetting;

  factory DnsSetting.fromJson(Map<String, dynamic> json) =>
      _$DnsSettingFromJson(json);
}

@freezed
sealed class DnsZoneSettings with _$DnsZoneSettings {
  const factory DnsZoneSettings({
    @JsonKey(name: 'multi_provider') @Default(false) bool multiProvider,
  }) = _DnsZoneSettings;

  factory DnsZoneSettings.fromJson(Map<String, dynamic> json) =>
      _$DnsZoneSettingsFromJson(json);
}

@freezed
sealed class DnssecDetails with _$DnssecDetails {
  const factory DnssecDetails({
    required String status,
    @JsonKey(name: 'dnssec_multi_signer') bool? dnssecMultiSigner,
    String? algorithm,
    String? digest,
    @JsonKey(name: 'digest_algorithm') String? digestAlgorithm,
    @JsonKey(name: 'digest_type') String? digestType,
    String? ds,
    int? flags,
    @JsonKey(name: 'key_tag') int? keyTag,
    @JsonKey(name: 'key_type') String? keyType,
    @JsonKey(name: 'modified_on') String? modifiedOn,
    @JsonKey(name: 'public_key') String? publicKey,
  }) = _DnssecDetails;

  factory DnssecDetails.fromJson(Map<String, dynamic> json) =>
      _$DnssecDetailsFromJson(json);
}
