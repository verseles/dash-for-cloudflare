import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/dns/domain/models/zone.dart';
import 'package:cf/features/dns/providers/zone_provider.dart';

void main() {
  group('ZonesState', () {
    const testZones = [
      Zone(id: 'zone1', name: 'example.com', status: 'active'),
      Zone(id: 'zone2', name: 'test.org', status: 'pending'),
    ];

    group('constructor', () {
      test('default constructor creates empty state', () {
        const state = ZonesState();

        expect(state.zones, isEmpty);
        expect(state.isFromCache, isFalse);
        expect(state.isRefreshing, isFalse);
        expect(state.cachedAt, isNull);
      });

      test('constructor with all parameters', () {
        final cachedTime = DateTime.now();
        final state = ZonesState(
          zones: testZones,
          isFromCache: true,
          isRefreshing: false,
          cachedAt: cachedTime,
        );

        expect(state.zones, equals(testZones));
        expect(state.isFromCache, isTrue);
        expect(state.isRefreshing, isFalse);
        expect(state.cachedAt, equals(cachedTime));
      });
    });

    group('copyWith', () {
      test('updates zones while preserving other fields', () {
        final original = ZonesState(
          zones: testZones,
          isFromCache: true,
          cachedAt: DateTime.now(),
        );
        const newZones = [Zone(id: 'zone3', name: 'new.com', status: 'active')];

        final updated = original.copyWith(zones: newZones);

        expect(updated.zones, equals(newZones));
        expect(updated.isFromCache, equals(original.isFromCache));
        expect(updated.cachedAt, equals(original.cachedAt));
      });

      test('updates isRefreshing flag', () {
        const original = ZonesState(zones: testZones);

        final refreshing = original.copyWith(isRefreshing: true);

        expect(refreshing.isRefreshing, isTrue);
        expect(refreshing.zones, equals(testZones));
      });

      test('updates isFromCache flag', () {
        const original = ZonesState(isFromCache: false);

        final fromCache = original.copyWith(isFromCache: true);

        expect(fromCache.isFromCache, isTrue);
      });

      test('updates cachedAt timestamp', () {
        const original = ZonesState();
        final newTime = DateTime.now();

        final updated = original.copyWith(cachedAt: newTime);

        expect(updated.cachedAt, equals(newTime));
      });
    });

    group('cache behavior', () {
      test('state with cachedAt tracks when data was cached', () {
        final cacheTime = DateTime(2024, 6, 15, 10, 30);
        final state = ZonesState(
          zones: testZones,
          isFromCache: true,
          cachedAt: cacheTime,
        );

        expect(state.cachedAt, equals(cacheTime));
        expect(state.isFromCache, isTrue);
      });

      test('refreshing state indicates background refresh in progress', () {
        final state = ZonesState(
          zones: testZones,
          isFromCache: true,
          isRefreshing: true,
          cachedAt: DateTime.now(),
        );

        expect(state.isRefreshing, isTrue);
        expect(state.zones, isNotEmpty);
      });
    });
  });
}
