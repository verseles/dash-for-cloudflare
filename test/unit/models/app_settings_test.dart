import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cf/features/auth/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    group('fromJson', () {
      test('parses minimal settings', () {
        final json = <String, dynamic>{};

        final settings = AppSettings.fromJson(json);

        expect(settings.cloudflareApiToken, isNull);
        expect(settings.themeMode, ThemeMode.system);
        expect(settings.locale, 'en');
        expect(settings.selectedZoneId, isNull);
        expect(settings.amoledDarkMode, false);
      });

      test('parses full settings', () {
        final json = {
          'cloudflareApiToken': 'test_token_12345678901234567890123456789012',
          'themeMode': 'dark',
          'locale': 'pt',
          'selectedZoneId': 'zone123',
          'amoledDarkMode': true,
        };

        final settings = AppSettings.fromJson(json);

        expect(
          settings.cloudflareApiToken,
          'test_token_12345678901234567890123456789012',
        );
        expect(settings.themeMode, ThemeMode.dark);
        expect(settings.locale, 'pt');
        expect(settings.selectedZoneId, 'zone123');
        expect(settings.amoledDarkMode, true);
      });

      test('parses light theme', () {
        final json = {'themeMode': 'light'};

        final settings = AppSettings.fromJson(json);

        expect(settings.themeMode, ThemeMode.light);
      });

      test('parses system theme from unknown value', () {
        final json = {'themeMode': 'invalid'};

        final settings = AppSettings.fromJson(json);

        expect(settings.themeMode, ThemeMode.system);
      });
    });

    group('toJson', () {
      test('serializes settings correctly', () {
        const settings = AppSettings(
          cloudflareApiToken: 'token123',
          themeMode: ThemeMode.dark,
          locale: 'pt',
          selectedZoneId: 'zone456',
        );

        final json = settings.toJson();

        expect(json['cloudflareApiToken'], 'token123');
        expect(json['themeMode'], 'dark');
        expect(json['locale'], 'pt');
        expect(json['selectedZoneId'], 'zone456');
      });

      test('serializes light theme', () {
        const settings = AppSettings(themeMode: ThemeMode.light);

        final json = settings.toJson();

        expect(json['themeMode'], 'light');
      });

      test('serializes system theme', () {
        const settings = AppSettings(themeMode: ThemeMode.system);

        final json = settings.toJson();

        expect(json['themeMode'], 'system');
      });
    });

    group('copyWith', () {
      test('updates token', () {
        const original = AppSettings();

        final updated = original.copyWith(cloudflareApiToken: 'new_token');

        expect(updated.cloudflareApiToken, 'new_token');
        expect(updated.themeMode, ThemeMode.system);
        expect(updated.locale, 'en');
      });

      test('updates theme mode', () {
        const original = AppSettings();

        final updated = original.copyWith(themeMode: ThemeMode.dark);

        expect(updated.themeMode, ThemeMode.dark);
      });

      test('updates locale', () {
        const original = AppSettings(locale: 'en');

        final updated = original.copyWith(locale: 'pt');

        expect(updated.locale, 'pt');
      });

      test('updates selected zone', () {
        const original = AppSettings();

        final updated = original.copyWith(selectedZoneId: 'zone123');

        expect(updated.selectedZoneId, 'zone123');
      });

      test('updates amoled dark mode', () {
        const original = AppSettings();

        final updated = original.copyWith(amoledDarkMode: true);

        expect(updated.amoledDarkMode, true);
      });
    });

    group('equality', () {
      test('equal settings are equal', () {
        const settings1 = AppSettings(
          cloudflareApiToken: 'token',
          themeMode: ThemeMode.dark,
          locale: 'en',
          amoledDarkMode: true,
        );
        const settings2 = AppSettings(
          cloudflareApiToken: 'token',
          themeMode: ThemeMode.dark,
          locale: 'en',
          amoledDarkMode: true,
        );

        expect(settings1, equals(settings2));
      });

      test('different settings are not equal', () {
        const settings1 = AppSettings(themeMode: ThemeMode.dark);
        const settings2 = AppSettings(themeMode: ThemeMode.light);

        expect(settings1, isNot(equals(settings2)));
      });

      test('different amoled mode makes settings unequal', () {
        const settings1 = AppSettings(amoledDarkMode: true);
        const settings2 = AppSettings(amoledDarkMode: false);

        expect(settings1, isNot(equals(settings2)));
      });
    });
  });

  group('ThemeModeConverter', () {
    const converter = ThemeModeConverter();

    group('fromJson', () {
      test('converts light string to ThemeMode.light', () {
        expect(converter.fromJson('light'), ThemeMode.light);
      });

      test('converts dark string to ThemeMode.dark', () {
        expect(converter.fromJson('dark'), ThemeMode.dark);
      });

      test('converts system string to ThemeMode.system', () {
        expect(converter.fromJson('system'), ThemeMode.system);
      });

      test('converts unknown string to ThemeMode.system', () {
        expect(converter.fromJson('unknown'), ThemeMode.system);
        expect(converter.fromJson(''), ThemeMode.system);
      });
    });

    group('toJson', () {
      test('converts ThemeMode.light to light string', () {
        expect(converter.toJson(ThemeMode.light), 'light');
      });

      test('converts ThemeMode.dark to dark string', () {
        expect(converter.toJson(ThemeMode.dark), 'dark');
      });

      test('converts ThemeMode.system to system string', () {
        expect(converter.toJson(ThemeMode.system), 'system');
      });
    });
  });
}
