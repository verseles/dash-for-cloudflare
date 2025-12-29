import 'package:freezed_annotation/freezed_annotation.dart';

part 'zone.freezed.dart';
part 'zone.g.dart';

@freezed
sealed class Zone with _$Zone {
  const factory Zone({
    required String id,
    required String name,
    required String status,
    ZoneRegistrar? registrar,
  }) = _Zone;

  factory Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);
}

@freezed
sealed class ZoneRegistrar with _$ZoneRegistrar {
  const factory ZoneRegistrar({required String id, required String name}) =
      _ZoneRegistrar;

  factory ZoneRegistrar.fromJson(Map<String, dynamic> json) =>
      _$ZoneRegistrarFromJson(json);
}
