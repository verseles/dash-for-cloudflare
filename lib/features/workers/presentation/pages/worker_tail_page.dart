import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/models/worker.dart';
import '../../providers/worker_tail_provider.dart';
import '../../../../l10n/app_localizations.dart';

class WorkerTailPage extends ConsumerStatefulWidget {
  const WorkerTailPage({super.key, required this.worker});

  final Worker worker;

  @override
  ConsumerState<WorkerTailPage> createState() => _WorkerTailPageState();
}

class _WorkerTailPageState extends ConsumerState<WorkerTailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  String _filterLevel = 'all';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tailState = ref.watch(workerTailNotifierProvider(widget.worker.id));

    // Auto-scroll to bottom when new logs arrive
    if (_autoScroll && tailState.logs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }

    final filteredLogs = tailState.logs.where((log) {
      if (_filterLevel == 'all') return true;
      return log.level == _filterLevel;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workers_tail_title),
        actions: [
          // Filter
          PopupMenuButton<String>(
            icon: const Icon(Symbols.filter_list),
            initialValue: _filterLevel,
            onSelected: (value) => setState(() => _filterLevel = value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text(l10n.workers_tail_filterAll)),
              PopupMenuItem(value: 'log', child: Text(l10n.workers_tail_filterLog)),
              PopupMenuItem(value: 'warn', child: Text(l10n.workers_tail_filterWarn)),
              PopupMenuItem(value: 'error', child: Text(l10n.workers_tail_filterError)),
            ],
          ),
          // Auto-scroll toggle
          IconButton(
            icon: Icon(_autoScroll ? Symbols.vertical_align_bottom : Symbols.vertical_align_bottom, fill: _autoScroll ? 1 : 0),
            onPressed: () => setState(() => _autoScroll = !_autoScroll),
            tooltip: l10n.workers_tail_autoScroll,
          ),
          // Clear
          IconButton(
            icon: const Icon(Symbols.delete_sweep),
            onPressed: tailState.logs.isEmpty
                ? null
                : () => ref.read(workerTailNotifierProvider(widget.worker.id).notifier).clearLogs(),
            tooltip: l10n.workers_tail_clear,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Icon(
                  tailState.isConnected
                      ? Symbols.wifi
                      : tailState.isConnecting
                          ? Symbols.wifi_off
                          : Symbols.wifi_off,
                  color: tailState.isConnected
                      ? Colors.green
                      : tailState.isConnecting
                          ? Colors.orange
                          : Colors.grey,
                  fill: 1,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  tailState.isConnected
                      ? l10n.workers_tail_connected
                      : tailState.isConnecting
                          ? l10n.workers_tail_connecting
                          : l10n.workers_tail_disconnected,
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  l10n.workers_tail_logCount(filteredLogs.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          // Error banner
          if (tailState.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(Symbols.error, color: Colors.red, size: 20, fill: 1),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tailState.error!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),

          // Logs list
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Symbols.terminal, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          tailState.isConnected
                              ? l10n.workers_tail_noLogsYet
                              : l10n.workers_tail_notConnected,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildLogEntry(log, theme);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tailState.isConnected
            ? () => ref.read(workerTailNotifierProvider(widget.worker.id).notifier).stopTail()
            : () => ref.read(workerTailNotifierProvider(widget.worker.id).notifier).startTail(),
        icon: Icon(tailState.isConnected ? Symbols.stop : Symbols.play_arrow),
        label: Text(tailState.isConnected ? l10n.workers_tail_stop : l10n.workers_tail_start),
        backgroundColor: tailState.isConnected ? Colors.red : theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildLogEntry(dynamic log, ThemeData theme) {
    Color levelColor;
    IconData levelIcon;

    switch (log.level) {
      case 'error':
        levelColor = Colors.red;
        levelIcon = Symbols.error;
        break;
      case 'warn':
        levelColor = Colors.orange;
        levelIcon = Symbols.warning;
        break;
      default:
        levelColor = Colors.blue;
        levelIcon = Symbols.info;
    }

    final timestamp = DateTime.tryParse(log.timestamp)?.toLocal();
    final timeStr = timestamp != null
        ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}'
        : log.timestamp;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: levelColor, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(levelIcon, color: levelColor, size: 16, fill: 1),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              log.message.join(' '),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
