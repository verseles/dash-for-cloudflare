import 'package:cf/core/logging/log_level.dart';
import 'package:cf/core/logging/log_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogService Filtering', () {
    late LogService logService;

    setUp(() async {
      logService = LogService.instance;
      logService.clear();

      // Seed some logs
      logService.info('User logged in', category: LogCategory.debug);
      logService.error('Connection failed', details: 'Timeout after 30s');
      logService.apiResponse('GET', '/zones', 200, body: '{"success": true}'); // Will log: GET /zones → 200
      logService.debug('Cache hit');
    });

    test('Filter by search query - message match', () {
      final logs = logService.getFilteredLogs(searchQuery: 'User');
      expect(logs.length, 1);
      expect(logs.first.message, 'User logged in');
    });

    test('Filter by search query - details match', () {
      final logs = logService.getFilteredLogs(searchQuery: 'Timeout');
      expect(logs.length, 1);
      expect(logs.first.message, 'Connection failed');
    });

    test('Filter by search query - case insensitive', () {
      final logs = logService.getFilteredLogs(searchQuery: 'connection');
      expect(logs.length, 1);
      expect(logs.first.message, 'Connection failed');
    });

    test('Filter by search query - no match', () {
      final logs = logService.getFilteredLogs(searchQuery: 'NotFoundQuery');
      expect(logs, isEmpty);
    });

    test('Filter by search query - empty query returns all', () {
      final logs = logService.getFilteredLogs(searchQuery: '');
      expect(logs.length, 5);
    });

    test('Filter by category and search query', () {
      final logs = logService.getFilteredLogs(
        category: LogCategory.api,
        searchQuery: 'zones',
      );
      expect(logs.length, 1);
      expect(logs.first.message, contains('GET /zones'));
    });
  });
}
