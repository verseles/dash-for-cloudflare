import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh'),
  ];

  /// The app title shown in various places
  ///
  /// In en, this message translates to:
  /// **'Dash for CF'**
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

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get common_deleted;

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

  /// No description provided for @common_clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get common_clearSearch;

  /// No description provided for @common_clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get common_clearFilters;

  /// No description provided for @common_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get common_all;

  /// No description provided for @common_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get common_none;

  /// No description provided for @common_proxy.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get common_proxy;

  /// No description provided for @common_rootOnly.
  ///
  /// In en, this message translates to:
  /// **'Root only'**
  String get common_rootOnly;

  /// No description provided for @common_disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get common_disable;

  /// No description provided for @menu_dns.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get menu_dns;

  /// No description provided for @menu_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get menu_analytics;

  /// No description provided for @menu_pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get menu_pages;

  /// No description provided for @menu_workers.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get menu_workers;

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

  /// No description provided for @menu_debugLogs.
  ///
  /// In en, this message translates to:
  /// **'Debug Logs'**
  String get menu_debugLogs;

  /// No description provided for @menu_selectZone.
  ///
  /// In en, this message translates to:
  /// **'Select Zone'**
  String get menu_selectZone;

  /// No description provided for @menu_noZones.
  ///
  /// In en, this message translates to:
  /// **'No zones'**
  String get menu_noZones;

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

  /// No description provided for @tabs_web.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get tabs_web;

  /// No description provided for @tabs_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get tabs_security;

  /// No description provided for @tabs_cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get tabs_cache;

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

  /// No description provided for @dns_deleteRecordConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Record?'**
  String get dns_deleteRecordConfirmTitle;

  /// No description provided for @dns_deleteRecordConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String dns_deleteRecordConfirmMessage(String name);

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

  /// No description provided for @analytics_requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get analytics_requests;

  /// No description provided for @analytics_bandwidth.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth'**
  String get analytics_bandwidth;

  /// No description provided for @analytics_uniqueVisitors.
  ///
  /// In en, this message translates to:
  /// **'Unique Visitors'**
  String get analytics_uniqueVisitors;

  /// No description provided for @analytics_requestsByStatus.
  ///
  /// In en, this message translates to:
  /// **'Requests by Status'**
  String get analytics_requestsByStatus;

  /// No description provided for @analytics_requestsByCountry.
  ///
  /// In en, this message translates to:
  /// **'Requests by Country'**
  String get analytics_requestsByCountry;

  /// No description provided for @analytics_geographicDistribution.
  ///
  /// In en, this message translates to:
  /// **'Geographic Distribution'**
  String get analytics_geographicDistribution;

  /// No description provided for @analytics_requestsByProtocol.
  ///
  /// In en, this message translates to:
  /// **'Requests by Protocol'**
  String get analytics_requestsByProtocol;

  /// No description provided for @analytics_requestsByHost.
  ///
  /// In en, this message translates to:
  /// **'Requests by Host'**
  String get analytics_requestsByHost;

  /// No description provided for @analytics_topPaths.
  ///
  /// In en, this message translates to:
  /// **'Top Paths'**
  String get analytics_topPaths;

  /// No description provided for @analytics_threatsStopped.
  ///
  /// In en, this message translates to:
  /// **'Threats Stopped'**
  String get analytics_threatsStopped;

  /// No description provided for @analytics_totalThreatsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Total Threats Blocked'**
  String get analytics_totalThreatsBlocked;

  /// No description provided for @analytics_actionsTaken.
  ///
  /// In en, this message translates to:
  /// **'Actions Taken'**
  String get analytics_actionsTaken;

  /// No description provided for @analytics_threatsByCountry.
  ///
  /// In en, this message translates to:
  /// **'Threats by Country'**
  String get analytics_threatsByCountry;

  /// No description provided for @analytics_topThreatSources.
  ///
  /// In en, this message translates to:
  /// **'Top Threat Sources'**
  String get analytics_topThreatSources;

  /// No description provided for @analytics_threatOrigins.
  ///
  /// In en, this message translates to:
  /// **'Threat Origins'**
  String get analytics_threatOrigins;

  /// No description provided for @analytics_cacheHitRatio.
  ///
  /// In en, this message translates to:
  /// **'Cache Hit Ratio'**
  String get analytics_cacheHitRatio;

  /// No description provided for @analytics_bandwidthSaved.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth Saved'**
  String get analytics_bandwidthSaved;

  /// No description provided for @analytics_requestsCacheVsOrigin.
  ///
  /// In en, this message translates to:
  /// **'Requests (Cache vs Origin)'**
  String get analytics_requestsCacheVsOrigin;

  /// No description provided for @analytics_bandwidthCacheVsOrigin.
  ///
  /// In en, this message translates to:
  /// **'Bandwidth (Cache vs Origin)'**
  String get analytics_bandwidthCacheVsOrigin;

  /// No description provided for @analytics_cacheStatusByHttpStatus.
  ///
  /// In en, this message translates to:
  /// **'Cache Status by HTTP Status'**
  String get analytics_cacheStatusByHttpStatus;

  /// No description provided for @analytics_securityRequiresPaidPlan.
  ///
  /// In en, this message translates to:
  /// **'Security Analytics requires a paid Cloudflare plan (Pro or higher).'**
  String get analytics_securityRequiresPaidPlan;

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

  /// No description provided for @dnsSettings_disableDnssecTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable DNSSEC?'**
  String get dnsSettings_disableDnssecTitle;

  /// No description provided for @dnsSettings_cancelDeactivation.
  ///
  /// In en, this message translates to:
  /// **'Cancel Deactivation'**
  String get dnsSettings_cancelDeactivation;

  /// No description provided for @emailSecurity_spfExists.
  ///
  /// In en, this message translates to:
  /// **'SPF record already configured'**
  String get emailSecurity_spfExists;

  /// No description provided for @emailSecurity_spfNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'SPF not configured'**
  String get emailSecurity_spfNotConfigured;

  /// No description provided for @emailSecurity_spfDescription.
  ///
  /// In en, this message translates to:
  /// **'Sender Policy Framework (SPF) specifies which mail servers are authorized to send email on behalf of your domain.'**
  String get emailSecurity_spfDescription;

  /// No description provided for @emailSecurity_spfIncludes.
  ///
  /// In en, this message translates to:
  /// **'Authorized Senders (includes)'**
  String get emailSecurity_spfIncludes;

  /// No description provided for @emailSecurity_spfIncludesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., _spf.google.com sendgrid.net'**
  String get emailSecurity_spfIncludesHint;

  /// No description provided for @emailSecurity_spfPolicy.
  ///
  /// In en, this message translates to:
  /// **'Policy (All)'**
  String get emailSecurity_spfPolicy;

  /// No description provided for @emailSecurity_spfPolicyHint.
  ///
  /// In en, this message translates to:
  /// **'~all (soft fail), -all (hard fail), or +all (allow)'**
  String get emailSecurity_spfPolicyHint;

  /// No description provided for @emailSecurity_spfSaved.
  ///
  /// In en, this message translates to:
  /// **'SPF record saved successfully'**
  String get emailSecurity_spfSaved;

  /// No description provided for @emailSecurity_dkimExists.
  ///
  /// In en, this message translates to:
  /// **'DKIM record already configured'**
  String get emailSecurity_dkimExists;

  /// No description provided for @emailSecurity_dkimNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'DKIM not configured'**
  String get emailSecurity_dkimNotConfigured;

  /// No description provided for @emailSecurity_dkimDescription.
  ///
  /// In en, this message translates to:
  /// **'DomainKeys Identified Mail (DKIM) adds a digital signature to your emails to verify they haven\'t been tampered with.'**
  String get emailSecurity_dkimDescription;

  /// No description provided for @emailSecurity_dkimSelector.
  ///
  /// In en, this message translates to:
  /// **'Selector'**
  String get emailSecurity_dkimSelector;

  /// No description provided for @emailSecurity_dkimSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., default, google, mailgun'**
  String get emailSecurity_dkimSelectorHint;

  /// No description provided for @emailSecurity_dkimPublicKey.
  ///
  /// In en, this message translates to:
  /// **'Public Key (p=)'**
  String get emailSecurity_dkimPublicKey;

  /// No description provided for @emailSecurity_dkimPublicKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the public key provided by your email provider (without v=DKIM1; k=rsa; p= prefix)'**
  String get emailSecurity_dkimPublicKeyHint;

  /// No description provided for @emailSecurity_dkimPublicKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Public key is required'**
  String get emailSecurity_dkimPublicKeyRequired;

  /// No description provided for @emailSecurity_dkimSaved.
  ///
  /// In en, this message translates to:
  /// **'DKIM record saved successfully'**
  String get emailSecurity_dkimSaved;

  /// No description provided for @emailSecurity_dmarcExists.
  ///
  /// In en, this message translates to:
  /// **'DMARC record already configured'**
  String get emailSecurity_dmarcExists;

  /// No description provided for @emailSecurity_dmarcNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'DMARC not configured'**
  String get emailSecurity_dmarcNotConfigured;

  /// No description provided for @emailSecurity_dmarcDescription.
  ///
  /// In en, this message translates to:
  /// **'Domain-based Message Authentication, Reporting & Conformance (DMARC) tells receiving mail servers what to do when SPF or DKIM checks fail.'**
  String get emailSecurity_dmarcDescription;

  /// No description provided for @emailSecurity_dmarcPolicy.
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get emailSecurity_dmarcPolicy;

  /// No description provided for @emailSecurity_dmarcPolicyHint.
  ///
  /// In en, this message translates to:
  /// **'Action to take on authentication failure'**
  String get emailSecurity_dmarcPolicyHint;

  /// No description provided for @emailSecurity_dmarcPolicyNone.
  ///
  /// In en, this message translates to:
  /// **'None (Monitor only)'**
  String get emailSecurity_dmarcPolicyNone;

  /// No description provided for @emailSecurity_dmarcPolicyQuarantine.
  ///
  /// In en, this message translates to:
  /// **'Quarantine (Mark as spam)'**
  String get emailSecurity_dmarcPolicyQuarantine;

  /// No description provided for @emailSecurity_dmarcPolicyReject.
  ///
  /// In en, this message translates to:
  /// **'Reject (Block delivery)'**
  String get emailSecurity_dmarcPolicyReject;

  /// No description provided for @emailSecurity_dmarcRua.
  ///
  /// In en, this message translates to:
  /// **'Aggregate Reports Email (rua)'**
  String get emailSecurity_dmarcRua;

  /// No description provided for @emailSecurity_dmarcRuaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., dmarc-reports@yourdomain.com'**
  String get emailSecurity_dmarcRuaHint;

  /// No description provided for @emailSecurity_dmarcRuf.
  ///
  /// In en, this message translates to:
  /// **'Forensic Reports Email (ruf)'**
  String get emailSecurity_dmarcRuf;

  /// No description provided for @emailSecurity_dmarcRufHint.
  ///
  /// In en, this message translates to:
  /// **'Optional: forensic failure reports'**
  String get emailSecurity_dmarcRufHint;

  /// No description provided for @emailSecurity_dmarcPct.
  ///
  /// In en, this message translates to:
  /// **'Percentage of emails to filter'**
  String get emailSecurity_dmarcPct;

  /// No description provided for @emailSecurity_dmarcSaved.
  ///
  /// In en, this message translates to:
  /// **'DMARC record saved successfully'**
  String get emailSecurity_dmarcSaved;

  /// No description provided for @emailSecurity_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get emailSecurity_preview;

  /// No description provided for @emailSecurity_recordName.
  ///
  /// In en, this message translates to:
  /// **'Record Name'**
  String get emailSecurity_recordName;

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
  /// **'Auto'**
  String get settings_themeSystem;

  /// No description provided for @settings_amoledMode.
  ///
  /// In en, this message translates to:
  /// **'AMOLED Black'**
  String get settings_amoledMode;

  /// No description provided for @settings_amoledModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Pure black background for dark mode (saves battery on OLED screens)'**
  String get settings_amoledModeDescription;

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

  /// No description provided for @settings_languageZh.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get settings_languageZh;

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

  /// No description provided for @error_prefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error_prefix(String message);

  /// No description provided for @error_copyError.
  ///
  /// In en, this message translates to:
  /// **'Copy Error Details'**
  String get error_copyError;

  /// No description provided for @error_permissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Permissions Required'**
  String get error_permissionsRequired;

  /// No description provided for @error_permissionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your API token doesn\'t have the necessary permissions to access this resource. Please check your token settings on Cloudflare.'**
  String get error_permissionsDescription;

  /// No description provided for @error_checkCloudflareDashboard.
  ///
  /// In en, this message translates to:
  /// **'Check Cloudflare Dashboard'**
  String get error_checkCloudflareDashboard;

  /// No description provided for @error_commonPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Commonly required permissions:'**
  String get error_commonPermissionsTitle;

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
  /// **'Install Dash for CF for quick access'**
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

  /// No description provided for @debugLogs_title.
  ///
  /// In en, this message translates to:
  /// **'Debug Logs'**
  String get debugLogs_title;

  /// No description provided for @debugLogs_copyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy All'**
  String get debugLogs_copyAll;

  /// No description provided for @debugLogs_saveToFile.
  ///
  /// In en, this message translates to:
  /// **'Save to File'**
  String get debugLogs_saveToFile;

  /// No description provided for @debugLogs_shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as Text'**
  String get debugLogs_shareAsText;

  /// No description provided for @debugLogs_shareAsFile.
  ///
  /// In en, this message translates to:
  /// **'Share as File'**
  String get debugLogs_shareAsFile;

  /// No description provided for @debugLogs_clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get debugLogs_clearLogs;

  /// No description provided for @debugLogs_logsCopied.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard'**
  String get debugLogs_logsCopied;

  /// No description provided for @debugLogs_savedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String debugLogs_savedTo(String path);

  /// No description provided for @debugLogs_failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String debugLogs_failedToSave(String error);

  /// No description provided for @debugLogs_failedToShare.
  ///
  /// In en, this message translates to:
  /// **'Failed to share: {error}'**
  String debugLogs_failedToShare(String error);

  /// No description provided for @debugLogs_copyTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Copy {timeRange}'**
  String debugLogs_copyTimeRange(String timeRange);

  /// No description provided for @debugLogs_logEntryCopied.
  ///
  /// In en, this message translates to:
  /// **'Log entry copied'**
  String get debugLogs_logEntryCopied;

  /// No description provided for @debugLogs_timeRange.
  ///
  /// In en, this message translates to:
  /// **'Time Range:'**
  String get debugLogs_timeRange;

  /// No description provided for @debugLogs_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter:'**
  String get debugLogs_filter;

  /// No description provided for @debugLogs_entries.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String debugLogs_entries(int count);

  /// No description provided for @debugLogs_noLogsInRange.
  ///
  /// In en, this message translates to:
  /// **'No logs in this time range'**
  String get debugLogs_noLogsInRange;

  /// No description provided for @debugLogs_tryLongerRange.
  ///
  /// In en, this message translates to:
  /// **'Try selecting a longer time range'**
  String get debugLogs_tryLongerRange;

  /// No description provided for @debugLogs_autoScrollOn.
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll ON'**
  String get debugLogs_autoScrollOn;

  /// No description provided for @debugLogs_autoScrollOff.
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll OFF'**
  String get debugLogs_autoScrollOff;

  /// No description provided for @debugLogs_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search logs...'**
  String get debugLogs_searchHint;

  /// No description provided for @dnsRecord_createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create DNS Record'**
  String get dnsRecord_createTitle;

  /// No description provided for @dnsRecord_editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit DNS Record'**
  String get dnsRecord_editTitle;

  /// No description provided for @dnsRecord_recordCreated.
  ///
  /// In en, this message translates to:
  /// **'Record created'**
  String get dnsRecord_recordCreated;

  /// No description provided for @dnsRecord_recordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Record updated'**
  String get dnsRecord_recordUpdated;

  /// No description provided for @dnsRecord_ttlAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get dnsRecord_ttlAuto;

  /// No description provided for @dnsRecord_ttl2min.
  ///
  /// In en, this message translates to:
  /// **'2 minutes'**
  String get dnsRecord_ttl2min;

  /// No description provided for @dnsRecord_ttl5min.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get dnsRecord_ttl5min;

  /// No description provided for @dnsRecord_ttl10min.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get dnsRecord_ttl10min;

  /// No description provided for @dnsRecord_ttl15min.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get dnsRecord_ttl15min;

  /// No description provided for @dnsRecord_ttl30min.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get dnsRecord_ttl30min;

  /// No description provided for @dnsRecord_ttl1hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get dnsRecord_ttl1hour;

  /// No description provided for @dnsRecord_ttl2hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get dnsRecord_ttl2hours;

  /// No description provided for @dnsRecord_ttl5hours.
  ///
  /// In en, this message translates to:
  /// **'5 hours'**
  String get dnsRecord_ttl5hours;

  /// No description provided for @dnsRecord_ttl12hours.
  ///
  /// In en, this message translates to:
  /// **'12 hours'**
  String get dnsRecord_ttl12hours;

  /// No description provided for @dnsRecord_ttl1day.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get dnsRecord_ttl1day;

  /// No description provided for @dnsRecord_enterValue.
  ///
  /// In en, this message translates to:
  /// **'Enter value'**
  String get dnsRecord_enterValue;

  /// No description provided for @emptyState_noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String emptyState_noResultsFor(String query);

  /// No description provided for @emptyState_tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms'**
  String get emptyState_tryAdjustingSearch;

  /// No description provided for @pages_title.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages_title;

  /// No description provided for @pages_selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select account'**
  String get pages_selectAccount;

  /// No description provided for @pages_noProjects.
  ///
  /// In en, this message translates to:
  /// **'No Pages projects found'**
  String get pages_noProjects;

  /// No description provided for @pages_lastDeployment.
  ///
  /// In en, this message translates to:
  /// **'Last deployed: {date}'**
  String pages_lastDeployment(String date);

  /// No description provided for @pages_statusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get pages_statusSuccess;

  /// No description provided for @pages_statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get pages_statusFailed;

  /// No description provided for @pages_statusBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get pages_statusBuilding;

  /// No description provided for @pages_statusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get pages_statusQueued;

  /// No description provided for @pages_statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get pages_statusSkipped;

  /// No description provided for @pages_statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get pages_statusUnknown;

  /// No description provided for @pages_openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get pages_openInBrowser;

  /// No description provided for @pages_deployments.
  ///
  /// In en, this message translates to:
  /// **'Deployments'**
  String get pages_deployments;

  /// No description provided for @pages_noDeployments.
  ///
  /// In en, this message translates to:
  /// **'No deployments found'**
  String get pages_noDeployments;

  /// No description provided for @pages_production.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get pages_production;

  /// No description provided for @pages_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get pages_preview;

  /// No description provided for @pages_deploymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Deployment Details'**
  String get pages_deploymentDetails;

  /// No description provided for @pages_commitInfo.
  ///
  /// In en, this message translates to:
  /// **'Commit Information'**
  String get pages_commitInfo;

  /// No description provided for @pages_buildStages.
  ///
  /// In en, this message translates to:
  /// **'Build Stages'**
  String get pages_buildStages;

  /// No description provided for @pages_rollback.
  ///
  /// In en, this message translates to:
  /// **'Rollback'**
  String get pages_rollback;

  /// No description provided for @pages_rollbackConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Rollback Deployment'**
  String get pages_rollbackConfirmTitle;

  /// No description provided for @pages_rollbackConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to rollback to this deployment? This will make this deployment the current production version.'**
  String get pages_rollbackConfirmMessage;

  /// No description provided for @pages_rollbackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rollback successful'**
  String get pages_rollbackSuccess;

  /// No description provided for @pages_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pages_retry;

  /// No description provided for @pages_retryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Retry Deployment'**
  String get pages_retryConfirmTitle;

  /// No description provided for @pages_retryConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to retry this deployment? This will start a new build with the same configuration.'**
  String get pages_retryConfirmMessage;

  /// No description provided for @pages_retrySuccess.
  ///
  /// In en, this message translates to:
  /// **'Deployment retry started'**
  String get pages_retrySuccess;

  /// No description provided for @pages_autoDeployPaused.
  ///
  /// In en, this message translates to:
  /// **'Auto-deploy paused'**
  String get pages_autoDeployPaused;

  /// No description provided for @pages_buildLogs.
  ///
  /// In en, this message translates to:
  /// **'Build Logs'**
  String get pages_buildLogs;

  /// No description provided for @pages_noLogs.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get pages_noLogs;

  /// No description provided for @pages_autoScrollOn.
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll enabled'**
  String get pages_autoScrollOn;

  /// No description provided for @pages_autoScrollOff.
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll disabled'**
  String get pages_autoScrollOff;

  /// No description provided for @pages_logCount.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} lines'**
  String pages_logCount(int current, int total);

  /// No description provided for @pages_customDomains.
  ///
  /// In en, this message translates to:
  /// **'Custom Domains'**
  String get pages_customDomains;

  /// No description provided for @pages_addDomain.
  ///
  /// In en, this message translates to:
  /// **'Add Domain'**
  String get pages_addDomain;

  /// No description provided for @pages_deleteDomainConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Custom Domain?'**
  String get pages_deleteDomainConfirmTitle;

  /// No description provided for @pages_deleteDomainConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{domain}\"? This will disconnect it from your Pages project.'**
  String pages_deleteDomainConfirmMessage(String domain);

  /// No description provided for @pages_buildSettings.
  ///
  /// In en, this message translates to:
  /// **'Build Settings'**
  String get pages_buildSettings;

  /// No description provided for @pages_buildCommand.
  ///
  /// In en, this message translates to:
  /// **'Build Command'**
  String get pages_buildCommand;

  /// No description provided for @pages_outputDirectory.
  ///
  /// In en, this message translates to:
  /// **'Output Directory'**
  String get pages_outputDirectory;

  /// No description provided for @pages_rootDirectory.
  ///
  /// In en, this message translates to:
  /// **'Root Directory'**
  String get pages_rootDirectory;

  /// No description provided for @pages_environmentVariables.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get pages_environmentVariables;

  /// No description provided for @pages_productionEnv.
  ///
  /// In en, this message translates to:
  /// **'Production Environment'**
  String get pages_productionEnv;

  /// No description provided for @pages_previewEnv.
  ///
  /// In en, this message translates to:
  /// **'Preview Environment'**
  String get pages_previewEnv;

  /// No description provided for @pages_addVariable.
  ///
  /// In en, this message translates to:
  /// **'Add Variable'**
  String get pages_addVariable;

  /// No description provided for @pages_variableName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pages_variableName;

  /// No description provided for @pages_variableValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get pages_variableValue;

  /// No description provided for @pages_secret.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get pages_secret;

  /// No description provided for @pages_plainText.
  ///
  /// In en, this message translates to:
  /// **'Plain Text'**
  String get pages_plainText;

  /// No description provided for @pages_compatibilityDate.
  ///
  /// In en, this message translates to:
  /// **'Compatibility Date'**
  String get pages_compatibilityDate;

  /// No description provided for @pages_compatibilityFlags.
  ///
  /// In en, this message translates to:
  /// **'Compatibility Flags'**
  String get pages_compatibilityFlags;

  /// No description provided for @pages_saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get pages_saveSettings;

  /// No description provided for @pages_settingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully'**
  String get pages_settingsUpdated;

  /// No description provided for @pages_domainAdded.
  ///
  /// In en, this message translates to:
  /// **'Domain added successfully'**
  String get pages_domainAdded;

  /// No description provided for @pages_domainDeleted.
  ///
  /// In en, this message translates to:
  /// **'Domain deleted successfully'**
  String get pages_domainDeleted;

  /// No description provided for @pages_domainNameHint.
  ///
  /// In en, this message translates to:
  /// **'example.com'**
  String get pages_domainNameHint;

  /// No description provided for @pages_gitRepository.
  ///
  /// In en, this message translates to:
  /// **'Git Repository'**
  String get pages_gitRepository;

  /// No description provided for @pages_productionBranch.
  ///
  /// In en, this message translates to:
  /// **'Production Branch'**
  String get pages_productionBranch;

  /// No description provided for @pages_automaticDeployments.
  ///
  /// In en, this message translates to:
  /// **'Preview Deployments'**
  String get pages_automaticDeployments;

  /// No description provided for @pages_automaticDeploymentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatic deployments for preview branches'**
  String get pages_automaticDeploymentsDescription;

  /// No description provided for @pages_productionDeployments.
  ///
  /// In en, this message translates to:
  /// **'Production Deployments'**
  String get pages_productionDeployments;

  /// No description provided for @pages_productionDeploymentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatic deployments for production branch'**
  String get pages_productionDeploymentsDescription;

  /// No description provided for @pages_prComments.
  ///
  /// In en, this message translates to:
  /// **'PR Comments'**
  String get pages_prComments;

  /// No description provided for @pages_buildSystemVersion.
  ///
  /// In en, this message translates to:
  /// **'Build System Version'**
  String get pages_buildSystemVersion;

  /// No description provided for @pages_buildOutput.
  ///
  /// In en, this message translates to:
  /// **'Build Output'**
  String get pages_buildOutput;

  /// No description provided for @pages_buildComments.
  ///
  /// In en, this message translates to:
  /// **'Build Comments'**
  String get pages_buildComments;

  /// No description provided for @pages_buildCache.
  ///
  /// In en, this message translates to:
  /// **'Build Cache'**
  String get pages_buildCache;

  /// No description provided for @pages_buildWatchPaths.
  ///
  /// In en, this message translates to:
  /// **'Build Watch Paths'**
  String get pages_buildWatchPaths;

  /// No description provided for @pages_includePaths.
  ///
  /// In en, this message translates to:
  /// **'Include Paths'**
  String get pages_includePaths;

  /// No description provided for @pages_deployHooks.
  ///
  /// In en, this message translates to:
  /// **'Deploy Hooks'**
  String get pages_deployHooks;

  /// No description provided for @pages_noDeployHooks.
  ///
  /// In en, this message translates to:
  /// **'No deploy hooks defined'**
  String get pages_noDeployHooks;

  /// No description provided for @pages_runtime.
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get pages_runtime;

  /// No description provided for @pages_placement.
  ///
  /// In en, this message translates to:
  /// **'Placement'**
  String get pages_placement;

  /// No description provided for @pages_usageModel.
  ///
  /// In en, this message translates to:
  /// **'Usage Model'**
  String get pages_usageModel;

  /// No description provided for @pages_bindings.
  ///
  /// In en, this message translates to:
  /// **'Bindings'**
  String get pages_bindings;

  /// No description provided for @pages_addBinding.
  ///
  /// In en, this message translates to:
  /// **'Add Binding'**
  String get pages_addBinding;

  /// No description provided for @pages_variableType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get pages_variableType;

  /// No description provided for @pages_variableSecret.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get pages_variableSecret;

  /// No description provided for @pages_variablePlainText.
  ///
  /// In en, this message translates to:
  /// **'Plaintext'**
  String get pages_variablePlainText;

  /// No description provided for @pages_functionsBilling.
  ///
  /// In en, this message translates to:
  /// **'Pages Functions billing'**
  String get pages_functionsBilling;

  /// No description provided for @pages_cpuTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'CPU time limit'**
  String get pages_cpuTimeLimit;

  /// No description provided for @pages_accessPolicy.
  ///
  /// In en, this message translates to:
  /// **'Access policy'**
  String get pages_accessPolicy;

  /// No description provided for @pages_dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get pages_dangerZone;

  /// No description provided for @pages_deleteProject.
  ///
  /// In en, this message translates to:
  /// **'Delete Project'**
  String get pages_deleteProject;

  /// No description provided for @pages_deleteProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this Pages project including all deployments, assets, functions and configurations associated with it.'**
  String get pages_deleteProjectDescription;

  /// No description provided for @pages_deleteProjectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Project?'**
  String get pages_deleteProjectConfirmTitle;

  /// No description provided for @pages_deleteProjectConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {project}? This action cannot be undone and will delete all deployments.'**
  String pages_deleteProjectConfirmMessage(String project);

  /// No description provided for @pages_projectDeleted.
  ///
  /// In en, this message translates to:
  /// **'Project deleted successfully'**
  String get pages_projectDeleted;

  /// No description provided for @workers_title.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get workers_title;

  /// No description provided for @workers_noWorkers.
  ///
  /// In en, this message translates to:
  /// **'No Workers scripts found'**
  String get workers_noWorkers;

  /// No description provided for @workers_searchWorkers.
  ///
  /// In en, this message translates to:
  /// **'Search Workers...'**
  String get workers_searchWorkers;

  /// No description provided for @workers_lastModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified: {date}'**
  String workers_lastModified(String date);

  /// No description provided for @workers_tabs_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get workers_tabs_overview;

  /// No description provided for @workers_tabs_triggers.
  ///
  /// In en, this message translates to:
  /// **'Triggers'**
  String get workers_tabs_triggers;

  /// No description provided for @workers_tabs_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get workers_tabs_settings;

  /// No description provided for @workers_metrics_requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get workers_metrics_requests;

  /// No description provided for @workers_metrics_errors.
  ///
  /// In en, this message translates to:
  /// **'Exceptions'**
  String get workers_metrics_errors;

  /// No description provided for @workers_metrics_cpuTime.
  ///
  /// In en, this message translates to:
  /// **'CPU Time'**
  String get workers_metrics_cpuTime;

  /// No description provided for @workers_metrics_noData.
  ///
  /// In en, this message translates to:
  /// **'No metrics available for this period'**
  String get workers_metrics_noData;

  /// No description provided for @workers_triggers_customDomains.
  ///
  /// In en, this message translates to:
  /// **'Custom Domains'**
  String get workers_triggers_customDomains;

  /// No description provided for @workers_triggers_routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get workers_triggers_routes;

  /// No description provided for @workers_triggers_addRoute.
  ///
  /// In en, this message translates to:
  /// **'Add Route'**
  String get workers_triggers_addRoute;

  /// No description provided for @workers_triggers_addDomain.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Domain'**
  String get workers_triggers_addDomain;

  /// No description provided for @workers_triggers_routePattern.
  ///
  /// In en, this message translates to:
  /// **'Route Pattern'**
  String get workers_triggers_routePattern;

  /// No description provided for @workers_triggers_routePatternHint.
  ///
  /// In en, this message translates to:
  /// **'example.com/*'**
  String get workers_triggers_routePatternHint;

  /// No description provided for @workers_triggers_deleteRouteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this route?'**
  String get workers_triggers_deleteRouteConfirm;

  /// No description provided for @workers_triggers_deleteDomainConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to detach this custom domain?'**
  String get workers_triggers_deleteDomainConfirm;

  /// No description provided for @workers_triggers_routeAdded.
  ///
  /// In en, this message translates to:
  /// **'Route added successfully'**
  String get workers_triggers_routeAdded;

  /// No description provided for @workers_triggers_routeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Route deleted successfully'**
  String get workers_triggers_routeDeleted;

  /// No description provided for @workers_triggers_domainAdded.
  ///
  /// In en, this message translates to:
  /// **'Domain attached successfully'**
  String get workers_triggers_domainAdded;

  /// No description provided for @workers_triggers_domainDeleted.
  ///
  /// In en, this message translates to:
  /// **'Domain detached successfully'**
  String get workers_triggers_domainDeleted;

  /// No description provided for @workers_triggers_cron.
  ///
  /// In en, this message translates to:
  /// **'Cron Triggers'**
  String get workers_triggers_cron;

  /// No description provided for @workers_triggers_cronExpression.
  ///
  /// In en, this message translates to:
  /// **'Cron Expression'**
  String get workers_triggers_cronExpression;

  /// No description provided for @workers_triggers_cronFormat.
  ///
  /// In en, this message translates to:
  /// **'Format: Minute Hour Day Month Weekday'**
  String get workers_triggers_cronFormat;

  /// No description provided for @workers_triggers_deleteScheduleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this cron trigger?'**
  String get workers_triggers_deleteScheduleConfirm;

  /// No description provided for @workers_triggers_noRoutes.
  ///
  /// In en, this message translates to:
  /// **'No routes configured for this zone'**
  String get workers_triggers_noRoutes;

  /// No description provided for @workers_triggers_noSchedules.
  ///
  /// In en, this message translates to:
  /// **'No cron triggers configured'**
  String get workers_triggers_noSchedules;

  /// No description provided for @workers_triggers_domainManagedByCloudflare.
  ///
  /// In en, this message translates to:
  /// **'Domain must be managed by Cloudflare.'**
  String get workers_triggers_domainManagedByCloudflare;

  /// No description provided for @workers_triggers_zoneNotFound.
  ///
  /// In en, this message translates to:
  /// **'Zone not found for this hostname.'**
  String get workers_triggers_zoneNotFound;

  /// No description provided for @workers_settings_bindings.
  ///
  /// In en, this message translates to:
  /// **'Bindings'**
  String get workers_settings_bindings;

  /// No description provided for @workers_settings_variables.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get workers_settings_variables;

  /// No description provided for @workers_settings_compatibility.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get workers_settings_compatibility;

  /// No description provided for @workers_settings_usageModel.
  ///
  /// In en, this message translates to:
  /// **'Usage Model'**
  String get workers_settings_usageModel;

  /// No description provided for @workers_bindings_kv.
  ///
  /// In en, this message translates to:
  /// **'KV Namespace'**
  String get workers_bindings_kv;

  /// No description provided for @workers_bindings_r2.
  ///
  /// In en, this message translates to:
  /// **'R2 Bucket'**
  String get workers_bindings_r2;

  /// No description provided for @workers_bindings_d1.
  ///
  /// In en, this message translates to:
  /// **'D1 Database'**
  String get workers_bindings_d1;

  /// No description provided for @workers_bindings_do.
  ///
  /// In en, this message translates to:
  /// **'Durable Object'**
  String get workers_bindings_do;

  /// No description provided for @workers_bindings_service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get workers_bindings_service;

  /// No description provided for @workers_bindings_queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get workers_bindings_queue;

  /// No description provided for @workers_settings_addBinding.
  ///
  /// In en, this message translates to:
  /// **'Add Binding'**
  String get workers_settings_addBinding;

  /// No description provided for @workers_settings_bindingType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get workers_settings_bindingType;

  /// No description provided for @workers_settings_envVariable.
  ///
  /// In en, this message translates to:
  /// **'Environment Variable'**
  String get workers_settings_envVariable;

  /// No description provided for @workers_settings_bindingSecret.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get workers_settings_bindingSecret;

  /// No description provided for @workers_settings_updateSecret.
  ///
  /// In en, this message translates to:
  /// **'Update Secret'**
  String get workers_settings_updateSecret;

  /// No description provided for @workers_settings_secretValue.
  ///
  /// In en, this message translates to:
  /// **'Secret Value'**
  String get workers_settings_secretValue;

  /// No description provided for @workers_settings_secretHint.
  ///
  /// In en, this message translates to:
  /// **'Enter secret value (write-only)'**
  String get workers_settings_secretHint;

  /// No description provided for @workers_settings_observability.
  ///
  /// In en, this message translates to:
  /// **'Observability'**
  String get workers_settings_observability;

  /// No description provided for @workers_settings_logs.
  ///
  /// In en, this message translates to:
  /// **'Workers Logs'**
  String get workers_settings_logs;

  /// No description provided for @workers_settings_traces.
  ///
  /// In en, this message translates to:
  /// **'Workers Traces'**
  String get workers_settings_traces;

  /// No description provided for @workers_settings_logpush.
  ///
  /// In en, this message translates to:
  /// **'Logpush'**
  String get workers_settings_logpush;

  /// No description provided for @workers_settings_tail.
  ///
  /// In en, this message translates to:
  /// **'Tail Worker'**
  String get workers_settings_tail;

  /// No description provided for @workers_settings_tailDescription.
  ///
  /// In en, this message translates to:
  /// **'Stream real-time logs from your Worker'**
  String get workers_settings_tailDescription;

  /// No description provided for @workers_settings_deleteWorker.
  ///
  /// In en, this message translates to:
  /// **'Delete Worker'**
  String get workers_settings_deleteWorker;

  /// No description provided for @workers_settings_deleteWorkerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Worker? This action cannot be undone and will delete all files, configurations and deployments.'**
  String get workers_settings_deleteWorkerConfirm;

  /// No description provided for @workers_settings_domainsAndRoutes.
  ///
  /// In en, this message translates to:
  /// **'Domains & Routes'**
  String get workers_settings_domainsAndRoutes;

  /// No description provided for @workers_settings_build.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get workers_settings_build;

  /// No description provided for @workers_settings_gitIntegration.
  ///
  /// In en, this message translates to:
  /// **'Git Integration'**
  String get workers_settings_gitIntegration;

  /// No description provided for @workers_settings_gitIntegrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure CI/CD in Cloudflare Dashboard'**
  String get workers_settings_gitIntegrationDescription;

  /// No description provided for @workers_settings_noAccountSelected.
  ///
  /// In en, this message translates to:
  /// **'No account selected'**
  String get workers_settings_noAccountSelected;

  /// No description provided for @workers_tail_title.
  ///
  /// In en, this message translates to:
  /// **'Worker Tail Logs'**
  String get workers_tail_title;

  /// No description provided for @workers_tail_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get workers_tail_connected;

  /// No description provided for @workers_tail_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get workers_tail_connecting;

  /// No description provided for @workers_tail_disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get workers_tail_disconnected;

  /// No description provided for @workers_tail_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get workers_tail_start;

  /// No description provided for @workers_tail_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get workers_tail_stop;

  /// No description provided for @workers_tail_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear logs'**
  String get workers_tail_clear;

  /// No description provided for @workers_tail_autoScroll.
  ///
  /// In en, this message translates to:
  /// **'Auto-scroll'**
  String get workers_tail_autoScroll;

  /// No description provided for @workers_tail_filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get workers_tail_filterAll;

  /// No description provided for @workers_tail_filterLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get workers_tail_filterLog;

  /// No description provided for @workers_tail_filterWarn.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get workers_tail_filterWarn;

  /// No description provided for @workers_tail_filterError.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get workers_tail_filterError;

  /// No description provided for @workers_tail_logCount.
  ///
  /// In en, this message translates to:
  /// **'{count} logs'**
  String workers_tail_logCount(int count);

  /// No description provided for @workers_tail_noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet. Trigger your worker to see logs.'**
  String get workers_tail_noLogsYet;

  /// No description provided for @workers_tail_notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected. Click Start to begin tailing.'**
  String get workers_tail_notConnected;

  /// No description provided for @workers_settings_viewDomains.
  ///
  /// In en, this message translates to:
  /// **'View Domains'**
  String get workers_settings_viewDomains;

  /// No description provided for @workers_settings_viewRoutes.
  ///
  /// In en, this message translates to:
  /// **'View Routes'**
  String get workers_settings_viewRoutes;

  /// No description provided for @workers_settings_pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get workers_settings_pricing;
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
      <String>['en', 'pt', 'zh'].contains(locale.languageCode);

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
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
