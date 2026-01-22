import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/auth/domain/models/account.dart';

void main() {
  group('Account', () {
    group('fromJson', () {
      test('parses account without settings', () {
        final json = {'id': 'acc123', 'name': 'My Account'};

        final account = Account.fromJson(json);

        expect(account.id, 'acc123');
        expect(account.name, 'My Account');
        expect(account.settings, isNull);
      });

      test('parses account with settings', () {
        final json = {
          'id': 'acc456',
          'name': 'Business Account',
          'settings': {
            'enforce_twofactor': true,
            'default_nameservers': 'cloudflare.standard',
          },
        };

        final account = Account.fromJson(json);

        expect(account.id, 'acc456');
        expect(account.name, 'Business Account');
        expect(account.settings, isNotNull);
        expect(account.settings!['enforce_twofactor'], true);
      });
    });

    group('toJson', () {
      test('serializes account without settings', () {
        const account = Account(id: 'acc123', name: 'My Account');

        final json = account.toJson();

        expect(json['id'], 'acc123');
        expect(json['name'], 'My Account');
        expect(json['settings'], isNull);
      });

      test('serializes account with settings', () {
        const account = Account(
          id: 'acc456',
          name: 'Business Account',
          settings: {'enforce_twofactor': true},
        );

        final json = account.toJson();

        expect(json['id'], 'acc456');
        expect(json['name'], 'Business Account');
        expect(json['settings'], isNotNull);
        expect(json['settings']['enforce_twofactor'], true);
      });
    });

    group('copyWith', () {
      test('creates new account with updated fields', () {
        const original = Account(id: 'acc123', name: 'Original');

        final updated = original.copyWith(name: 'Updated');

        expect(updated.id, 'acc123');
        expect(updated.name, 'Updated');
      });

      test('adds settings to account', () {
        const original = Account(id: 'acc123', name: 'My Account');

        final updated = original.copyWith(settings: {'new_setting': 'value'});

        expect(updated.settings, isNotNull);
        expect(updated.settings!['new_setting'], 'value');
      });
    });

    group('equality', () {
      test('equal accounts are equal', () {
        const account1 = Account(id: 'acc123', name: 'My Account');
        const account2 = Account(id: 'acc123', name: 'My Account');

        expect(account1, equals(account2));
        expect(account1.hashCode, equals(account2.hashCode));
      });

      test('different accounts are not equal', () {
        const account1 = Account(id: 'acc123', name: 'My Account');
        const account2 = Account(id: 'acc456', name: 'My Account');

        expect(account1, isNot(equals(account2)));
      });
    });
  });
}
