import 'package:freezed_annotation/freezed_annotation.dart';

part 'deployment_log.freezed.dart';
part 'deployment_log.g.dart';

/// Response wrapper for deployment logs API
/// The API returns: { result: { data: [...], total: N, includes_container_logs: bool } }
@freezed
sealed class DeploymentLogsResponse with _$DeploymentLogsResponse {
  const factory DeploymentLogsResponse({
    @Default([]) List<DeploymentLogEntry> data,
    @Default(0) int total,
    @JsonKey(name: 'includes_container_logs')
    @Default(false)
    bool includesContainerLogs,
  }) = _DeploymentLogsResponse;

  factory DeploymentLogsResponse.fromJson(Map<String, dynamic> json) =>
      _$DeploymentLogsResponseFromJson(json);
}

/// A single log entry from the build process
@freezed
sealed class DeploymentLogEntry with _$DeploymentLogEntry {
  const DeploymentLogEntry._();

  const factory DeploymentLogEntry({
    /// The log line content
    required String line,

    /// Timestamp in ISO 8601 format
    @JsonKey(name: 'ts') required String timestamp,
  }) = _DeploymentLogEntry;

  factory DeploymentLogEntry.fromJson(Map<String, dynamic> json) =>
      _$DeploymentLogEntryFromJson(json);

  /// Parse timestamp to DateTime
  DateTime get dateTime => DateTime.parse(timestamp);

  /// Check if this is an error line
  bool get isError =>
      line.toLowerCase().contains('error') ||
      line.toLowerCase().contains('failed') ||
      line.toLowerCase().contains('fatal');

  /// Check if this is a warning line
  bool get isWarning =>
      line.toLowerCase().contains('warning') ||
      line.toLowerCase().contains('warn');

  /// Check if this is a success/completion line
  bool get isSuccess =>
      line.toLowerCase().contains('success') ||
      line.toLowerCase().contains('completed') ||
      line.toLowerCase().contains('done');
}
