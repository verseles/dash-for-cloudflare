import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/cloudflare_response.dart';
import '../../../features/auth/domain/models/account.dart';
import '../../../features/dns/domain/models/zone.dart';
import '../../../features/dns/domain/models/dns_record.dart';
import '../../../features/dns/domain/models/dns_settings.dart';
import '../../../features/pages/domain/models/pages_project.dart';
import '../../../features/pages/domain/models/pages_deployment.dart';
import '../../../features/pages/domain/models/pages_domain.dart';
import '../../../features/pages/domain/models/deployment_log.dart';
import '../../../features/workers/domain/models/worker.dart';
import '../../../features/workers/domain/models/worker_settings.dart';
import '../../../features/workers/domain/models/worker_route.dart';
import '../../../features/workers/domain/models/worker_schedule.dart';
import '../../../features/workers/domain/models/worker_domain.dart';

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

  /// Get deployment build logs
  @GET(
    '/accounts/{accountId}/pages/projects/{projectName}/deployments/{deploymentId}/history/logs',
  )
  Future<CloudflareResponse<DeploymentLogsResponse>> getDeploymentLogs(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName,
    @Path('deploymentId') String deploymentId,
  );

  // ============== PAGES PROJECTS MANAGEMENT ==============

  /// Update a Pages project (build_config, deployment_configs, etc.)
  @PATCH('/accounts/{accountId}/pages/projects/{projectName}')
  Future<CloudflareResponse<PagesProject>> patchPagesProject(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName,
    @Body() Map<String, dynamic> data,
  );

  /// Get custom domains for a Pages project
  @GET('/accounts/{accountId}/pages/projects/{projectName}/domains')
  Future<CloudflareResponse<List<PagesDomain>>> getPagesDomains(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName,
  );

  /// Add a custom domain to a Pages project
  @POST('/accounts/{accountId}/pages/projects/{projectName}/domains')
  Future<CloudflareResponse<PagesDomain>> addPagesDomain(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName,
    @Body() Map<String, dynamic> data,
  );

  /// Delete a custom domain from a Pages project
  @DELETE('/accounts/{accountId}/pages/projects/{projectName}/domains/{domainName}')
  Future<CloudflareResponse<DeleteResponse>> deletePagesDomain(
    @Path('accountId') String accountId,
    @Path('projectName') String projectName,
    @Path('domainName') String domainName,
  );

  // ============== WORKERS SCRIPTS ==============

  /// Get all Workers scripts for an account
  @GET('/accounts/{accountId}/workers/scripts')
  Future<CloudflareResponse<List<Worker>>> getWorkersScripts(
    @Path('accountId') String accountId,
  );

  /// Get settings for a specific Worker script
  @GET('/accounts/{accountId}/workers/scripts/{scriptName}/settings')
  Future<CloudflareResponse<WorkerSettings>> getWorkerSettings(
    @Path('accountId') String accountId,
    @Path('scriptName') String scriptName,
  );

  /// Get Schedules (cron triggers) for a specific Worker script
  @GET('/accounts/{accountId}/workers/scripts/{scriptName}/schedules')
  Future<CloudflareResponse<WorkerSchedulesResponse>> getWorkerSchedules(
    @Path('accountId') String accountId,
    @Path('scriptName') String scriptName,
  );

  /// Update Worker script settings (bindings, etc.)
  @PATCH('/accounts/{accountId}/workers/scripts/{scriptName}/settings')
  Future<CloudflareResponse<WorkerSettings>> patchWorkerSettings(
    @Path('accountId') String accountId,
    @Path('scriptName') String scriptName,
    @Body() Map<String, dynamic> data,
  );

  /// Create or update a Worker secret
  @PUT('/accounts/{accountId}/workers/scripts/{scriptName}/secrets')
  Future<CloudflareResponse<WorkerBinding>> updateWorkerSecret(
    @Path('accountId') String accountId,
    @Path('scriptName') String scriptName,
    @Body() Map<String, dynamic> data,
  );

  /// Get all Workers custom domains for an account
  @GET('/accounts/{accountId}/workers/domains')
  Future<CloudflareResponse<List<WorkerDomain>>> getWorkerDomains(
    @Path('accountId') String accountId,
  );

  /// Attach or update a Workers custom domain
  @PUT('/accounts/{accountId}/workers/domains')
  Future<CloudflareResponse<WorkerDomain>> attachWorkerDomain(
    @Path('accountId') String accountId,
    @Body() Map<String, dynamic> data,
  );

  /// Detach a Workers custom domain
  @DELETE('/accounts/{accountId}/workers/domains/{domainId}')
  Future<CloudflareResponse<DeleteResponse>> detachWorkerDomain(
    @Path('accountId') String accountId,
    @Path('domainId') String domainId,
  );

  // ============== WORKERS ROUTES ==============

  /// Get all Workers routes for a specific zone
  @GET('/zones/{zoneId}/workers/routes')
  Future<CloudflareResponse<List<WorkerRoute>>> getWorkerRoutes(
    @Path('zoneId') String zoneId,
  );

  /// Create a new Workers route for a specific zone
  @POST('/zones/{zoneId}/workers/routes')
  Future<CloudflareResponse<WorkerRoute>> createWorkerRoute(
    @Path('zoneId') String zoneId,
    @Body() Map<String, dynamic> data,
  );

  /// Delete a Workers route
  @DELETE('/zones/{zoneId}/workers/routes/{routeId}')
  Future<CloudflareResponse<DeleteResponse>> deleteWorkerRoute(
    @Path('zoneId') String zoneId,
    @Path('routeId') String routeId,
  );
}
