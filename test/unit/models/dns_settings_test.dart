import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/dns/domain/models/dns_settings.dart';

void main() {
  group('DnsSetting', () {
    test('fromJson parses boolean value', () {
      final json = {
        'id': 'cname_flattening',
        'value': true,
        'editable': true,
        'modified_on': '2024-01-01T00:00:00Z',
      };

      final setting = DnsSetting.fromJson(json);

      expect(setting.id, 'cname_flattening');
      expect(setting.value, true);
      expect(setting.editable, true);
      expect(setting.modifiedOn, '2024-01-01T00:00:00Z');
    });

    test('fromJson parses string value', () {
      final json = {'id': 'ssl', 'value': 'full', 'editable': false};

      final setting = DnsSetting.fromJson(json);

      expect(setting.id, 'ssl');
      expect(setting.value, 'full');
      expect(setting.editable, false);
    });

    test('defaults editable to true', () {
      final json = {'id': 'test', 'value': 'something'};

      final setting = DnsSetting.fromJson(json);

      expect(setting.editable, true);
    });

    test('toJson serializes correctly', () {
      const setting = DnsSetting(
        id: 'always_online',
        value: 'on',
        editable: true,
      );

      final json = setting.toJson();

      expect(json['id'], 'always_online');
      expect(json['value'], 'on');
      expect(json['editable'], true);
    });
  });

  group('DnsZoneSettings', () {
    test('fromJson parses multi_provider', () {
      final json = {'multi_provider': true};

      final settings = DnsZoneSettings.fromJson(json);

      expect(settings.multiProvider, true);
    });

    test('defaults multiProvider to false', () {
      final json = <String, dynamic>{};

      final settings = DnsZoneSettings.fromJson(json);

      expect(settings.multiProvider, false);
    });

    test('toJson serializes correctly', () {
      const settings = DnsZoneSettings(multiProvider: true);

      final json = settings.toJson();

      expect(json['multi_provider'], true);
    });
  });

  group('DnssecDetails', () {
    test('fromJson parses disabled status', () {
      final json = {'status': 'disabled'};

      final dnssec = DnssecDetails.fromJson(json);

      expect(dnssec.status, 'disabled');
      expect(dnssec.ds, isNull);
      expect(dnssec.algorithm, isNull);
    });

    test('fromJson parses active status with all fields', () {
      final json = {
        'status': 'active',
        'dnssec_multi_signer': false,
        'algorithm': '13',
        'digest': 'ABC123DEF456',
        'digest_algorithm': 'SHA-256',
        'digest_type': '2',
        'ds': 'example.com. 3600 IN DS 2371 13 2 ABC123DEF456',
        'flags': 257,
        'key_tag': 2371,
        'key_type': 'ECDSAP256SHA256',
        'modified_on': '2024-06-01T00:00:00Z',
        'public_key':
            'mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==',
      };

      final dnssec = DnssecDetails.fromJson(json);

      expect(dnssec.status, 'active');
      expect(dnssec.dnssecMultiSigner, false);
      expect(dnssec.algorithm, '13');
      expect(dnssec.digest, 'ABC123DEF456');
      expect(dnssec.digestAlgorithm, 'SHA-256');
      expect(dnssec.digestType, '2');
      expect(dnssec.ds, isNotNull);
      expect(dnssec.flags, 257);
      expect(dnssec.keyTag, 2371);
      expect(dnssec.keyType, 'ECDSAP256SHA256');
      expect(dnssec.publicKey, isNotNull);
    });

    test('fromJson parses pending status', () {
      final json = {
        'status': 'pending',
        'ds': 'example.com. 3600 IN DS 2371 13 2 ABC123DEF456',
        'key_tag': 2371,
      };

      final dnssec = DnssecDetails.fromJson(json);

      expect(dnssec.status, 'pending');
      expect(dnssec.ds, isNotNull);
    });

    test('toJson serializes correctly', () {
      const dnssec = DnssecDetails(
        status: 'active',
        dnssecMultiSigner: true,
        algorithm: '13',
        keyTag: 2371,
      );

      final json = dnssec.toJson();

      expect(json['status'], 'active');
      expect(json['dnssec_multi_signer'], true);
      expect(json['algorithm'], '13');
      expect(json['key_tag'], 2371);
    });

    test('copyWith updates status', () {
      const original = DnssecDetails(status: 'disabled');

      final updated = original.copyWith(status: 'pending');

      expect(updated.status, 'pending');
    });
  });
}
