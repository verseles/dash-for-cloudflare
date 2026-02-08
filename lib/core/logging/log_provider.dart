import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'log_entry.dart';
import 'log_level.dart';
import 'log_service.dart';

part 'log_provider.g.dart';

/// Time range options for log filtering
enum LogTimeRange {
  oneMinute(Duration(minutes: 1), '1m'),
  fiveMinutes(Duration(minutes: 5), '5m'),
  fifteenMinutes(Duration(minutes: 15), '15m'),
  thirtyMinutes(Duration(minutes: 30), '30m'),
  all(null, 'All');

  const LogTimeRange(this.duration, this.label);

  final Duration? duration;
  final String label;
}

/// State for the log viewer
class LogViewerState {
  const LogViewerState({
    this.logs = const [],
    this.timeRange = LogTimeRange.fiveMinutes,
    this.category = LogCategory.all,
    this.searchQuery = '',
  });

  final List<LogEntry> logs;
  final LogTimeRange timeRange;
  final LogCategory category;
  final String searchQuery;

  LogViewerState copyWith({
    List<LogEntry>? logs,
    LogTimeRange? timeRange,
    LogCategory? category,
    String? searchQuery,
  }) {
    return LogViewerState(
      logs: logs ?? this.logs,
      timeRange: timeRange ?? this.timeRange,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Provider for log viewer state
@riverpod
class LogViewer extends _$LogViewer {
  @override
  LogViewerState build() {
    // Listen to new logs
    final subscription = LogService.instance.logStream.listen((_) {
      _refreshLogs();
    });

    // Clean up on dispose
    ref.onDispose(() {
      subscription.cancel();
    });

    // Initial load
    return LogViewerState(
      logs: _getFilteredLogs(
        LogTimeRange.fiveMinutes,
        LogCategory.all,
        '',
      ),
    );
  }

  List<LogEntry> _getFilteredLogs(
    LogTimeRange timeRange,
    LogCategory category,
    String searchQuery,
  ) {
    return LogService.instance.getFilteredLogs(
      timeRange: timeRange.duration,
      category: category,
      searchQuery: searchQuery,
    );
  }

  void _refreshLogs() {
    state = state.copyWith(
      logs: _getFilteredLogs(
        state.timeRange,
        state.category,
        state.searchQuery,
      ),
    );
  }

  /// Set the time range filter
  void setTimeRange(LogTimeRange timeRange) {
    state = state.copyWith(
      timeRange: timeRange,
      logs: _getFilteredLogs(
        timeRange,
        state.category,
        state.searchQuery,
      ),
    );
  }

  /// Set the category filter
  void setCategory(LogCategory category) {
    state = state.copyWith(
      category: category,
      logs: _getFilteredLogs(
        state.timeRange,
        category,
        state.searchQuery,
      ),
    );
  }

  /// Set the search query
  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      logs: _getFilteredLogs(
        state.timeRange,
        state.category,
        query,
      ),
    );
  }

  /// Clear all logs
  void clearLogs() {
    LogService.instance.clear();
    state = state.copyWith(logs: []);
  }

  /// Get formatted logs for export
  String getLogsForExport() {
    return LogService.instance.formatLogsForExport(
      state.logs,
      timeRangeLabel: state.timeRange.label,
    );
  }

  /// Refresh logs manually
  void refresh() {
    _refreshLogs();
  }
}

/// Provider for file logging enabled state
@riverpod
class FileLoggingEnabled extends _$FileLoggingEnabled {
  @override
  bool build() {
    return LogService.instance.fileLoggingEnabled;
  }

  Future<void> toggle() async {
    final newValue = !state;
    await LogService.instance.setFileLoggingEnabled(newValue);
    state = newValue;
  }

  Future<void> setEnabled(bool enabled) async {
    await LogService.instance.setFileLoggingEnabled(enabled);
    state = enabled;
  }
}
