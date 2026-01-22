import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/cloudflare_response.dart';
import '../../../features/auth/domain/models/account.dart';
import '../../../features/dns/domain/models/zone.dart';
import '../../../features/dns/domain/models/dns_record.dart';
import '../../../features/dns/domain/models/dns_settings.dart';
import '../../../features/pages/domain/models/pages_project.dart';
import '../../../features/pages/domain/models/pages_deployment.dart';

part 'cloudflare_api.g.dart';

/// Cloudflare REST API client using Retrofit.
@RestApi()
abstract class CloudflareApi {
  factory CloudflareApi(Dio dio, {String baseUrl}) = _CloudflareApi;

  // ============== ACCOUNTS ==============

  /// Get all accounts the token has access to
  @GET('/accounts')
  Future<CloudflareResponse<List<Account>>> getAccounts({
    @Query('per_page') int perPage = 100,
    @Query('page') int page = 1,
  });

  // ============== ZONES ==============

  /// Get all zones (domains) with pagination
  @GET('/zones')
  Future<CloudflareResponse<List<Zone>>> getZones({
    @Query('per_page') int perPage = 100,
    @Query('page') int page = 1,
  });

  /// Get a single zone by ID
  @GET('/zones/{zoneId}')
  Future<CloudflareResponse<Zone>> getZone(@Path('zoneId') String zoneId);

  // ============== DNS RECORDS ==============

  /// Get all DNS records for a zone
  @GET('/zones/{zoneId}/dns_records')
  Future<CloudflareResponse<List<DnsRecord>>> getDnsRecords(
    @Path('zoneId') String zoneId, {
    @Query('per_page') int perPage = 100,
  });

  /// Get a single DNS record
  @GET('/zones/{zoneId}/dns_records/{recordId}')
  Future<CloudflareResponse<DnsRecord>> getDnsRecord(
    @Path('zoneId') String zoneId,
    @Path('recordId') String recordId,
  );

  /// Create a new DNS record
  @POST('/zones/{zoneId}/dns_records')
  Future<CloudflareResponse<DnsRecord>> createDnsRecord(
    @Path('zoneId') String zoneId,
    @Body() DnsRecordCreate record,
  );

  /// Update an existing DNS record (full update)
  @PUT('/zones/{zoneId}/dns_records/{recordId}')
  Future<CloudflareResponse<DnsRecord>> updateDnsRecord(
    @Path('zoneId') String zoneId,
    @Path('recordId') String recordId,
    @Body() DnsRecordCreate record,
  );

  /// Partially update a DNS record
  @PATCH('/zones/{zoneId}/dns_records/{recordId}')
  Future<CloudflareResponse<DnsRecord>> patchDnsRecord(
    @Path('zoneId') String zoneId,
    @Path('recordId') String recordId,
    @Body() Map<String, dynamic> data,
  );

  /// Delete a DNS record
  @DELETE('/zones/{zoneId}/dns_records/{recordId}')
  Future<CloudflareResponse<DeleteResponse>> deleteDnsRecord(
    @Path('zoneId') String zoneId,
    @Path('recordId') String recordId,
  );

  // ============== DNSSEC ==============

  /// Get DNSSEC details for a zone
  @GET('/zones/{zoneId}/dnssec')
  Future<CloudflareResponse<DnssecDetails>> getDnssec(
    @Path('zoneId') String zoneId,
  );

  /// Update DNSSEC settings (enable/disable, multi-signer)
  @PATCH('/zones/{zoneId}/dnssec')
  Future<CloudflareResponse<DnssecDetails>> updateDnssec(
    @Path('zoneId') String zoneId,
    @Body() Map<String, dynamic> data,
  );

  // ============== ZONE SETTINGS ==============

  /// Get all zone settings
  @GET('/zones/{zoneId}/settings')
  Future<CloudflareResponse<List<DnsSetting>>> getSettings(
    @Path('zoneId') String zoneId,
  );

  /// Update a specific zone setting
  @PATCH('/zones/{zoneId}/settings/{settingId}')
  Future<CloudflareResponse<DnsSetting>> updateSetting(
    @Path('zoneId') String zoneId,
    @Path('settingId') String settingId,
    @Body() Map<String, dynamic> data,
  );

  // ============== DNS ZONE SETTINGS ==============

  /// Get DNS-specific zone settings (multi-provider, etc.)
  @GET('/zones/{zoneId}/dns_settings')
  Future<CloudflareResponse<DnsZoneSettings>> getDnsZoneSettings(
    @Path('zoneId') String zoneId,
  );

  /// Update DNS-specific zone settings
  @PATCH('/zones/{zoneId}/dns_settings')
  Future<CloudflareResponse<DnsZoneSettings>> updateDnsZoneSettings(
    @Path('zoneId') String zoneId,
    @Body() Map<String, dynamic> data,
  );

  // ============== PAGES PROJECTS ==============

  /// Get Pages projects for an account (paginated, max 10 per page)
  /// Note: Pages API only accepts page parameter, per_page is fixed at 10
  @GET('/accounts/{accountId}/pages/projects')
  Future<CloudflareResponse<List<PagesProject>>> getPagesProjects(
    @Path('accountId') String accountId, {
    @Query('page') int page = 1,
  });

  /// Get a single Pages project by name
  @GET('/accounts/{accountId}/pages/projects/{projectName}')
  Future<CloudflareResponse<PagesProject>> getPagesProject(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName,
  );

  // ============== PAGES DEPLOYMENTS ==============

  /// Get all deployments for a Pages project
  @GET('/accounts/{accountId}/pages/projects/{projectName}/deployments')
  Future<CloudflareResponse<List<PagesDeployment>>> getPagesDeployments(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName, {
    @Query('per_page') int perPage = 25,
    @Query('page') int page = 1,
  });

  /// Get a single deployment
  @GET(
    '/accounts/{accountId}/pages/projects/{projectName}/deployments/{deploymentId}',
  )
  Future<CloudflareResponse<PagesDeployment>> getPagesDeployment(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName,
    @Path('deploymentId') String deploymentId,
  );

  /// Rollback to a specific deployment
  @POST(
    '/accounts/{accountId}/pages/projects/{projectName}/deployments/{deploymentId}/rollback',
  )
  Future<CloudflareResponse<PagesDeployment>> rollbackDeployment(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName,
    @Path('deploymentId') String deploymentId,
  );

  /// Retry a deployment
  @POST(
    '/accounts/{accountId}/pages/projects/{projectName}/deployments/{deploymentId}/retry',
  )
  Future<CloudflareResponse<PagesDeployment>> retryDeployment(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName,
    @Path('deploymentId') String deploymentId,
  );
}
