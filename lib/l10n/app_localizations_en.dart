// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dash for Cloudflare';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get workInProgress =>
      'Work in progress. This feature will be available soon!';
}
