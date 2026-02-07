import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'log_entry.dart';
import 'log_level.dart';

/// Singleton service for managing application logs
class LogService {
  LogService._();

  static final LogService instance = LogService._();

  /// Maximum number of logs to keep in memory
  static const int maxLogsInMemory = 1000;

  /// Maximum log file size in bytes (5MB)
  static const int maxLogFileSize = 5 * 1024 * 1024;

  final _logs = Queue<LogEntry>();
  final _logController = StreamController<LogEntry>.broadcast();

  bool _fileLoggingEnabled = false;
  File? _logFile;
  IOSink? _logFileSink;
  DateTime? _sessionStartTime;

  /// Stream of new log entries
  Stream<LogEntry> get logStream => _logController.stream;

  /// Get all logs as unmodifiable list
  List<LogEntry> get logs => List.unmodifiable(_logs.toList());

  /// Whether file logging is enabled
  bool get fileLoggingEnabled => _fileLoggingEnabled;

  /// Session start time
  DateTime get sessionStartTime => _sessionStartTime ?? DateTime.now();

  /// Initialize the log service
  Future<void> initialize() async {
    _sessionStartTime = DateTime.now();
    info('Log service initialized', category: LogCategory.debug);
  }

  /// Enable or disable file logging
  Future<void> setFileLoggingEnabled(bool enabled) async {
    if (enabled == _fileLoggingEnabled) return;

    _fileLoggingEnabled = enabled;

    if (enabled) {
      await _openLogFile();
      info('File logging enabled', category: LogCategory.debug);
    } else {
      await _closeLogFile();
      info('File logging disabled', category: LogCategory.debug);
    }
  }

  /// Log a debug message
  void debug(String message, {String? details}) {
    _log(LogLevel.debug, message, details: details, category: LogCategory.debug);
  }

  /// Log an info message
  void info(String message, {String? details, LogCategory category = LogCategory.debug}) {
    _log(LogLevel.info, message, details: details, category: category);
  }

  /// Log a warning message
  void warning(String message, {String? details, LogCategory category = LogCategory.debug}) {
    _log(LogLevel.warning, message, details: details, category: category);
  }

  /// Log an error message
  void error(String message, {String? details, Object? error, StackTrace? stackTrace}) {
    String? fullDetails = details;
    if (error != null) {
      fullDetails = '${details ?? ''}\nError: $error';
      if (stackTrace != null && kDebugMode) {
        fullDetails += '\nStack: $stackTrace';
      }
    }
    _log(LogLevel.error, message, details: fullDetails?.trim(), category: LogCategory.errors);
  }

  /// Log an API request
  void apiRequest(String method, String path, {Map<String, dynamic>? headers}) {
    final details = headers != null ? 'Headers: ${headers.keys.join(', ')}' : null;
    _log(LogLevel.api, '$method $path', details: details, category: LogCategory.api);
  }

  /// Log an API response
  void apiResponse(String method, String path, int statusCode, {int? durationMs, String? body}) {
    final buffer = StringBuffer();
    buffer.write('$statusCode');
    if (durationMs != null) {
      buffer.write(' (${durationMs}ms)');
    }
    String? details;
    if (body != null && body.length < 500) {
      details = 'Body: $body';
    } else if (body != null) {
      details = 'Body: ${body.substring(0, 500)}... (truncated)';
    }
    _log(LogLevel.api, '$method $path → ${buffer.toString()}', details: details, category: LogCategory.api);
  }

  /// Log an API error
  void apiError(String method, String path, {int? statusCode, String? error, String? body}) {
    final buffer = StringBuffer();
    if (statusCode != null) {
      buffer.write('$statusCode - ');
    }
    buffer.write(error ?? 'Unknown error');
    String? details;
    if (body != null && body.length < 500) {
      details = 'Body: $body';
    }
    _log(LogLevel.error, '$method $path → ${buffer.toString()}', details: details, category: LogCategory.api);
  }

  /// Log a state change
  void stateChange(String provider, String description) {
    _log(LogLevel.info, '$provider: $description', category: LogCategory.state);
  }

