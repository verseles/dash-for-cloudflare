import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloudflare_resources.freezed.dart';
part 'cloudflare_resources.g.dart';

/// KV Namespace model
@freezed
sealed class KVNamespace with _$KVNamespace {
  const factory KVNamespace({
    required String id,
    required String title,
    @JsonKey(name: 'supports_url_encoding') @Default(false) bool supportsUrlEncoding,
  }) = _KVNamespace;

  factory KVNamespace.fromJson(Map<String, dynamic> json) =>
      _$KVNamespaceFromJson(json);
}

/// R2 Bucket model
@freezed
sealed class R2Bucket with _$R2Bucket {
  const factory R2Bucket({
    required String name,
    @JsonKey(name: 'creation_date') required DateTime creationDate,
    String? location,
  }) = _R2Bucket;

  factory R2Bucket.fromJson(Map<String, dynamic> json) =>
      _$R2BucketFromJson(json);
}

/// D1 Database model
@freezed
sealed class D1Database with _$D1Database {
  const factory D1Database({
    required String uuid,
    required String name,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    String? version,
    @JsonKey(name: 'file_size') int? fileSize,
  }) = _D1Database;

  factory D1Database.fromJson(Map<String, dynamic> json) =>
      _$D1DatabaseFromJson(json);
}
