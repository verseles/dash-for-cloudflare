import 'package:cf/features/workers/domain/models/worker_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Worker Analytics Models', () {
    test('should create WorkerAnalyticsData and WorkerTimeSeries from JSON', () {
      final json = {
        'timeSeries': [
          {
            'timestamp': '2024-01-01T00:00:00Z',
            'requests': 100,
            'errors': 5,
            'cpuTimeMax': 15
          }
        ]
      };

      final data = WorkerAnalyticsData.fromJson(json);

      expect(data.timeSeries.length, 1);
      expect(data.timeSeries[0].timestamp, '2024-01-01T00:00:00Z');
      expect(data.timeSeries[0].requests, 100);
      expect(data.timeSeries[0].errors, 5);
      expect(data.timeSeries[0].cpuTimeMax, 15);
    });
  });
}