  /// Internal log method
  void _log(LogLevel level, String message, {String? details, LogCategory category = LogCategory.debug}) {
    // In release mode, skip debug logs
    if (!kDebugMode && level == LogLevel.debug) return;

    final entry = LogEntry(
      level: level,
      message: message,
      details: details,
      category: category,
    );

    // Add to memory queue
    _logs.addLast(entry);
    while (_logs.length > maxLogsInMemory) {
      _logs.removeFirst();
    }

    // Broadcast to listeners
    _logController.add(entry);

    // Write to file if enabled
    if (_fileLoggingEnabled && _logFileSink != null) {
      _logFileSink!.writeln(entry.toExportString());
    }

    // Also print to console in debug mode
    if (kDebugMode) {
      debugPrint(entry.toDisplayString());
    }
  }

  /// Get logs filtered by time range
  List<LogEntry> getLogsInRange(Duration duration) {
    final cutoff = DateTime.now().subtract(duration);
    return _logs.where((log) => log.timestamp.isAfter(cutoff)).toList();
  }

  /// Get logs filtered by category
  List<LogEntry> getLogsByCategory(LogCategory category) {
    if (category == LogCategory.all) return logs;
    return _logs.where((log) => log.category == category).toList();
  }

  /// Get logs filtered by both time range and category
  List<LogEntry> getFilteredLogs({Duration? timeRange, LogCategory? category}) {
    var filtered = _logs.toList();

    if (timeRange != null) {
      final cutoff = DateTime.now().subtract(timeRange);
      filtered = filtered.where((log) => log.timestamp.isAfter(cutoff)).toList();
    }

    if (category != null && category != LogCategory.all) {
      filtered = filtered.where((log) => log.category == category).toList();
    }

    return filtered;
  }

  /// Format logs for export/copy
  String formatLogsForExport(List<LogEntry> entries, {String? timeRangeLabel}) {
    final buffer = StringBuffer();
    buffer.writeln('=== Debug Logs${timeRangeLabel != null ? ' (last $timeRangeLabel)' : ''} ===');
    buffer.writeln('Session: ${sessionStartTime.toIso8601String()}');
    buffer.writeln('Platform: ${_getPlatform()}');
    buffer.writeln('Exported: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total entries: ${entries.length}');
    buffer.writeln('');

    for (final entry in entries) {
      buffer.writeln(entry.toExportString());
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isLinux) return 'linux';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    return 'unknown';
  }

  /// Clear all logs from memory
  void clear() {
    _logs.clear();
    info('Logs cleared', category: LogCategory.debug);
  }

  /// Open log file for writing
  Future<void> _openLogFile() async {
    if (kIsWeb) return; // No file logging on web

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // Rotate log files if needed
      await _rotateLogFiles(logDir);

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      _logFile = File('${logDir.path}/app_$timestamp.log');
      _logFileSink = _logFile!.openWrite(mode: FileMode.append);

      // Write header
      _logFileSink!.writeln('=== Log Session Started ===');
      _logFileSink!.writeln('Time: ${DateTime.now().toIso8601String()}');
      _logFileSink!.writeln('Platform: ${_getPlatform()}');
      _logFileSink!.writeln('===========================');
      _logFileSink!.writeln('');
    } catch (e) {
      debugPrint('Failed to open log file: $e');
    }
  }

  /// Close log file
  Future<void> _closeLogFile() async {
    if (_logFileSink != null) {
      _logFileSink!.writeln('');
      _logFileSink!.writeln('=== Log Session Ended ===');
      await _logFileSink!.flush();
      await _logFileSink!.close();
      _logFileSink = null;
      _logFile = null;
    }
  }

  /// Rotate old log files (keep last 7 days)
  Future<void> _rotateLogFiles(Directory logDir) async {
    try {
      final files = await logDir.list().toList();
      final cutoff = DateTime.now().subtract(const Duration(days: 7));

      // Also check total size
      int totalSize = 0;
      final logFiles = <File>[];

      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.log')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
          } else {
            logFiles.add(entity);
            totalSize += await entity.length();
          }
        }
      }

      // If total exceeds 20MB, delete oldest files
      if (totalSize > 20 * 1024 * 1024) {
        logFiles.sort(
          (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
        );
        for (final file in logFiles) {
          if (totalSize <= 10 * 1024 * 1024) break;
          totalSize -= await file.length();
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Failed to rotate log files: $e');
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    await _closeLogFile();
    await _logController.close();
  }
}

/// Global log helper functions
LogService get log => LogService.instance;
