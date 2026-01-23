import 'package:freezed_annotation/freezed_annotation.dart';

part 'pages_domain.freezed.dart';
part 'pages_domain.g.dart';

/// Cloudflare Pages Custom Domain model.
@freezed
sealed class PagesDomain with _$PagesDomain {
  const factory PagesDomain({
    required String id,
    required String name,
    required String status,
    @JsonKey(name: 'created_on') required DateTime createdOn,
    @JsonKey(name: 'verification_data') Map<String, dynamic>? verificationData,
    @JsonKey(name: 'validation_data') Map<String, dynamic>? validationData,
  }) = _PagesDomain;

  factory PagesDomain.fromJson(Map<String, dynamic> json) =>
      _$PagesDomainFromJson(json);
}
