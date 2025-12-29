import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/dns/domain/models/dns_record.dart';

void main() {
  group('DnsRecord', () {
    group('fromJson', () {
      test('parses minimal DNS record', () {
        final json = {
          'id': 'rec123',
          'type': 'A',
          'name': 'www.example.com',
          'content': '192.168.1.1',
          'zone_id': 'zone123',
          'zone_name': 'example.com',
        };

        final record = DnsRecord.fromJson(json);

        expect(record.id, 'rec123');
        expect(record.type, 'A');
        expect(record.name, 'www.example.com');
        expect(record.content, '192.168.1.1');
        expect(record.zoneId, 'zone123');
        expect(record.zoneName, 'example.com');
        expect(record.proxied, false); // default
        expect(record.ttl, 1); // default (Auto)
      });

      test('parses full DNS record', () {
        final json = {
          'id': 'rec456',
          'type': 'MX',
          'name': 'example.com',
          'content': 'mail.example.com',
          'proxied': false,
          'ttl': 3600,
          'zone_id': 'zone123',
          'zone_name': 'example.com',
          'priority': 10,
          'created_on': '2024-01-01T00:00:00Z',
          'modified_on': '2024-06-01T00:00:00Z',
          'proxiable': false,
          'locked': false,
          'meta': {'auto_added': false},
        };

        final record = DnsRecord.fromJson(json);

        expect(record.id, 'rec456');
        expect(record.type, 'MX');
        expect(record.priority, 10);
        expect(record.ttl, 3600);
        expect(record.createdOn, '2024-01-01T00:00:00Z');
        expect(record.modifiedOn, '2024-06-01T00:00:00Z');
        expect(record.proxiable, false);
        expect(record.locked, false);
        expect(record.meta, isNotNull);
      });

      test('parses proxied A record', () {
        final json = {
          'id': 'rec789',
          'type': 'A',
          'name': 'cdn.example.com',
          'content': '1.2.3.4',
          'proxied': true,
          'ttl': 1,
          'zone_id': 'zone123',
          'zone_name': 'example.com',
          'proxiable': true,
        };

        final record = DnsRecord.fromJson(json);

        expect(record.proxied, true);
        expect(record.proxiable, true);
      });
    });

    group('toJson', () {
      test('serializes DNS record correctly', () {
        const record = DnsRecord(
          id: 'rec123',
          type: 'CNAME',
          name: 'blog.example.com',
          content: 'example.com',
          proxied: true,
          ttl: 1,
          zoneId: 'zone123',
          zoneName: 'example.com',
        );

        final json = record.toJson();

        expect(json['id'], 'rec123');
        expect(json['type'], 'CNAME');
        expect(json['name'], 'blog.example.com');
        expect(json['content'], 'example.com');
        expect(json['proxied'], true);
        expect(json['ttl'], 1);
        expect(json['zone_id'], 'zone123');
        expect(json['zone_name'], 'example.com');
      });

      test('serializes MX record with priority', () {
        const record = DnsRecord(
          id: 'rec123',
          type: 'MX',
          name: 'example.com',
          content: 'mail.example.com',
          zoneId: 'zone123',
          zoneName: 'example.com',
          priority: 10,
        );

        final json = record.toJson();

        expect(json['priority'], 10);
      });
    });

    group('copyWith', () {
      test('updates proxied status', () {
        const original = DnsRecord(
          id: 'rec123',
          type: 'A',
          name: 'www.example.com',
          content: '1.2.3.4',
          proxied: false,
          zoneId: 'zone123',
          zoneName: 'example.com',
        );

        final updated = original.copyWith(proxied: true);

        expect(updated.proxied, true);
        expect(updated.id, 'rec123');
        expect(updated.content, '1.2.3.4');
      });

      test('updates content and TTL', () {
        const original = DnsRecord(
          id: 'rec123',
          type: 'A',
          name: 'www.example.com',
          content: '1.2.3.4',
          ttl: 1,
          zoneId: 'zone123',
          zoneName: 'example.com',
        );

        final updated = original.copyWith(content: '5.6.7.8', ttl: 3600);

        expect(updated.content, '5.6.7.8');
        expect(updated.ttl, 3600);
      });
    });

    group('equality', () {
      test('equal records are equal', () {
        const record1 = DnsRecord(
          id: 'rec123',
          type: 'A',
          name: 'example.com',
          content: '1.2.3.4',
          zoneId: 'zone123',
          zoneName: 'example.com',
        );
        const record2 = DnsRecord(
          id: 'rec123',
          type: 'A',
          name: 'example.com',
          content: '1.2.3.4',
          zoneId: 'zone123',
          zoneName: 'example.com',
        );

        expect(record1, equals(record2));
      });
    });
  });

  group('DnsRecordCreate', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'A',
        'name': 'www',
        'content': '1.2.3.4',
        'proxied': true,
        'ttl': 1,
      };

      final record = DnsRecordCreate.fromJson(json);

      expect(record.type, 'A');
      expect(record.name, 'www');
      expect(record.content, '1.2.3.4');
      expect(record.proxied, true);
      expect(record.ttl, 1);
    });

    test('toJson serializes correctly', () {
      const record = DnsRecordCreate(
        type: 'MX',
        name: '@',
        content: 'mail.example.com',
        priority: 10,
        ttl: 3600,
      );

      final json = record.toJson();

      expect(json['type'], 'MX');
      expect(json['name'], '@');
      expect(json['content'], 'mail.example.com');
      expect(json['priority'], 10);
      expect(json['ttl'], 3600);
    });

    test('defaults are correct', () {
      const record = DnsRecordCreate(
        type: 'TXT',
        name: '@',
        content: 'v=spf1 include:example.com ~all',
      );

      expect(record.proxied, false);
      expect(record.ttl, 1);
      expect(record.priority, isNull);
    });
  });
}
