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
  String get common_add => 'Add';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_deleted => 'Deleted successfully';

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
  String get common_clearSearch => 'Clear search';

  @override
  String get common_clearFilters => 'Clear filters';

  @override
  String get common_all => 'All';

  @override
  String get common_none => 'None';

  @override
  String get common_proxy => 'Proxy';

  @override
  String get common_rootOnly => 'Root only';

  @override
  String get common_disable => 'Disable';

  @override
  String get menu_dns => 'DNS';

  @override
  String get menu_analytics => 'Analytics';

  @override
  String get menu_pages => 'Pages';

  @override
  String get menu_workers => 'Workers';

  @override
  String get menu_settings => 'Settings';

  @override
  String get menu_about => 'About';

  @override
  String get menu_debugLogs => 'Debug Logs';

  @override
  String get menu_selectZone => 'Select Zone';

  @override
  String get menu_noZones => 'No zones';

  @override
  String get tabs_records => 'Records';

  @override
  String get tabs_analytics => 'Analytics';

  @override
  String get tabs_settings => 'Settings';

  @override
  String get tabs_web => 'Web';

  @override
  String get tabs_security => 'Security';

  @override
  String get tabs_cache => 'Cache';

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
  String get dns_deleteRecordConfirmTitle => 'Delete Record?';

  @override
  String dns_deleteRecordConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

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
  String get analytics_requests => 'Requests';

  @override
  String get analytics_bandwidth => 'Bandwidth';

  @override
  String get analytics_uniqueVisitors => 'Unique Visitors';

  @override
  String get analytics_requestsByStatus => 'Requests by Status';

  @override
  String get analytics_requestsByCountry => 'Requests by Country';

  @override
  String get analytics_geographicDistribution => 'Geographic Distribution';

  @override
  String get analytics_requestsByProtocol => 'Requests by Protocol';

  @override
  String get analytics_requestsByHost => 'Requests by Host';

  @override
  String get analytics_topPaths => 'Top Paths';

  @override
  String get analytics_threatsStopped => 'Threats Stopped';

  @override
  String get analytics_totalThreatsBlocked => 'Total Threats Blocked';

  @override
  String get analytics_actionsTaken => 'Actions Taken';

  @override
  String get analytics_threatsByCountry => 'Threats by Country';

  @override
  String get analytics_topThreatSources => 'Top Threat Sources';

  @override
  String get analytics_threatOrigins => 'Threat Origins';

  @override
  String get analytics_cacheHitRatio => 'Cache Hit Ratio';

  @override
  String get analytics_bandwidthSaved => 'Bandwidth Saved';

  @override
  String get analytics_requestsCacheVsOrigin => 'Requests (Cache vs Origin)';

  @override
  String get analytics_bandwidthCacheVsOrigin => 'Bandwidth (Cache vs Origin)';

  @override
  String get analytics_cacheStatusByHttpStatus => 'Cache Status by HTTP Status';

  @override
  String get analytics_securityRequiresPaidPlan =>
      'Security Analytics requires a paid Cloudflare plan (Pro or higher).';

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
  String get dnsSettings_disableDnssecTitle => 'Disable DNSSEC?';

  @override
  String get dnsSettings_cancelDeactivation => 'Cancel Deactivation';

  @override
  String get emailSecurity_spfExists => 'SPF record already configured';

  @override
  String get emailSecurity_spfNotConfigured => 'SPF not configured';

  @override
  String get emailSecurity_spfDescription =>
      'Sender Policy Framework (SPF) specifies which mail servers are authorized to send email on behalf of your domain.';

  @override
  String get emailSecurity_spfIncludes => 'Authorized Senders (includes)';

  @override
  String get emailSecurity_spfIncludesHint =>
      'e.g., _spf.google.com sendgrid.net';

  @override
  String get emailSecurity_spfPolicy => 'Policy (All)';

  @override
  String get emailSecurity_spfPolicyHint =>
      '~all (soft fail), -all (hard fail), or +all (allow)';

  @override
  String get emailSecurity_spfSaved => 'SPF record saved successfully';

  @override
  String get emailSecurity_dkimExists => 'DKIM record already configured';

  @override
  String get emailSecurity_dkimNotConfigured => 'DKIM not configured';

  @override
  String get emailSecurity_dkimDescription =>
      'DomainKeys Identified Mail (DKIM) adds a digital signature to your emails to verify they haven\'t been tampered with.';

  @override
  String get emailSecurity_dkimSelector => 'Selector';

  @override
  String get emailSecurity_dkimSelectorHint => 'e.g., default, google, mailgun';

  @override
  String get emailSecurity_dkimPublicKey => 'Public Key (p=)';

  @override
  String get emailSecurity_dkimPublicKeyHint =>
      'Paste the public key provided by your email provider (without v=DKIM1; k=rsa; p= prefix)';

  @override
  String get emailSecurity_dkimPublicKeyRequired => 'Public key is required';

  @override
  String get emailSecurity_dkimSaved => 'DKIM record saved successfully';

  @override
  String get emailSecurity_dmarcExists => 'DMARC record already configured';

  @override
  String get emailSecurity_dmarcNotConfigured => 'DMARC not configured';

  @override
  String get emailSecurity_dmarcDescription =>
      'Domain-based Message Authentication, Reporting & Conformance (DMARC) tells receiving mail servers what to do when SPF or DKIM checks fail.';

  @override
  String get emailSecurity_dmarcPolicy => 'Policy';

  @override
  String get emailSecurity_dmarcPolicyHint =>
      'Action to take on authentication failure';

  @override
  String get emailSecurity_dmarcPolicyNone => 'None (Monitor only)';

  @override
  String get emailSecurity_dmarcPolicyQuarantine => 'Quarantine (Mark as spam)';

  @override
  String get emailSecurity_dmarcPolicyReject => 'Reject (Block delivery)';

  @override
  String get emailSecurity_dmarcRua => 'Aggregate Reports Email (rua)';

  @override
  String get emailSecurity_dmarcRuaHint => 'e.g., dmarc-reports@yourdomain.com';

  @override
  String get emailSecurity_dmarcRuf => 'Forensic Reports Email (ruf)';

  @override
  String get emailSecurity_dmarcRufHint => 'Optional: forensic failure reports';

  @override
  String get emailSecurity_dmarcPct => 'Percentage of emails to filter';

  @override
  String get emailSecurity_dmarcSaved => 'DMARC record saved successfully';

  @override
  String get emailSecurity_preview => 'Preview';

  @override
  String get emailSecurity_recordName => 'Record Name';

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
  String error_prefix(String message) {
    return 'Error: $message';
  }

  @override
  String get error_copyError => 'Copy Error Details';

  @override
  String get error_permissionsRequired => 'Permissions Required';

  @override
  String get error_permissionsDescription =>
      'Your API token doesn\'t have the necessary permissions to access this resource. Please check your token settings on Cloudflare.';

  @override
  String get error_checkCloudflareDashboard => 'Check Cloudflare Dashboard';

  @override
  String get error_commonPermissionsTitle => 'Commonly required permissions:';

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

  @override
  String get debugLogs_title => 'Debug Logs';

  @override
  String get debugLogs_copyAll => 'Copy All';

  @override
  String get debugLogs_saveToFile => 'Save to File';

  @override
  String get debugLogs_shareAsText => 'Share as Text';

  @override
  String get debugLogs_shareAsFile => 'Share as File';

  @override
  String get debugLogs_clearLogs => 'Clear Logs';

  @override
  String get debugLogs_logsCopied => 'Logs copied to clipboard';

  @override
  String debugLogs_savedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String debugLogs_failedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String debugLogs_failedToShare(String error) {
    return 'Failed to share: $error';
  }

  @override
  String debugLogs_copyTimeRange(String timeRange) {
    return 'Copy $timeRange';
  }

  @override
  String get debugLogs_logEntryCopied => 'Log entry copied';

  @override
  String get debugLogs_timeRange => 'Time Range:';

  @override
  String get debugLogs_filter => 'Filter:';

  @override
  String debugLogs_entries(int count) {
    return '$count entries';
  }

  @override
  String get debugLogs_noLogsInRange => 'No logs in this time range';

  @override
  String get debugLogs_tryLongerRange => 'Try selecting a longer time range';

  @override
  String get debugLogs_autoScrollOn => 'Auto-scroll ON';

  @override
  String get debugLogs_autoScrollOff => 'Auto-scroll OFF';

  @override
  String get dnsRecord_createTitle => 'Create DNS Record';

  @override
  String get dnsRecord_editTitle => 'Edit DNS Record';

  @override
  String get dnsRecord_recordCreated => 'Record created';

  @override
  String get dnsRecord_recordUpdated => 'Record updated';

  @override
  String get dnsRecord_ttlAuto => 'Auto';

  @override
  String get dnsRecord_ttl2min => '2 minutes';

  @override
  String get dnsRecord_ttl5min => '5 minutes';

  @override
  String get dnsRecord_ttl10min => '10 minutes';

  @override
  String get dnsRecord_ttl15min => '15 minutes';

  @override
  String get dnsRecord_ttl30min => '30 minutes';

  @override
  String get dnsRecord_ttl1hour => '1 hour';

  @override
  String get dnsRecord_ttl2hours => '2 hours';

  @override
  String get dnsRecord_ttl5hours => '5 hours';

  @override
  String get dnsRecord_ttl12hours => '12 hours';

  @override
  String get dnsRecord_ttl1day => '1 day';

  @override
  String get dnsRecord_enterValue => 'Enter value';

  @override
  String emptyState_noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get emptyState_tryAdjustingSearch => 'Try adjusting your search terms';

  @override
  String get pages_title => 'Pages';

  @override
  String get pages_selectAccount => 'Select account';

  @override
  String get pages_noProjects => 'No Pages projects found';

  @override
  String pages_lastDeployment(String date) {
    return 'Last deployed: $date';
  }

  @override
  String get pages_statusSuccess => 'Success';

  @override
  String get pages_statusFailed => 'Failed';

  @override
  String get pages_statusBuilding => 'Building';

  @override
  String get pages_statusQueued => 'Queued';

  @override
  String get pages_statusSkipped => 'Skipped';

  @override
  String get pages_statusUnknown => 'Unknown';

  @override
  String get pages_openInBrowser => 'Open in browser';

  @override
  String get pages_deployments => 'Deployments';

  @override
  String get pages_noDeployments => 'No deployments found';

  @override
  String get pages_production => 'Production';

  @override
  String get pages_preview => 'Preview';

  @override
  String get pages_deploymentDetails => 'Deployment Details';

  @override
  String get pages_commitInfo => 'Commit Information';

  @override
  String get pages_buildStages => 'Build Stages';

  @override
  String get pages_rollback => 'Rollback';

  @override
  String get pages_rollbackConfirmTitle => 'Rollback Deployment';

  @override
  String get pages_rollbackConfirmMessage =>
      'Are you sure you want to rollback to this deployment? This will make this deployment the current production version.';

  @override
  String get pages_rollbackSuccess => 'Rollback successful';

  @override
  String get pages_retry => 'Retry';

  @override
  String get pages_retryConfirmTitle => 'Retry Deployment';

  @override
  String get pages_retryConfirmMessage =>
      'Are you sure you want to retry this deployment? This will start a new build with the same configuration.';

  @override
  String get pages_retrySuccess => 'Deployment retry started';

  @override
  String get pages_autoDeployPaused => 'Auto-deploy paused';

  @override
  String get pages_buildLogs => 'Build Logs';

  @override
  String get pages_noLogs => 'No logs available';

  @override
  String get pages_autoScrollOn => 'Auto-scroll enabled';

  @override
  String get pages_autoScrollOff => 'Auto-scroll disabled';

  @override
  String pages_logCount(int current, int total) {
    return '$current of $total lines';
  }

  @override
  String get pages_customDomains => 'Custom Domains';

  @override
  String get pages_addDomain => 'Add Domain';

  @override
  String get pages_deleteDomainConfirmTitle => 'Delete Custom Domain?';

  @override
  String pages_deleteDomainConfirmMessage(String domain) {
    return 'Are you sure you want to delete \"$domain\"? This will disconnect it from your Pages project.';
  }

  @override
  String get pages_buildSettings => 'Build Settings';

  @override
  String get pages_buildCommand => 'Build Command';

  @override
  String get pages_outputDirectory => 'Output Directory';

  @override
  String get pages_rootDirectory => 'Root Directory';

  @override
  String get pages_environmentVariables => 'Environment Variables';

  @override
  String get pages_productionEnv => 'Production Environment';

  @override
  String get pages_previewEnv => 'Preview Environment';

  @override
  String get pages_addVariable => 'Add Variable';

  @override
  String get pages_variableName => 'Name';

  @override
  String get pages_variableValue => 'Value';

  @override
  String get pages_secret => 'Secret';

  @override
  String get pages_plainText => 'Plain Text';

  @override
  String get pages_compatibilityDate => 'Compatibility Date';

  @override
  String get pages_compatibilityFlags => 'Compatibility Flags';

  @override
  String get pages_saveSettings => 'Save Settings';

  @override
  String get pages_settingsUpdated => 'Settings updated successfully';

  @override
  String get pages_domainAdded => 'Domain added successfully';

  @override
  String get pages_domainDeleted => 'Domain deleted successfully';

  @override
  String get pages_domainNameHint => 'example.com';

  @override
  String get pages_gitRepository => 'Git Repository';

  @override
  String get pages_productionBranch => 'Production Branch';

  @override
  String get pages_automaticDeployments => 'Preview Deployments';

  @override
  String get pages_automaticDeploymentsDescription =>
      'Automatic deployments for preview branches';

  @override
  String get pages_productionDeployments => 'Production Deployments';

  @override
  String get pages_productionDeploymentsDescription =>
      'Automatic deployments for production branch';

  @override
  String get pages_prComments => 'PR Comments';

  @override
  String get pages_buildSystemVersion => 'Build System Version';

  @override
  String get pages_buildOutput => 'Build Output';

  @override
  String get pages_buildComments => 'Build Comments';

  @override
  String get pages_buildCache => 'Build Cache';

  @override
  String get pages_buildWatchPaths => 'Build Watch Paths';

  @override
  String get pages_includePaths => 'Include Paths';

  @override
  String get pages_deployHooks => 'Deploy Hooks';

  @override
  String get pages_noDeployHooks => 'No deploy hooks defined';

  @override
  String get pages_runtime => 'Runtime';

  @override
  String get pages_placement => 'Placement';

  @override
  String get pages_usageModel => 'Usage Model';

  @override
  String get pages_bindings => 'Bindings';

  @override
  String get pages_addBinding => 'Add Binding';

  @override
  String get pages_variableType => 'Type';

  @override
  String get pages_variableSecret => 'Secret';

  @override
  String get pages_variablePlainText => 'Plaintext';

  @override
  String get pages_functionsBilling => 'Pages Functions billing';

  @override
  String get pages_cpuTimeLimit => 'CPU time limit';

  @override
  String get pages_accessPolicy => 'Access policy';

  @override
  String get pages_dangerZone => 'Danger Zone';

  @override
  String get pages_deleteProject => 'Delete Project';

  @override
  String get pages_deleteProjectDescription =>
      'Permanently delete this Pages project including all deployments, assets, functions and configurations associated with it.';

  @override
  String get pages_deleteProjectConfirmTitle => 'Delete Project?';

  @override
  String pages_deleteProjectConfirmMessage(String project) {
    return 'Are you sure you want to delete $project? This action cannot be undone and will delete all deployments.';
  }

  @override
  String get pages_projectDeleted => 'Project deleted successfully';

  @override
  String get workers_title => 'Workers';

  @override
  String get workers_noWorkers => 'No Workers scripts found';

  @override
  String get workers_searchWorkers => 'Search Workers...';

  @override
  String workers_lastModified(String date) {
    return 'Last modified: $date';
  }

  @override
  String get workers_tabs_overview => 'Overview';

  @override
  String get workers_tabs_triggers => 'Triggers';

  @override
  String get workers_tabs_settings => 'Settings';

  @override
  String get workers_metrics_requests => 'Requests';

  @override
  String get workers_metrics_errors => 'Exceptions';

  @override
  String get workers_metrics_cpuTime => 'CPU Time';

  @override
  String get workers_metrics_noData => 'No metrics available for this period';

  @override
  String get workers_triggers_customDomains => 'Custom Domains';

  @override
  String get workers_triggers_routes => 'Routes';

  @override
  String get workers_triggers_addRoute => 'Add Route';

  @override
  String get workers_triggers_addDomain => 'Add Custom Domain';

  @override
  String get workers_triggers_routePattern => 'Route Pattern';

  @override
  String get workers_triggers_routePatternHint => 'example.com/*';

  @override
  String get workers_triggers_deleteRouteConfirm =>
      'Are you sure you want to delete this route?';

  @override
  String get workers_triggers_deleteDomainConfirm =>
      'Are you sure you want to detach this custom domain?';

  @override
  String get workers_triggers_routeAdded => 'Route added successfully';

  @override
  String get workers_triggers_routeDeleted => 'Route deleted successfully';

  @override
  String get workers_triggers_domainAdded => 'Domain attached successfully';

  @override
  String get workers_triggers_domainDeleted => 'Domain detached successfully';

  @override
  String get workers_triggers_cron => 'Cron Triggers';

  @override
  String get workers_triggers_cronExpression => 'Cron Expression';

  @override
  String get workers_triggers_cronFormat =>
      'Format: Minute Hour Day Month Weekday';

  @override
  String get workers_triggers_deleteScheduleConfirm =>
      'Are you sure you want to remove this cron trigger?';

  @override
  String get workers_triggers_noRoutes => 'No routes configured for this zone';

  @override
  String get workers_triggers_noSchedules => 'No cron triggers configured';

  @override
  String get workers_triggers_domainManagedByCloudflare =>
      'Domain must be managed by Cloudflare.';

  @override
  String get workers_triggers_zoneNotFound =>
      'Zone not found for this hostname.';

  @override
  String get workers_settings_bindings => 'Bindings';

  @override
  String get workers_settings_variables => 'Environment Variables';

  @override
  String get workers_settings_compatibility => 'Compatibility';

  @override
  String get workers_settings_usageModel => 'Usage Model';

  @override
  String get workers_bindings_kv => 'KV Namespace';

  @override
  String get workers_bindings_r2 => 'R2 Bucket';

  @override
  String get workers_bindings_d1 => 'D1 Database';

  @override
  String get workers_bindings_do => 'Durable Object';

  @override
  String get workers_bindings_service => 'Service';

  @override
  String get workers_bindings_queue => 'Queue';

  @override
  String get workers_settings_addBinding => 'Add Binding';

  @override
  String get workers_settings_bindingType => 'Type';

  @override
  String get workers_settings_envVariable => 'Environment Variable';

  @override
  String get workers_settings_bindingSecret => 'Secret';

  @override
  String get workers_settings_updateSecret => 'Update Secret';

  @override
  String get workers_settings_secretValue => 'Secret Value';

  @override
  String get workers_settings_secretHint => 'Enter secret value (write-only)';

  @override
  String get workers_settings_observability => 'Observability';

  @override
  String get workers_settings_logs => 'Workers Logs';

  @override
  String get workers_settings_traces => 'Workers Traces';

  @override
  String get workers_settings_logpush => 'Logpush';

  @override
  String get workers_settings_tail => 'Tail Worker';

  @override
  String get workers_settings_tailDescription =>
      'Stream real-time logs from your Worker';

  @override
  String get workers_settings_deleteWorker => 'Delete Worker';

  @override
  String get workers_settings_deleteWorkerConfirm =>
      'Are you sure you want to delete this Worker? This action cannot be undone and will delete all files, configurations and deployments.';

  @override
  String get workers_settings_domainsAndRoutes => 'Domains & Routes';

  @override
  String get workers_settings_build => 'Build';

  @override
  String get workers_settings_gitIntegration => 'Git Integration';

  @override
  String get workers_settings_gitIntegrationDescription =>
      'Configure CI/CD in Cloudflare Dashboard';

  @override
  String get workers_settings_noAccountSelected => 'No account selected';

  @override
  String get workers_tail_title => 'Worker Tail Logs';

  @override
  String get workers_tail_connected => 'Connected';

  @override
  String get workers_tail_connecting => 'Connecting...';

  @override
  String get workers_tail_disconnected => 'Disconnected';

  @override
  String get workers_tail_start => 'Start';

  @override
  String get workers_tail_stop => 'Stop';

  @override
  String get workers_tail_clear => 'Clear logs';

  @override
  String get workers_tail_autoScroll => 'Auto-scroll';

  @override
  String get workers_tail_filterAll => 'All';

  @override
  String get workers_tail_filterLog => 'Log';

  @override
  String get workers_tail_filterWarn => 'Warnings';

  @override
  String get workers_tail_filterError => 'Errors';

  @override
  String workers_tail_logCount(int count) {
    return '$count logs';
  }

  @override
  String get workers_tail_noLogsYet =>
      'No logs yet. Trigger your worker to see logs.';

  @override
  String get workers_tail_notConnected =>
      'Not connected. Click Start to begin tailing.';

  @override
  String get workers_settings_viewDomains => 'View Domains';

  @override
  String get workers_settings_viewRoutes => 'View Routes';

  @override
  String get workers_settings_pricing => 'Pricing';
}
