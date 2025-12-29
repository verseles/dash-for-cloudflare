import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloudflare_response.freezed.dart';
part 'cloudflare_response.g.dart';

@Freezed(genericArgumentFactories: true)
sealed class CloudflareResponse<T> with _$CloudflareResponse<T> {
  const factory CloudflareResponse({
    T? result,
    @Default(true) bool success,
    @Default([]) List<CloudflareError> errors,
    @Default([]) List<CloudflareMessage> messages,
    CloudflareResultInfo? resultInfo,
  }) = _CloudflareResponse<T>;

  factory CloudflareResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$CloudflareResponseFromJson(json, fromJsonT);
}

@freezed
sealed class CloudflareError with _$CloudflareError {
  const factory CloudflareError({required int code, required String message}) =
      _CloudflareError;

  factory CloudflareError.fromJson(Map<String, dynamic> json) =>
      _$CloudflareErrorFromJson(json);
}

@freezed
sealed class CloudflareMessage with _$CloudflareMessage {
  const factory CloudflareMessage({
    required int code,
    required String message,
  }) = _CloudflareMessage;

  factory CloudflareMessage.fromJson(Map<String, dynamic> json) =>
      _$CloudflareMessageFromJson(json);
}

@freezed
sealed class CloudflareResultInfo with _$CloudflareResultInfo {
  const factory CloudflareResultInfo({
    required int page,
    @JsonKey(name: 'per_page') required int perPage,
    required int count,
    @JsonKey(name: 'total_count') required int totalCount,
    @JsonKey(name: 'total_pages') required int totalPages,
  }) = _CloudflareResultInfo;

  factory CloudflareResultInfo.fromJson(Map<String, dynamic> json) =>
      _$CloudflareResultInfoFromJson(json);
}

@freezed
sealed class DeleteResponse with _$DeleteResponse {
  const factory DeleteResponse({required String id}) = _DeleteResponse;

  factory DeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteResponseFromJson(json);
}
