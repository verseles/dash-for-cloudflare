import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/dns/domain/models/dns_record.dart';
import 'package:cf/features/dns/providers/dns_records_provider.dart';

void main() {
  group('DnsRecordsState', () {
    group('constructor', () {
      test('has correct defaults', () {
        const state = DnsRecordsState();

        expect(state.records, isEmpty);
        expect(state.savingIds, isEmpty);
        expect(state.newIds, isEmpty);
        expect(state.deletingIds, isEmpty);
        expect(state.activeFilter, 'All');
        expect(state.searchQuery, '');
        expect(state.isFromCache, false);
        expect(state.isRefreshing, false);
        expect(state.cachedAt, isNull);
      });

      test('accepts all parameters', () {
        final cachedTime = DateTime(2024, 1, 15, 10, 30);
        final state = DnsRecordsState(
          records: const [
            DnsRecord(
              id: 'rec1',
              type: 'A',
              name: 'www',
              content: '1.2.3.4',
              zoneId: 'z1',
              zoneName: 'example.com',
            ),
          ],
          savingIds: const {'rec1'},
          newIds: const {'rec2'},
          deletingIds: const {'rec3'},
          activeFilter: 'A',
          searchQuery: 'www',
          isFromCache: true,
          isRefreshing: true,
          cachedAt: cachedTime,
        );

        expect(state.records.length, 1);
        expect(state.savingIds, {'rec1'});
        expect(state.newIds, {'rec2'});
        expect(state.deletingIds, {'rec3'});
        expect(state.activeFilter, 'A');
        expect(state.searchQuery, 'www');
        expect(state.isFromCache, true);
        expect(state.isRefreshing, true);
        expect(state.cachedAt, cachedTime);
      });
    });

    group('copyWith', () {
      test('updates isFromCache', () {
        const original = DnsRecordsState(isFromCache: false);
        final updated = original.copyWith(isFromCache: true);

        expect(updated.isFromCache, true);
        expect(updated.isRefreshing, false); // unchanged
      });

      test('updates isRefreshing', () {
        const original = DnsRecordsState(isRefreshing: false);
        final updated = original.copyWith(isRefreshing: true);

        expect(updated.isRefreshing, true);
      });

      test('updates cachedAt', () {
        const original = DnsRecordsState();
        final newTime = DateTime(2024, 6, 15);
        final updated = original.copyWith(cachedAt: newTime);

        expect(updated.cachedAt, newTime);
      });

      test('preserves other values when updating cache fields', () {
        const original = DnsRecordsState(
          activeFilter: 'MX',
          searchQuery: 'mail',
        );
        final updated = original.copyWith(isFromCache: true);

        expect(updated.activeFilter, 'MX');
        expect(updated.searchQuery, 'mail');
        expect(updated.isFromCache, true);
      });

      test('updates records list', () {
        const original = DnsRecordsState();
        const newRecords = [
          DnsRecord(
            id: 'new1',
            type: 'CNAME',
            name: 'blog',
            content: 'example.com',
            zoneId: 'z1',
            zoneName: 'example.com',
          ),
        ];
        final updated = original.copyWith(records: newRecords);

        expect(updated.records.length, 1);
        expect(updated.records.first.id, 'new1');
      });
    });

    group('filteredRecords', () {
      final testRecords = [
        const DnsRecord(
          id: 'rec1',
          type: 'A',
          name: 'www.example.com',
          content: '1.2.3.4',
          zoneId: 'z1',
          zoneName: 'example.com',
        ),
        const DnsRecord(
          id: 'rec2',
          type: 'A',
          name: 'api.example.com',
          content: '5.6.7.8',
          zoneId: 'z1',
          zoneName: 'example.com',
        ),
        const DnsRecord(
          id: 'rec3',
          type: 'MX',
          name: 'example.com',
          content: 'mail.example.com',
          zoneId: 'z1',
          zoneName: 'example.com',
        ),
        const DnsRecord(
          id: 'rec4',
          type: 'TXT',
          name: 'example.com',
          content: 'v=spf1 include:_spf.example.com ~all',
          zoneId: 'z1',
          zoneName: 'example.com',
        ),
      ];

      test('returns all records when filter is All', () {
        final state = DnsRecordsState(records: testRecords, activeFilter: 'All');

        expect(state.filteredRecords.length, 4);
      });

      test('filters by type', () {
        final state = DnsRecordsState(records: testRecords, activeFilter: 'A');

        expect(state.filteredRecords.length, 2);
        expect(state.filteredRecords.every((r) => r.type == 'A'), true);
      });

      test('filters by search query in name', () {
        final state = DnsRecordsState(records: testRecords, searchQuery: 'www');

        expect(state.filteredRecords.length, 1);
        expect(state.filteredRecords.first.name, 'www.example.com');
      });

      test('filters by search query in content', () {
        final state = DnsRecordsState(records: testRecords, searchQuery: 'spf');

        expect(state.filteredRecords.length, 1);
        expect(state.filteredRecords.first.type, 'TXT');
      });

      test('combines type filter and search query', () {
        final state = DnsRecordsState(
          records: testRecords,
          activeFilter: 'A',
          searchQuery: 'api',
        );

        expect(state.filteredRecords.length, 1);
        expect(state.filteredRecords.first.name, 'api.example.com');
      });

      test('search is case insensitive', () {
        final state = DnsRecordsState(records: testRecords, searchQuery: 'WWW');

        expect(state.filteredRecords.length, 1);
        expect(state.filteredRecords.first.name, 'www.example.com');
      });

      test('returns empty when no matches', () {
        final state = DnsRecordsState(
          records: testRecords,
          searchQuery: 'nonexistent',
        );

        expect(state.filteredRecords, isEmpty);
      });
    });
  });

  group('recordTypes', () {
    test('contains common DNS record types', () {
      expect(recordTypes, contains('A'));
      expect(recordTypes, contains('AAAA'));
      expect(recordTypes, contains('CNAME'));
      expect(recordTypes, contains('TXT'));
      expect(recordTypes, contains('MX'));
      expect(recordTypes, contains('SRV'));
      expect(recordTypes, contains('NS'));
      expect(recordTypes, contains('PTR'));
    });

    test('has expected length', () {
      expect(recordTypes.length, 8);
    });
  });
}
