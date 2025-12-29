import 'package:flutter/material.dart';

/// Log levels for the application
enum LogLevel {
  debug('DEBUG', Colors.purple, 0),
  info('INFO', Colors.grey, 1),
  api('API', Color(0xFFF38020), 2), // Cloudflare orange
  warning('WARN', Colors.orange, 3),
  error('ERROR', Colors.red, 4);

  const LogLevel(this.label, this.color, this.priority);

  final String label;
  final Color color;
  final int priority;
}

/// Log categories for filtering
enum LogCategory {
  all('All'),
  api('API'),
  errors('Errors'),
  state('State'),
  debug('Debug');

  const LogCategory(this.label);

  final String label;
}
