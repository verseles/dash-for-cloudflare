import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../domain/models/worker_tail.dart';
import '../../auth/providers/account_provider.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/logging/log_service.dart';
import '../../../core/logging/log_level.dart';

part 'worker_tail_provider.g.dart';

/// State for tail logs
class TailState {
  const TailState({
    this.logs = const [],
    this.isConnected = false,
    this.isConnecting = false,
    this.error,
    this.sessionId,
  });

  final List<TailLog> logs;
  final bool isConnected;
  final bool isConnecting;
  final String? error;
  final String? sessionId;

  TailState copyWith({
    List<TailLog>? logs,
    bool? isConnected,
    bool? isConnecting,
    String? error,
    String? sessionId,
  }) {
    return TailState(
      logs: logs ?? this.logs,
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

/// Provider for worker tail logs
@riverpod
class WorkerTailNotifier extends _$WorkerTailNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _currentSessionId;

  @override
  TailState build(String scriptName) {
    ref.onDispose(() {
      stopTail();
    });
    return const TailState();
  }

  /// Start tailing logs
  Future<void> startTail() async {
    if (state.isConnected || state.isConnecting) {
      log.warning('WorkerTailNotifier: Already connected or connecting');
      return;
    }

    final accountId = ref.read(selectedAccountIdProvider);
    if (accountId == null) {
      state = state.copyWith(error: 'No account selected');
      return;
    }

    state = state.copyWith(isConnecting: true, error: null);

    try {
      // Create tail session
      final api = ref.read(cloudflareApiProvider);
      final response = await api.createTail(accountId, scriptName);

      if (!response.success || response.result == null) {
        throw Exception('Failed to create tail session');
      }

      final session = response.result!;
      _currentSessionId = session.id;

      log.info('WorkerTailNotifier: Created tail session ${session.id}', category: LogCategory.state);

      // Connect to WebSocket
      final wsUrl = Uri.parse(session.url);
      _channel = WebSocketChannel.connect(wsUrl);

      // Listen to messages
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      state = state.copyWith(
        isConnected: true,
        isConnecting: false,
        sessionId: session.id,
      );
    } catch (e, stack) {
      log.error('WorkerTailNotifier: Failed to start tail', error: e, stackTrace: stack);
      state = state.copyWith(
        isConnecting: false,
        error: e.toString(),
      );
    }
  }

  /// Stop tailing logs
  Future<void> stopTail() async {
    if (!state.isConnected && !state.isConnecting) return;

    // Close WebSocket
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;

    // Delete tail session from API
    if (_currentSessionId != null) {
      final accountId = ref.read(selectedAccountIdProvider);
      if (accountId != null) {
        try {
          final api = ref.read(cloudflareApiProvider);
          await api.deleteTail(accountId, scriptName, _currentSessionId!);
          log.info('WorkerTailNotifier: Deleted tail session $_currentSessionId', category: LogCategory.state);
        } catch (e) {
          log.warning('WorkerTailNotifier: Failed to delete tail session', details: e.toString());
        }
      }
      _currentSessionId = null;
    }

    state = const TailState();
  }

  /// Clear logs
  void clearLogs() {
    state = state.copyWith(logs: []);
  }

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;

      // Tail messages come wrapped in an envelope
      if (json.containsKey('outcome')) {
        // This is a request log
        final timestamp = json['event']?['request']?['timestamp'] ?? DateTime.now().toIso8601String();
        final logs = json['logs'] as List<dynamic>? ?? [];
        final exceptions = json['exceptions'] as List<dynamic>? ?? [];

        // Create log entries from console.log statements
        for (final logItem in logs) {
          final logEntry = TailLog(
            timestamp: timestamp,
            level: logItem['level'] ?? 'log',
            message: logItem['message'] ?? [],
            event: json['event'] as Map<String, dynamic>?,
          );
          state = state.copyWith(logs: [...state.logs, logEntry]);
        }

        // Create log entries from exceptions
        for (final exception in exceptions) {
          final exceptionEntry = TailLog(
            timestamp: timestamp,
            level: 'error',
            message: [exception['name'] ?? 'Error', exception['message'] ?? ''],
            exceptions: exception as Map<String, dynamic>?,
          );
          state = state.copyWith(logs: [...state.logs, exceptionEntry]);
        }
      }
    } catch (e) {
      log.warning('WorkerTailNotifier: Failed to parse message', details: e.toString());
    }
  }

  void _onError(dynamic error) {
    log.error('WorkerTailNotifier: WebSocket error', error: error);
    state = state.copyWith(
      isConnected: false,
      error: error.toString(),
    );
  }

  void _onDone() {
    log.info('WorkerTailNotifier: WebSocket closed', category: LogCategory.state);
    state = state.copyWith(isConnected: false);
  }
}
