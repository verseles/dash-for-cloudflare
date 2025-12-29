import 'log_level.dart';

/// Represents a single log entry
class LogEntry {
  LogEntry({
    required this.level,
    required this.message,
    this.details,
    this.category = LogCategory.debug,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? details;
  final LogCategory category;

  /// Format timestamp as HH:mm:ss
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Format timestamp as full ISO format
  String get formattedTimestamp {
    return timestamp.toIso8601String();
  }

  /// Format for display in the log list
  String toDisplayString() {
    final buffer = StringBuffer();
    buffer.write('[$formattedTime] [${level.label}] $message');
    if (details != null && details!.isNotEmpty) {
      buffer.write('\n  → $details');
    }
    return buffer.toString();
  }

  /// Format for copying/exporting
  String toExportString() {
    final buffer = StringBuffer();
    buffer.write('[$formattedTimestamp] [${level.label}] $message');
    if (details != null && details!.isNotEmpty) {
      // Indent multi-line details
      final indentedDetails = details!.split('\n').join('\n  ');
      buffer.write('\n  → $indentedDetails');
    }
    return buffer.toString();
  }

  @override
  String toString() => toDisplayString();
}
