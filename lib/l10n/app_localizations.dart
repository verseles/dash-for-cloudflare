import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// The app title shown in various places
  ///
  /// In en, this message translates to:
  /// **'Dash for Cloudflare'**
  String get appTitle;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get common_copied;

  /// No description provided for @common_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get common_copy;

  /// No description provided for @common_copyFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy'**
  String get common_copyFailed;

  /// No description provided for @common_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get common_create;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get common_noData;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_refresh;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_workInProgress.
  ///
  /// In en, this message translates to:
  /// **'Work in progress. This feature will be available soon!'**
  String get common_workInProgress;

  /// No description provided for @menu_dns.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get menu_dns;

  /// No description provided for @menu_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menu_settings;

  /// No description provided for @menu_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menu_about;

  /// No description provided for @tabs_records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get tabs_records;

  /// No description provided for @tabs_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get tabs_analytics;

  /// No description provided for @tabs_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabs_settings;

  /// No description provided for @zone_selectZone.
  ///
  /// In en, this message translates to:
  /// **'Select a zone'**
  String get zone_selectZone;

  /// No description provided for @zone_searchZones.
  ///
  /// In en, this message translates to:
  /// **'Search zones...'**
  String get zone_searchZones;

  /// No description provided for @zone_noZones.
  ///
  /// In en, this message translates to:
  /// **'No zones found'**
  String get zone_noZones;

  /// No description provided for @zone_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get zone_status_active;

  /// No description provided for @zone_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get zone_status_pending;

  /// No description provided for @zone_status_initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing'**
  String get zone_status_initializing;

  /// No description provided for @zone_status_moved.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get zone_status_moved;

  /// No description provided for @zone_status_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get zone_status_deleted;

  /// No description provided for @zone_status_deactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get zone_status_deactivated;

  /// No description provided for @dns_records.
  ///
  /// In en, this message translates to:
  /// **'DNS Records'**
  String get dns_records;

  /// No description provided for @dns_filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dns_filterAll;

  /// No description provided for @dns_searchRecords.
  ///
  /// In en, this message translates to:
  /// **'Search records...'**
  String get dns_searchRecords;

  /// No description provided for @dns_noRecords.
  ///
  /// In en, this message translates to:
  /// **'No DNS records'**
  String get dns_noRecords;

  /// No description provided for @dns_noRecordsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a DNS record to get started'**
  String get dns_noRecordsDescription;

  /// No description provided for @dns_noRecordsMatch.
  ///
  /// In en, this message translates to:
  /// **'No records match your filter'**
  String get dns_noRecordsMatch;

  /// No description provided for @dns_selectZoneFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a zone to view records'**
  String get dns_selectZoneFirst;

  /// No description provided for @dns_addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get dns_addRecord;

  /// No description provided for @dns_editRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Record'**
  String get dns_editRecord;

  /// No description provided for @dns_deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get dns_deleteRecord;

  /// No description provided for @dns_deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete DNS Record?'**
  String get dns_deleteConfirmTitle;

  /// No description provided for @dns_deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This action cannot be undone.'**
  String dns_deleteConfirmMessage(String name);

  /// No description provided for @dns_recordSaved.
  ///
  /// In en, this message translates to:
  /// **'Record saved successfully'**
  String get dns_recordSaved;

  /// No description provided for @dns_recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted successfully'**
  String get dns_recordDeleted;

  /// No description provided for @dns_recordDeletedUndo.
  ///
  /// In en, this message translates to:
  /// **'Record deleted. Tap to undo.'**
  String get dns_recordDeletedUndo;

  /// No description provided for @record_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get record_type;

  /// No description provided for @record_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get record_name;

  /// No description provided for @record_nameHint.
  ///
  /// In en, this message translates to:
  /// **'Name or @ for root'**
  String get record_nameHint;

  /// No description provided for @record_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get record_nameRequired;

  /// No description provided for @record_content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get record_content;

  /// No description provided for @record_contentRequired.
  ///
  /// In en, this message translates to:
  /// **'Content is required'**
  String get record_contentRequired;

  /// No description provided for @record_ttl.
  ///
  /// In en, this message translates to:
  /// **'TTL'**
  String get record_ttl;

  /// No description provided for @record_ttlAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get record_ttlAuto;

  /// No description provided for @record_priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get record_priority;

  /// No description provided for @record_proxied.
  ///
  /// In en, this message translates to:
  /// **'Proxied'**
  String get record_proxied;

  /// No description provided for @record_proxiedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Proxied through Cloudflare'**
  String get record_proxiedTooltip;

  /// No description provided for @record_dnsOnly.
  ///
  /// In en, this message translates to:
  /// **'DNS only'**
  String get record_dnsOnly;

  /// No description provided for @record_dnsOnlyTooltip.
  ///
  /// In en, this message translates to:
  /// **'DNS only (not proxied)'**
  String get record_dnsOnlyTooltip;

  /// No description provided for @analytics_title.
  ///
  /// In en, this message translates to:
  /// **'DNS Analytics'**
  String get analytics_title;

  /// No description provided for @analytics_selectZone.
  ///
  /// In en, this message translates to:
  /// **'Select a zone to view analytics'**
  String get analytics_selectZone;

  /// No description provided for @analytics_noData.
  ///
  /// In en, this message translates to:
  /// **'No analytics data'**
  String get analytics_noData;

  /// No description provided for @analytics_loadAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Load Analytics'**
  String get analytics_loadAnalytics;

  /// No description provided for @analytics_timeRange30m.
  ///
  /// In en, this message translates to:
  /// **'30m'**
  String get analytics_timeRange30m;

  /// No description provided for @analytics_timeRange6h.
  ///
  /// In en, this message translates to:
  /// **'6h'**
  String get analytics_timeRange6h;

  /// No description provided for @analytics_timeRange12h.
  ///
  /// In en, this message translates to:
  /// **'12h'**
  String get analytics_timeRange12h;

  /// No description provided for @analytics_timeRange24h.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get analytics_timeRange24h;

  /// No description provided for @analytics_timeRange7d.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get analytics_timeRange7d;

  /// No description provided for @analytics_timeRange30d.
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get analytics_timeRange30d;

  /// No description provided for @analytics_totalQueries.
  ///
  /// In en, this message translates to:
  /// **'Total Queries'**
  String get analytics_totalQueries;

  /// No description provided for @analytics_topQueryNames.
  ///
  /// In en, this message translates to:
  /// **'Top Query Names'**
  String get analytics_topQueryNames;

  /// No description provided for @analytics_clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get analytics_clearSelection;

  /// No description provided for @analytics_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get analytics_total;

  /// No description provided for @analytics_queryTypes.
  ///
  /// In en, this message translates to:
  /// **'Query Types'**
  String get analytics_queryTypes;

  /// No description provided for @analytics_dataCenters.
  ///
  /// In en, this message translates to:
  /// **'Data Centers'**
  String get analytics_dataCenters;

  /// No description provided for @analytics_queriesOverTime.
  ///
  /// In en, this message translates to:
  /// **'Queries Over Time'**
  String get analytics_queriesOverTime;

  /// No description provided for @analytics_queriesByDataCenter.
  ///
  /// In en, this message translates to:
  /// **'Queries by Data Center'**
  String get analytics_queriesByDataCenter;

  /// No description provided for @analytics_queriesByLocation.
  ///
  /// In en, this message translates to:
  /// **'Queries by Location'**
  String get analytics_queriesByLocation;

  /// No description provided for @analytics_queriesByRecordType.
  ///
  /// In en, this message translates to:
  /// **'Queries by Record Type'**
  String get analytics_queriesByRecordType;

  /// No description provided for @analytics_queriesByResponseCode.
  ///
  /// In en, this message translates to:
  /// **'Queries by Response Code'**
  String get analytics_queriesByResponseCode;

  /// No description provided for @analytics_queriesByIpVersion.
  ///
  /// In en, this message translates to:
  /// **'Queries by IP Version'**
  String get analytics_queriesByIpVersion;

  /// No description provided for @analytics_queriesByProtocol.
  ///
  /// In en, this message translates to:
  /// **'Queries by Protocol'**
  String get analytics_queriesByProtocol;

  /// No description provided for @analytics_topQueryNamesChart.
  ///
  /// In en, this message translates to:
  /// **'Top Query Names'**
  String get analytics_topQueryNamesChart;

  /// No description provided for @dnsSettings_title.
  ///
  /// In en, this message translates to:
  /// **'DNS Settings'**
  String get dnsSettings_title;

  /// No description provided for @dnsSettings_dnssec.
  ///
  /// In en, this message translates to:
  /// **'DNSSEC'**
  String get dnsSettings_dnssec;

  /// No description provided for @dnsSettings_dnssecDescription.
  ///
  /// In en, this message translates to:
  /// **'DNS Security Extensions adds a layer of security by signing DNS records. This helps protect your domain from DNS spoofing and cache poisoning attacks.'**
  String get dnsSettings_dnssecDescription;

  /// No description provided for @dnsSettings_dnssecDisabled.
  ///
  /// In en, this message translates to:
  /// **'DNSSEC is disabled'**
  String get dnsSettings_dnssecDisabled;

  /// No description provided for @dnsSettings_dnssecPending.
  ///
  /// In en, this message translates to:
  /// **'DNSSEC is pending activation'**
  String get dnsSettings_dnssecPending;

  /// No description provided for @dnsSettings_dnssecPendingCf.
  ///
  /// In en, this message translates to:
  /// **'DNSSEC will be configured automatically by Cloudflare Registrar'**
  String get dnsSettings_dnssecPendingCf;

  /// No description provided for @dnsSettings_dnssecActive.
  ///
  /// In en, this message translates to:
  /// **'DNSSEC is active'**
  String get dnsSettings_dnssecActive;

  /// No description provided for @dnsSettings_dnssecPendingDisable.
  ///
  /// In en, this message translates to:
  /// **'DNSSEC is pending deactivation'**
  String get dnsSettings_dnssecPendingDisable;

  /// No description provided for @dnsSettings_enableDnssec.
  ///
  /// In en, this message translates to:
  /// **'Enable DNSSEC'**
  String get dnsSettings_enableDnssec;

  /// No description provided for @dnsSettings_disableDnssec.
  ///
  /// In en, this message translates to:
  /// **'Disable DNSSEC'**
  String get dnsSettings_disableDnssec;

  /// No description provided for @dnsSettings_cancelDnssec.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dnsSettings_cancelDnssec;

  /// No description provided for @dnsSettings_viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get dnsSettings_viewDetails;

  /// No description provided for @dnsSettings_viewDsRecord.
  ///
  /// In en, this message translates to:
  /// **'View DS Record'**
  String get dnsSettings_viewDsRecord;

  /// No description provided for @dnsSettings_dsRecord.
  ///
  /// In en, this message translates to:
  /// **'DS Record'**
  String get dnsSettings_dsRecord;

  /// No description provided for @dnsSettings_copyDsRecord.
  ///
  /// In en, this message translates to:
  /// **'Copy DS Record'**
  String get dnsSettings_copyDsRecord;

  /// No description provided for @dnsSettings_dsRecordCopied.
  ///
  /// In en, this message translates to:
  /// **'DS record copied to clipboard'**
  String get dnsSettings_dsRecordCopied;

  /// No description provided for @dnsSettings_addDsToRegistrar.
  ///
  /// In en, this message translates to:
  /// **'Add this DS record to your domain registrar to complete DNSSEC setup:'**
  String get dnsSettings_addDsToRegistrar;

  /// No description provided for @dnsSettings_multiSignerDnssec.
  ///
  /// In en, this message translates to:
  /// **'Multi-signer DNSSEC'**
  String get dnsSettings_multiSignerDnssec;

  /// No description provided for @dnsSettings_multiSignerDescription.
  ///
  /// In en, this message translates to:
  /// **'Allows multiple DNS providers to sign your zone'**
  String get dnsSettings_multiSignerDescription;

  /// No description provided for @dnsSettings_multiProviderDns.
  ///
  /// In en, this message translates to:
  /// **'Multi-provider DNS'**
  String get dnsSettings_multiProviderDns;

  /// No description provided for @dnsSettings_multiProviderDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable secondary DNS with other providers'**
  String get dnsSettings_multiProviderDescription;

  /// No description provided for @dnsSettings_cnameFlattening.
  ///
  /// In en, this message translates to:
  /// **'CNAME Flattening'**
  String get dnsSettings_cnameFlattening;

  /// No description provided for @dnsSettings_cnameFlatteningDescription.
  ///
  /// In en, this message translates to:
  /// **'Flatten CNAME records at the zone apex'**
  String get dnsSettings_cnameFlatteningDescription;

  /// No description provided for @dnsSettings_cnameFlattenNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get dnsSettings_cnameFlattenNone;

  /// No description provided for @dnsSettings_cnameFlattenAtRoot.
  ///
  /// In en, this message translates to:
  /// **'Flatten at root'**
  String get dnsSettings_cnameFlattenAtRoot;

  /// No description provided for @dnsSettings_cnameFlattenAll.
  ///
  /// In en, this message translates to:
  /// **'Flatten all'**
  String get dnsSettings_cnameFlattenAll;

  /// No description provided for @dnsSettings_emailSecurity.
  ///
  /// In en, this message translates to:
  /// **'Email Security'**
  String get dnsSettings_emailSecurity;

  /// No description provided for @dnsSettings_emailSecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure DMARC, SPF, and DKIM records for email authentication'**
  String get dnsSettings_emailSecurityDescription;

  /// No description provided for @dnsSettings_configureEmail.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get dnsSettings_configureEmail;

  /// No description provided for @dnssecDetails_title.
  ///
  /// In en, this message translates to:
  /// **'DNSSEC Details'**
  String get dnssecDetails_title;

  /// No description provided for @dnssecDetails_dsRecord.
  ///
  /// In en, this message translates to:
  /// **'DS Record'**
  String get dnssecDetails_dsRecord;

  /// No description provided for @dnssecDetails_digest.
  ///
  /// In en, this message translates to:
  /// **'Digest'**
  String get dnssecDetails_digest;

  /// No description provided for @dnssecDetails_digestType.
  ///
  /// In en, this message translates to:
  /// **'Digest Type'**
  String get dnssecDetails_digestType;

  /// No description provided for @dnssecDetails_algorithm.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get dnssecDetails_algorithm;

  /// No description provided for @dnssecDetails_publicKey.
  ///
  /// In en, this message translates to:
  /// **'Public Key'**
  String get dnssecDetails_publicKey;

  /// No description provided for @dnssecDetails_keyTag.
  ///
  /// In en, this message translates to:
  /// **'Key Tag'**
  String get dnssecDetails_keyTag;

  /// No description provided for @dnssecDetails_keyType.
  ///
  /// In en, this message translates to:
  /// **'Key Type'**
  String get dnssecDetails_keyType;

  /// No description provided for @dnssecDetails_flags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get dnssecDetails_flags;

  /// No description provided for @dnssecDetails_modifiedOn.
  ///
  /// In en, this message translates to:
  /// **'Modified On'**
  String get dnssecDetails_modifiedOn;

  /// No description provided for @dnssecDetails_tapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get dnssecDetails_tapToCopy;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_apiToken.
  ///
  /// In en, this message translates to:
  /// **'API Token'**
  String get settings_apiToken;

  /// No description provided for @settings_apiTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your Cloudflare API token'**
  String get settings_apiTokenHint;

  /// No description provided for @settings_apiTokenDescription.
  ///
  /// In en, this message translates to:
  /// **'Your API token needs the following permissions:'**
  String get settings_apiTokenDescription;

  /// No description provided for @settings_apiTokenPermission1.
  ///
  /// In en, this message translates to:
  /// **'Zone:Read - to list your zones'**
  String get settings_apiTokenPermission1;

  /// No description provided for @settings_apiTokenPermission2.
  ///
  /// In en, this message translates to:
  /// **'DNS:Edit - to manage DNS records'**
  String get settings_apiTokenPermission2;

  /// No description provided for @settings_apiTokenPermission3.
  ///
  /// In en, this message translates to:
  /// **'Zone Settings:Read - for DNSSEC status'**
  String get settings_apiTokenPermission3;

  /// No description provided for @settings_apiTokenPermission4.
  ///
  /// In en, this message translates to:
  /// **'Zone Settings:Edit - to toggle DNSSEC'**
  String get settings_apiTokenPermission4;

  /// No description provided for @settings_apiTokenPermission5.
  ///
  /// In en, this message translates to:
  /// **'Analytics:Read - for DNS analytics'**
  String get settings_apiTokenPermission5;

  /// No description provided for @settings_createToken.
  ///
  /// In en, this message translates to:
  /// **'Create a token at dash.cloudflare.com'**
  String get settings_createToken;

  /// No description provided for @settings_tokenValid.
  ///
  /// In en, this message translates to:
  /// **'Token is valid'**
  String get settings_tokenValid;

  /// No description provided for @settings_tokenInvalid.
  ///
  /// In en, this message translates to:
  /// **'Token must be at least 40 characters'**
  String get settings_tokenInvalid;

  /// No description provided for @settings_tokenSaved.
  ///
  /// In en, this message translates to:
  /// **'Token saved'**
  String get settings_tokenSaved;

  /// No description provided for @settings_goToDns.
  ///
  /// In en, this message translates to:
  /// **'Go to DNS'**
  String get settings_goToDns;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_themeLight;

  /// No description provided for @settings_themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_themeDark;

  /// No description provided for @settings_themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_themeSystem;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_languageEn;

  /// No description provided for @settings_languagePt.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get settings_languagePt;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settings_version(String version);

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_generic;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get error_network;

  /// No description provided for @error_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired API token'**
  String get error_unauthorized;

  /// No description provided for @error_forbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this resource'**
  String get error_forbidden;

  /// No description provided for @error_notFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get error_notFound;

  /// No description provided for @error_rateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get error_rateLimited;

  /// No description provided for @error_serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get error_serverError;

  /// No description provided for @pwa_updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version is available'**
  String get pwa_updateAvailable;

  /// No description provided for @pwa_updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get pwa_updateNow;

  /// No description provided for @pwa_installApp.
  ///
  /// In en, this message translates to:
  /// **'Install App'**
  String get pwa_installApp;

  /// No description provided for @pwa_installDescription.
  ///
  /// In en, this message translates to:
  /// **'Install Dash for Cloudflare for quick access'**
  String get pwa_installDescription;

  /// No description provided for @settings_cloudflareApiToken.
  ///
  /// In en, this message translates to:
  /// **'Cloudflare API Token'**
  String get settings_cloudflareApiToken;

  /// No description provided for @settings_requiredPermissions.
  ///
  /// In en, this message translates to:
  /// **'Required permissions: Zone:Read, DNS:Read, DNS:Edit'**
  String get settings_requiredPermissions;

  /// No description provided for @settings_createTokenOnCloudflare.
  ///
  /// In en, this message translates to:
  /// **'Create token on Cloudflare'**
  String get settings_createTokenOnCloudflare;

  /// No description provided for @settings_tokenPastedFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Token pasted from clipboard'**
  String get settings_tokenPastedFromClipboard;

  /// No description provided for @settings_storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settings_storage;

  /// No description provided for @settings_clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settings_clearCache;

  /// No description provided for @settings_clearCacheDescription.
  ///
  /// In en, this message translates to:
  /// **'DNS records, analytics, and data centers'**
  String get settings_clearCacheDescription;

  /// No description provided for @settings_clearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settings_clearCacheTitle;

  /// No description provided for @settings_clearCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'This will clear all cached data including DNS records, analytics, and data center information.\n\nData will be reloaded from the API on next access.'**
  String get settings_clearCacheMessage;

  /// No description provided for @settings_cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get settings_cacheCleared;

  /// No description provided for @settings_debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settings_debug;

  /// No description provided for @settings_saveLogsToFile.
  ///
  /// In en, this message translates to:
  /// **'Save logs to file'**
  String get settings_saveLogsToFile;

  /// No description provided for @settings_saveLogsDescription.
  ///
  /// In en, this message translates to:
  /// **'Persists logs for later analysis'**
  String get settings_saveLogsDescription;

  /// No description provided for @settings_viewDebugLogs.
  ///
  /// In en, this message translates to:
  /// **'View Debug Logs'**
  String get settings_viewDebugLogs;

  /// No description provided for @settings_goToDnsManagement.
  ///
  /// In en, this message translates to:
  /// **'Go to DNS Management'**
  String get settings_goToDnsManagement;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
