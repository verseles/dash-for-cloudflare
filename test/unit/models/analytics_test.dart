import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/analytics/domain/models/analytics.dart';

void main() {
  group('DnsAnalyticsData', () {
    test('fromJson parses empty analytics', () {
      final json = <String, dynamic>{};

      final analytics = DnsAnalyticsData.fromJson(json);

      expect(analytics.total, 0);
      expect(analytics.timeSeries, isEmpty);
      expect(analytics.byQueryName, isEmpty);
      expect(analytics.byQueryType, isEmpty);
      expect(analytics.byResponseCode, isEmpty);
      expect(analytics.byDataCenter, isEmpty);
      expect(analytics.byIpVersion, isEmpty);
      expect(analytics.byProtocol, isEmpty);
    });

    test('fromJson parses full analytics', () {
      final json = {
        'total': 1000,
        'timeSeries': [
          {'timestamp': '2024-01-01T00:00:00Z', 'count': 100},
          {'timestamp': '2024-01-01T01:00:00Z', 'count': 200},
        ],
        'byQueryName': [
          {
            'count': 500,
            'dimensions': {'queryName': 'example.com'},
          },
        ],
        'avgProcessingTime': 15.5,
        'avgQps': 2.5,
      };

      final analytics = DnsAnalyticsData.fromJson(json);

      expect(analytics.total, 1000);
      expect(analytics.timeSeries.length, 2);
      expect(analytics.timeSeries[0].timestamp, '2024-01-01T00:00:00Z');
      expect(analytics.timeSeries[0].count, 100);
      expect(analytics.byQueryName.length, 1);
      expect(analytics.avgProcessingTime, 15.5);
      expect(analytics.avgQps, 2.5);
    });

    test('toJson serializes correctly', () {
      const analytics = DnsAnalyticsData(
        total: 500,
        avgQps: 1.5,
        timeSeries: [
          AnalyticsTimeSeries(timestamp: '2024-01-01T00:00:00Z', count: 100),
        ],
      );

      final json = analytics.toJson();

      expect(json['total'], 500);
      expect(json['avgQps'], 1.5);
      expect(json['timeSeries'], isNotEmpty);
    });

    test('copyWith updates fields', () {
      const original = DnsAnalyticsData(total: 100);

      final updated = original.copyWith(total: 200, avgQps: 5.0);

      expect(updated.total, 200);
      expect(updated.avgQps, 5.0);
    });
  });

  group('AnalyticsTimeSeries', () {
    test('fromJson parses correctly', () {
      final json = {
        'timestamp': '2024-06-15T12:00:00Z',
        'count': 150,
        'queryName': 'api.example.com',
      };

      final series = AnalyticsTimeSeries.fromJson(json);

      expect(series.timestamp, '2024-06-15T12:00:00Z');
      expect(series.count, 150);
      expect(series.queryName, 'api.example.com');
    });

    test('fromJson without queryName', () {
      final json = {'timestamp': '2024-06-15T12:00:00Z', 'count': 100};

      final series = AnalyticsTimeSeries.fromJson(json);

      expect(series.queryName, isNull);
    });

    test('toJson serializes correctly', () {
      const series = AnalyticsTimeSeries(
        timestamp: '2024-06-15T12:00:00Z',
        count: 200,
      );

      final json = series.toJson();

      expect(json['timestamp'], '2024-06-15T12:00:00Z');
      expect(json['count'], 200);
    });
  });

  group('AnalyticsGroup', () {
    test('fromJson parses query type group', () {
      final json = {
        'count': 300,
        'dimensions': {'queryType': 'A'},
      };

      final group = AnalyticsGroup.fromJson(json);

      expect(group.count, 300);
      expect(group.dimensions['queryType'], 'A');
    });

    test('fromJson parses data center group', () {
      final json = {
        'count': 150,
        'dimensions': {'coloName': 'GRU'},
      };

      final group = AnalyticsGroup.fromJson(json);

      expect(group.count, 150);
      expect(group.dimensions['coloName'], 'GRU');
    });

    test('toJson serializes correctly', () {
      const group = AnalyticsGroup(
        count: 500,
        dimensions: {'responseCode': 'NOERROR'},
      );

      final json = group.toJson();

      expect(json['count'], 500);
      expect(json['dimensions']['responseCode'], 'NOERROR');
    });
  });

  group('DataCenterInfo', () {
    test('fromJson parses correctly', () {
      final json = {
        'iata': 'GRU',
        'place': 'Sao Paulo, Brazil',
        'lat': -23.5505,
        'lng': -46.6333,
      };

      final dc = DataCenterInfo.fromJson(json);

      expect(dc.iata, 'GRU');
      expect(dc.place, 'Sao Paulo, Brazil');
      expect(dc.lat, -23.5505);
      expect(dc.lng, -46.6333);
    });

    test('toJson serializes correctly', () {
      const dc = DataCenterInfo(
        iata: 'SFO',
        place: 'San Francisco, USA',
        lat: 37.7749,
        lng: -122.4194,
      );

      final json = dc.toJson();

      expect(json['iata'], 'SFO');
      expect(json['place'], 'San Francisco, USA');
      expect(json['lat'], 37.7749);
      expect(json['lng'], -122.4194);
    });

    test('equality works correctly', () {
      const dc1 = DataCenterInfo(
        iata: 'LAX',
        place: 'Los Angeles, USA',
        lat: 34.0522,
        lng: -118.2437,
      );
      const dc2 = DataCenterInfo(
        iata: 'LAX',
        place: 'Los Angeles, USA',
        lat: 34.0522,
        lng: -118.2437,
      );

      expect(dc1, equals(dc2));
    });
  });
}
