import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_tail.freezed.dart';
part 'worker_tail.g.dart';

/// Tail session response from API
@freezed
sealed class TailSession with _$TailSession {
  const factory TailSession({
    required String id,
    required String url,
    @JsonKey(name: 'expires_at') required String expiresAt,
  }) = _TailSession;

  factory TailSession.fromJson(Map<String, dynamic> json) =>
      _$TailSessionFromJson(json);
}

/// Log entry from tail WebSocket
@freezed
sealed class TailLog with _$TailLog {
  const factory TailLog({
    required String timestamp,
    required String level,
    required List<dynamic> message,
    Map<String, dynamic>? event,
    Map<String, dynamic>? logs,
    Map<String, dynamic>? exceptions,
  }) = _TailLog;

  factory TailLog.fromJson(Map<String, dynamic> json) =>
      _$TailLogFromJson(json);
}
