import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/dns/domain/models/zone.dart';

void main() {
  group('Zone', () {
    group('fromJson', () {
      test('parses zone without registrar', () {
        final json = {
          'id': 'zone123',
          'name': 'example.com',
          'status': 'active',
        };

        final zone = Zone.fromJson(json);

        expect(zone.id, 'zone123');
        expect(zone.name, 'example.com');
        expect(zone.status, 'active');
        expect(zone.registrar, isNull);
      });

      test('parses zone with registrar', () {
        final json = {
          'id': 'zone456',
          'name': 'test.org',
          'status': 'pending',
          'registrar': {'id': 'reg123', 'name': 'cloudflare'},
        };

        final zone = Zone.fromJson(json);

        expect(zone.id, 'zone456');
        expect(zone.name, 'test.org');
        expect(zone.status, 'pending');
        expect(zone.registrar, isNotNull);
        expect(zone.registrar!.id, 'reg123');
        expect(zone.registrar!.name, 'cloudflare');
      });
    });

    group('toJson', () {
      test('serializes zone without registrar', () {
        const zone = Zone(id: 'zone123', name: 'example.com', status: 'active');

        final json = zone.toJson();

        expect(json['id'], 'zone123');
        expect(json['name'], 'example.com');
        expect(json['status'], 'active');
        expect(json['registrar'], isNull);
      });

      test('serializes zone with registrar', () {
        const zone = Zone(
          id: 'zone456',
          name: 'test.org',
          status: 'pending',
          registrar: ZoneRegistrar(id: 'reg123', name: 'cloudflare'),
        );

        final json = zone.toJson();

        expect(json['id'], 'zone456');
        expect(json['name'], 'test.org');
        expect(json['status'], 'pending');
        expect(json['registrar'], isNotNull);
        // Freezed toJson puts the registrar object (not serialized map)
        // The nested object needs its own toJson() call for full serialization
        final registrar = json['registrar'] as ZoneRegistrar;
        expect(registrar.id, 'reg123');
        expect(registrar.name, 'cloudflare');
      });
    });

    group('copyWith', () {
      test('creates new zone with updated fields', () {
        const original = Zone(
          id: 'zone123',
          name: 'example.com',
          status: 'active',
        );

        final updated = original.copyWith(status: 'pending');

        expect(updated.id, 'zone123');
        expect(updated.name, 'example.com');
        expect(updated.status, 'pending');
      });

      test('adds registrar to zone', () {
        const original = Zone(
          id: 'zone123',
          name: 'example.com',
          status: 'active',
        );

        final updated = original.copyWith(
          registrar: const ZoneRegistrar(id: 'reg1', name: 'cloudflare'),
        );

        expect(updated.registrar, isNotNull);
        expect(updated.registrar!.name, 'cloudflare');
      });
    });

    group('equality', () {
      test('equal zones are equal', () {
        const zone1 = Zone(
          id: 'zone123',
          name: 'example.com',
          status: 'active',
        );
        const zone2 = Zone(
          id: 'zone123',
          name: 'example.com',
          status: 'active',
        );

        expect(zone1, equals(zone2));
        expect(zone1.hashCode, equals(zone2.hashCode));
      });

      test('different zones are not equal', () {
        const zone1 = Zone(
          id: 'zone123',
          name: 'example.com',
          status: 'active',
        );
        const zone2 = Zone(
          id: 'zone456',
          name: 'example.com',
          status: 'active',
        );

        expect(zone1, isNot(equals(zone2)));
      });
    });
  });

  group('ZoneRegistrar', () {
    test('fromJson parses correctly', () {
      final json = {'id': 'reg123', 'name': 'namecheap'};

      final registrar = ZoneRegistrar.fromJson(json);

      expect(registrar.id, 'reg123');
      expect(registrar.name, 'namecheap');
    });

    test('toJson serializes correctly', () {
      const registrar = ZoneRegistrar(id: 'reg123', name: 'cloudflare');

      final json = registrar.toJson();

      expect(json['id'], 'reg123');
      expect(json['name'], 'cloudflare');
    });
  });
}
