import 'package:cf/features/workers/domain/models/worker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Worker Model', () {
    test('should create a Worker instance from JSON', () {
      final json = {
        'id': 'my-worker',
        'etag': 'abc123',
        'handlers': ['fetch', 'scheduled'],
        'created_on': '2024-01-01T00:00:00Z',
        'modified_on': '2024-06-15T10:30:00Z',
        'usage_model': 'bundled',
        'last_deployed_from': 'wrangler',
      };

      final worker = Worker.fromJson(json);

      expect(worker.id, 'my-worker');
      expect(worker.etag, 'abc123');
      expect(worker.handlers, ['fetch', 'scheduled']);
      expect(worker.createdOn, DateTime.parse('2024-01-01T00:00:00Z'));
      expect(worker.modifiedOn, DateTime.parse('2024-06-15T10:30:00Z'));
      expect(worker.usageModel, 'bundled');
      expect(worker.lastDeployedFrom, 'wrangler');
    });

    test('WorkerExtension should correctly identify handlers', () {
      final worker = Worker(
        id: 'test',
        handlers: ['fetch'],
        createdOn: DateTime.now(),
        modifiedOn: DateTime.now(),
      );

      expect(worker.hasFetchHandler, isTrue);
      expect(worker.hasScheduledHandler, isFalse);

      final worker2 = worker.copyWith(handlers: ['scheduled']);
      expect(worker2.hasFetchHandler, isFalse);
      expect(worker2.hasScheduledHandler, isTrue);
    });
  });
}
