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
  String get common_cancel => 'Cancel';

  @override
  String get common_close => 'Close';

  @override
  String get common_copied => 'Copied to clipboard';

  @override
  String get common_copy => 'Copy';

  @override
  String get common_copyFailed => 'Failed to copy';

  @override
  String get common_create => 'Create';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_error => 'Error';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_noData => 'No data available';

  @override
  String get common_ok => 'OK';

  @override
  String get common_refresh => 'Refresh';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_save => 'Save';

  @override
  String get common_workInProgress =>
      'Work in progress. This feature will be available soon!';

  @override
  String get menu_dns => 'DNS';

  @override
  String get menu_settings => 'Settings';

  @override
  String get menu_about => 'About';

  @override
  String get tabs_records => 'Records';

  @override
  String get tabs_analytics => 'Analytics';

  @override
  String get tabs_settings => 'Settings';

  @override
  String get zone_selectZone => 'Select a zone';

  @override
  String get zone_searchZones => 'Search zones...';

  @override
  String get zone_noZones => 'No zones found';

  @override
  String get zone_status_active => 'Active';

  @override
  String get zone_status_pending => 'Pending';

  @override
  String get zone_status_initializing => 'Initializing';

  @override
  String get zone_status_moved => 'Moved';

  @override
  String get zone_status_deleted => 'Deleted';

  @override
  String get zone_status_deactivated => 'Deactivated';

  @override
  String get dns_records => 'DNS Records';

  @override
  String get dns_filterAll => 'All';

  @override
  String get dns_searchRecords => 'Search records...';

  @override
  String get dns_noRecords => 'No DNS records';

  @override
  String get dns_noRecordsDescription => 'Add a DNS record to get started';

  @override
  String get dns_noRecordsMatch => 'No records match your filter';

  @override
  String get dns_selectZoneFirst => 'Select a zone to view records';

  @override
  String get dns_addRecord => 'Add Record';

  @override
  String get dns_editRecord => 'Edit Record';

  @override
  String get dns_deleteRecord => 'Delete Record';

  @override
  String get dns_deleteConfirmTitle => 'Delete DNS Record?';

  @override
  String dns_deleteConfirmMessage(String name) {
    return 'Are you sure you want to delete $name? This action cannot be undone.';
  }

  @override
  String get dns_recordSaved => 'Record saved successfully';

  @override
  String get dns_recordDeleted => 'Record deleted successfully';

  @override
  String get dns_recordDeletedUndo => 'Record deleted. Tap to undo.';

  @override
  String get record_type => 'Type';

  @override
  String get record_name => 'Name';

  @override
  String get record_nameHint => 'Name or @ for root';

  @override
  String get record_nameRequired => 'Name is required';

  @override
  String get record_content => 'Content';

  @override
  String get record_contentRequired => 'Content is required';

  @override
  String get record_ttl => 'TTL';

  @override
  String get record_ttlAuto => 'Auto';

  @override
  String get record_priority => 'Priority';

  @override
  String get record_proxied => 'Proxied';

  @override
  String get record_proxiedTooltip => 'Proxied through Cloudflare';

  @override
  String get record_dnsOnly => 'DNS only';

  @override
  String get record_dnsOnlyTooltip => 'DNS only (not proxied)';

  @override
  String get analytics_title => 'DNS Analytics';

  @override
  String get analytics_selectZone => 'Select a zone to view analytics';

  @override
  String get analytics_noData => 'No analytics data';

  @override
  String get analytics_loadAnalytics => 'Load Analytics';

  @override
  String get analytics_timeRange30m => '30m';

  @override
  String get analytics_timeRange6h => '6h';

  @override
  String get analytics_timeRange12h => '12h';

  @override
  String get analytics_timeRange24h => '24h';

  @override
  String get analytics_timeRange7d => '7d';

  @override
  String get analytics_timeRange30d => '30d';

  @override
  String get analytics_totalQueries => 'Total Queries';

  @override
  String get analytics_topQueryNames => 'Top Query Names';

  @override
  String get analytics_clearSelection => 'Clear selection';

  @override
  String get analytics_total => 'Total';

  @override
  String get analytics_queryTypes => 'Query Types';

  @override
  String get analytics_dataCenters => 'Data Centers';

  @override
  String get analytics_queriesOverTime => 'Queries Over Time';

  @override
  String get analytics_queriesByDataCenter => 'Queries by Data Center';

  @override
  String get analytics_queriesByLocation => 'Queries by Location';

  @override
  String get analytics_queriesByRecordType => 'Queries by Record Type';

  @override
  String get analytics_queriesByResponseCode => 'Queries by Response Code';

  @override
  String get analytics_queriesByIpVersion => 'Queries by IP Version';

  @override
  String get analytics_queriesByProtocol => 'Queries by Protocol';

  @override
  String get analytics_topQueryNamesChart => 'Top Query Names';

  @override
  String get dnsSettings_title => 'DNS Settings';

  @override
  String get dnsSettings_dnssec => 'DNSSEC';

  @override
  String get dnsSettings_dnssecDescription =>
      'DNS Security Extensions adds a layer of security by signing DNS records. This helps protect your domain from DNS spoofing and cache poisoning attacks.';

  @override
  String get dnsSettings_dnssecDisabled => 'DNSSEC is disabled';

  @override
  String get dnsSettings_dnssecPending => 'DNSSEC is pending activation';

  @override
  String get dnsSettings_dnssecPendingCf =>
      'DNSSEC will be configured automatically by Cloudflare Registrar';

  @override
  String get dnsSettings_dnssecActive => 'DNSSEC is active';

  @override
  String get dnsSettings_dnssecPendingDisable =>
      'DNSSEC is pending deactivation';

  @override
  String get dnsSettings_enableDnssec => 'Enable DNSSEC';

  @override
  String get dnsSettings_disableDnssec => 'Disable DNSSEC';

  @override
  String get dnsSettings_cancelDnssec => 'Cancel';

  @override
  String get dnsSettings_viewDetails => 'View Details';

  @override
  String get dnsSettings_viewDsRecord => 'View DS Record';

  @override
  String get dnsSettings_dsRecord => 'DS Record';

  @override
  String get dnsSettings_copyDsRecord => 'Copy DS Record';

  @override
  String get dnsSettings_dsRecordCopied => 'DS record copied to clipboard';

  @override
  String get dnsSettings_addDsToRegistrar =>
      'Add this DS record to your domain registrar to complete DNSSEC setup:';

  @override
  String get dnsSettings_multiSignerDnssec => 'Multi-signer DNSSEC';

  @override
  String get dnsSettings_multiSignerDescription =>
      'Allows multiple DNS providers to sign your zone';

  @override
  String get dnsSettings_multiProviderDns => 'Multi-provider DNS';

  @override
  String get dnsSettings_multiProviderDescription =>
      'Enable secondary DNS with other providers';

  @override
  String get dnsSettings_cnameFlattening => 'CNAME Flattening';

  @override
  String get dnsSettings_cnameFlatteningDescription =>
      'Flatten CNAME records at the zone apex';

  @override
  String get dnsSettings_cnameFlattenNone => 'None';

  @override
  String get dnsSettings_cnameFlattenAtRoot => 'Flatten at root';

  @override
  String get dnsSettings_cnameFlattenAll => 'Flatten all';

  @override
  String get dnsSettings_emailSecurity => 'Email Security';

  @override
  String get dnsSettings_emailSecurityDescription =>
      'Configure DMARC, SPF, and DKIM records for email authentication';

  @override
  String get dnsSettings_configureEmail => 'Configure';

  @override
  String get dnssecDetails_title => 'DNSSEC Details';

  @override
  String get dnssecDetails_dsRecord => 'DS Record';

  @override
  String get dnssecDetails_digest => 'Digest';

  @override
  String get dnssecDetails_digestType => 'Digest Type';

  @override
  String get dnssecDetails_algorithm => 'Algorithm';

  @override
  String get dnssecDetails_publicKey => 'Public Key';

  @override
  String get dnssecDetails_keyTag => 'Key Tag';

  @override
  String get dnssecDetails_keyType => 'Key Type';

  @override
  String get dnssecDetails_flags => 'Flags';

  @override
  String get dnssecDetails_modifiedOn => 'Modified On';

  @override
  String get dnssecDetails_tapToCopy => 'Tap to copy';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_apiToken => 'API Token';

  @override
  String get settings_apiTokenHint => 'Enter your Cloudflare API token';

  @override
  String get settings_apiTokenDescription =>
      'Your API token needs the following permissions:';

  @override
  String get settings_apiTokenPermission1 => 'Zone:Read - to list your zones';

  @override
  String get settings_apiTokenPermission2 => 'DNS:Edit - to manage DNS records';

  @override
  String get settings_apiTokenPermission3 =>
      'Zone Settings:Read - for DNSSEC status';

  @override
  String get settings_apiTokenPermission4 =>
      'Zone Settings:Edit - to toggle DNSSEC';

  @override
  String get settings_apiTokenPermission5 =>
      'Analytics:Read - for DNS analytics';

  @override
  String get settings_createToken => 'Create a token at dash.cloudflare.com';

  @override
  String get settings_tokenValid => 'Token is valid';

  @override
  String get settings_tokenInvalid => 'Token must be at least 40 characters';

  @override
  String get settings_tokenSaved => 'Token saved';

  @override
  String get settings_goToDns => 'Go to DNS';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_themeSystem => 'System';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_languagePt => 'Português';

  @override
  String get settings_about => 'About';

  @override
  String settings_version(String version) {
    return 'Version $version';
  }

  @override
  String get error_generic => 'Something went wrong';

  @override
  String get error_network => 'Network error. Please check your connection.';

  @override
  String get error_unauthorized => 'Invalid or expired API token';

  @override
  String get error_forbidden =>
      'You don\'t have permission to access this resource';

  @override
  String get error_notFound => 'Resource not found';

  @override
  String get error_rateLimited => 'Too many requests. Please try again later.';

  @override
  String get error_serverError => 'Server error. Please try again later.';

  @override
  String get pwa_updateAvailable => 'A new version is available';

  @override
  String get pwa_updateNow => 'Update Now';

  @override
  String get pwa_installApp => 'Install App';

  @override
  String get pwa_installDescription =>
      'Install Dash for Cloudflare for quick access';

  @override
  String get settings_cloudflareApiToken => 'Cloudflare API Token';

  @override
  String get settings_requiredPermissions =>
      'Required permissions: Zone:Read, DNS:Read, DNS:Edit';

  @override
  String get settings_createTokenOnCloudflare => 'Create token on Cloudflare';

  @override
  String get settings_tokenPastedFromClipboard => 'Token pasted from clipboard';

  @override
  String get settings_storage => 'Storage';

  @override
  String get settings_clearCache => 'Clear Cache';

  @override
  String get settings_clearCacheDescription =>
      'DNS records, analytics, and data centers';

  @override
  String get settings_clearCacheTitle => 'Clear Cache';

  @override
  String get settings_clearCacheMessage =>
      'This will clear all cached data including DNS records, analytics, and data center information.\n\nData will be reloaded from the API on next access.';

  @override
  String get settings_cacheCleared => 'Cache cleared successfully';

  @override
  String get settings_debug => 'Debug';

  @override
  String get settings_saveLogsToFile => 'Save logs to file';

  @override
  String get settings_saveLogsDescription => 'Persists logs for later analysis';

  @override
  String get settings_viewDebugLogs => 'View Debug Logs';

  @override
  String get settings_goToDnsManagement => 'Go to DNS Management';
}
