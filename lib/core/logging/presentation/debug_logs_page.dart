import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../log_entry.dart';
import '../log_level.dart';
import '../log_provider.dart';

/// Page for viewing and exporting debug logs
class DebugLogsPage extends ConsumerStatefulWidget {
  const DebugLogsPage({super.key});

  @override
  ConsumerState<DebugLogsPage> createState() => _DebugLogsPageState();
}

class _DebugLogsPageState extends ConsumerState<DebugLogsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _copyLogs(String logs) async {
    await Clipboard.setData(ClipboardData(text: logs));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logs copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveToFile(String logs) async {
    if (kIsWeb) {
      // Web doesn't support file saving the same way
      await _copyLogs(logs);
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/debug_logs_$timestamp.txt');
      await file.writeAsString(logs);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to ${file.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareAsText(String logs) async {
    await Share.share(logs, subject: 'Debug Logs');
  }

  Future<void> _shareAsFile(String logs) async {
    if (kIsWeb) {
      // Fallback to text sharing on web
      await _shareAsText(logs);
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/debug_logs_$timestamp.txt');
      await file.writeAsString(logs);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Debug Logs',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logState = ref.watch(logViewerProvider);

    // Auto-scroll when new logs arrive
    ref.listen(logViewerProvider, (previous, next) {
      if (_autoScroll && next.logs.length > (previous?.logs.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(
            icon: Icon(_autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_center),
            tooltip: _autoScroll ? 'Auto-scroll ON' : 'Auto-scroll OFF',
            onPressed: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
              if (_autoScroll) {
                _scrollToBottom();
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              final logs = ref.read(logViewerProvider.notifier).getLogsForExport();
              switch (value) {
                case 'clear':
                  ref.read(logViewerProvider.notifier).clearLogs();
                  break;
                case 'copy_all':
                  _copyLogs(logs);
                  break;
                case 'save_file':
                  _saveToFile(logs);
                  break;
                case 'share_file':
                  _shareAsFile(logs);
                  break;
                case 'share_text':
                  _shareAsText(logs);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy_all',
                child: ListTile(
                  leading: Icon(Icons.copy_all),
                  title: Text('Copy All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (!kIsWeb)
                const PopupMenuItem(
                  value: 'save_file',
                  child: ListTile(
                    leading: Icon(Icons.save),
                    title: Text('Save to File'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'share_text',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share as Text'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (!kIsWeb)
                const PopupMenuItem(
                  value: 'share_file',
                  child: ListTile(
                    leading: Icon(Icons.attach_file),
                    title: Text('Share as File'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Clear Logs', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar with filters
          _buildToolbar(context, logState),
          const Divider(height: 1),
          // Log list
          Expanded(
            child: logState.logs.isEmpty
                ? _buildEmptyState(context)
                : _buildLogList(context, logState.logs),
          ),
          // Bottom action bar
          _buildBottomBar(context, logState),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, LogViewerState logState) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time range selector
          Row(
            children: [
              Text(
                'Time Range:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<LogTimeRange>(
                  segments: LogTimeRange.values
                      .map((range) => ButtonSegment(
                            value: range,
                            label: Text(range.label),
                          ))
                      .toList(),
                  selected: {logState.timeRange},
                  onSelectionChanged: (selection) {
                    ref.read(logViewerProvider.notifier).setTimeRange(selection.first);
                  },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Category filter
          Row(
            children: [
              Text(
                'Filter:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LogCategory.values.map((category) {
                      final isSelected = logState.category == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.label),
                          selected: isSelected,
                          onSelected: (_) {
                            ref.read(logViewerProvider.notifier).setCategory(category);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(BuildContext context, List<LogEntry> logs) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: logs.length,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final log = logs[index];
        return _LogEntryTile(entry: log);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No logs in this time range',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a longer time range',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, LogViewerState logState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${logState.logs.length} entries',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          FilledButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: Text('Copy ${logState.timeRange.label}'),
            onPressed: logState.logs.isEmpty
                ? null
                : () {
                    final logs = ref.read(logViewerProvider.notifier).getLogsForExport();
                    _copyLogs(logs);
                  },
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a single log entry
class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});

  final LogEntry entry;

  String _formatForCopy() {
    final buffer = StringBuffer();
    buffer.writeln('[${entry.formattedTime}] [${entry.level.label}] ${entry.message}');
    if (entry.details != null && entry.details!.isNotEmpty) {
      buffer.writeln('  → ${entry.details}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: _formatForCopy()));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log entry copied'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: entry.level == LogLevel.error
            ? Colors.red.withValues(alpha: isDark ? 0.2 : 0.1)
            : entry.level == LogLevel.warning
                ? Colors.orange.withValues(alpha: isDark ? 0.2 : 0.1)
                : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Timestamp
              Text(
                entry.formattedTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 8),
              // Level badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: entry.level.color.withValues(alpha: isDark ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.level.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: entry.level.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Message
              Expanded(
                child: Text(
                  entry.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (entry.details != null && entry.details!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '→ ${entry.details}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.outline,
                  fontSize: 11,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}
