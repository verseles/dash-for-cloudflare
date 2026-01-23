import 'package:cf/features/workers/domain/models/worker_route.dart';
import 'package:cf/features/workers/domain/models/worker_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkerRoute Model', () {
    test('should create a WorkerRoute instance from JSON', () {
      final json = {
        'id': 'route-123',
        'pattern': 'example.com/*',
        'script': 'my-worker',
        'request_limit_fail_open': true
      };

      final route = WorkerRoute.fromJson(json);

      expect(route.id, 'route-123');
      expect(route.pattern, 'example.com/*');
      expect(route.script, 'my-worker');
      expect(route.requestLimitFailOpen, isTrue);
    });
  });

  group('WorkerSchedule Model', () {
    test('should create a WorkerSchedule instance from JSON', () {
      final json = {
        'cron': '*/5 * * * *',
        'created_on': '2024-01-01T00:00:00Z'
      };

      final schedule = WorkerSchedule.fromJson(json);

      expect(schedule.cron, '*/5 * * * *');
      expect(schedule.createdOn, DateTime.parse('2024-01-01T00:00:00Z'));
    });

    test('should create a WorkerSchedulesResponse from JSON', () {
      final json = {
        'schedules': [
          {'cron': '0 0 * * *'}
        ]
      };

      final response = WorkerSchedulesResponse.fromJson(json);
      expect(response.schedules.length, 1);
      expect(response.schedules[0].cron, '0 0 * * *');
    });
  });
}
