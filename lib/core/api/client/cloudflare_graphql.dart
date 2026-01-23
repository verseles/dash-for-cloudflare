import 'package:dio/dio.dart';
import '../../../features/analytics/domain/models/analytics.dart';
import '../../../features/workers/domain/models/worker_analytics.dart';
import '../../logging/log_service.dart';

/// GraphQL client for Cloudflare Analytics API.
class CloudflareGraphQL {
  CloudflareGraphQL(this._dio);

  final Dio _dio;

  /// Main analytics query that fetches all 7 groups
  static const String _mainAnalyticsQuery = '''
    query GetDnsAnalytics(\$zoneTag: String!, \$since: DateTime!, \$until: DateTime!) {
      viewer {
        zones(filter: {zoneTag: \$zoneTag}) {
          total: dnsAnalyticsAdaptiveGroups(limit: 1, filter: {datetime_geq: \$since, datetime_leq: \$until}) {
            count
          }
          timeSeries: dnsAnalyticsAdaptiveGroups(
            limit: 1000,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [datetimeFifteenMinutes_ASC]
          ) {
            count
            dimensions {
              ts: datetimeFifteenMinutes
            }
          }
          byQueryName: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: \$since, datetime_leq: \$until}, orderBy: [count_DESC]) {
            count
            dimensions {
              queryName
            }
          }
          byQueryType: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: \$since, datetime_leq: \$until}, orderBy: [count_DESC]) {
            count
            dimensions {
              queryType
            }
          }
          byResponseCode: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: \$since, datetime_leq: \$until}, orderBy: [count_DESC]) {
            count
            dimensions {
              responseCode
            }
          }
          byDataCenter: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: \$since, datetime_leq: \$until}, orderBy: [count_DESC]) {
            count
            dimensions {
              coloName
            }
          }
          byIpVersion: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: \$since, datetime_leq: \$until}, orderBy: [count_DESC]) {
            count
            dimensions {
              ipVersion
            }
          }
          byProtocol: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: \$since, datetime_leq: \$until}, orderBy: [count_DESC]) {
            count
            dimensions {
              protocol
            }
          }
        }
      }
    }
  ''';

  /// Query for time series data filtered by a specific query name
  static const String _queryNameTimeSeriesQuery = '''
    query GetDnsAnalyticsForQueryName(\$zoneTag: String!, \$since: DateTime!, \$until: DateTime!, \$queryName: String!) {
      viewer {
        zones(filter: {zoneTag: \$zoneTag}) {
          timeSeries: dnsAnalyticsAdaptiveGroups(
            limit: 1000,
            filter: {datetime_geq: \$since, datetime_leq: \$until, queryName: \$queryName},
            orderBy: [datetimeFifteenMinutes_ASC]
          ) {
            count
            dimensions {
              ts: datetimeFifteenMinutes
            }
          }
        }
      }
    }
  ''';

  static const String _webAnalyticsQuery = '''
    query GetWebAnalytics(\$zoneTag: String!, \$since: DateTime!, \$until: DateTime!) {
      viewer {
        zones(filter: {zoneTag: \$zoneTag}) {
          httpRequestsAdaptiveGroups(
            limit: 1000,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [datetimeFifteenMinutes_ASC]
          ) {
            count
            sum {
              edgeResponseBytes
            }
            dimensions {
              ts: datetimeFifteenMinutes
            }
          }
          byStatus: httpRequestsAdaptiveGroups(
            limit: 10,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [count_DESC]
          ) {
            count
            dimensions {
              edgeResponseStatus
            }
          }
          byCountry: httpRequestsAdaptiveGroups(
            limit: 10,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [count_DESC]
          ) {
            count
            dimensions {
              clientCountryName
            }
          }
          byContentType: httpRequestsAdaptiveGroups(
            limit: 10,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [count_DESC]
          ) {
            count
            dimensions {
              clientRequestHTTPProtocol
            }
          }
          byBrowser: httpRequestsAdaptiveGroups(
            limit: 10,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [count_DESC]
          ) {
            count
            dimensions {
              clientRequestHTTPHost
            }
          }
          byPath: httpRequestsAdaptiveGroups(
            limit: 10,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [count_DESC]
          ) {
            count
            dimensions {
              clientRequestPath
            }
          }
        }
      }
    }
  ''';

  static const String _performanceAnalyticsQuery = '''
    query GetPerformanceAnalytics(\$zoneTag: String!, \$since: DateTime!, \$until: DateTime!) {
      viewer {
        zones(filter: {zoneTag: \$zoneTag}) {
          total: httpRequestsAdaptiveGroups(
            limit: 1000,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [datetimeFifteenMinutes_ASC]
          ) {
            count
            sum {
              edgeResponseBytes
            }
            dimensions {
              ts: datetimeFifteenMinutes
            }
          }
          cached: httpRequestsAdaptiveGroups(
            limit: 1000,
            filter: {datetime_geq: \$since, datetime_leq: \$until, cacheStatus_in: ["hit", "stale", "revalidated", "updating"]},
            orderBy: [datetimeFifteenMinutes_ASC]
          ) {
            count
            sum {
              edgeResponseBytes
            }
            dimensions {
              ts: datetimeFifteenMinutes
            }
          }
          byContentType: httpRequestsAdaptiveGroups(
            limit: 10,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [count_DESC]
          ) {
            count
            dimensions {
              edgeResponseStatus
              cacheStatus
            }
          }
        }
      }
    }
  ''';

  static const String _securityAnalyticsQuery = '''
    query GetSecurityAnalytics(\$zoneTag: String!, \$since: DateTime!, \$until: DateTime!) {
      viewer {
        zones(filter: {zoneTag: \$zoneTag}) {
          firewallEventsAdaptiveGroups(
            limit: 1000,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [datetimeFifteenMinutes_ASC]
          ) {
            count
            dimensions {
              ts: datetimeFifteenMinutes
            }
          }
          byAction: firewallEventsAdaptiveGroups(
            limit: 10,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [count_DESC]
          ) {
            count
            dimensions {
              action
            }
          }
          byCountry: firewallEventsAdaptiveGroups(
            limit: 10,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [count_DESC]
          ) {
            count
            dimensions {
              clientCountryName
            }
          }
          bySource: firewallEventsAdaptiveGroups(
            limit: 10,
            filter: {datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [count_DESC]
          ) {
            count
            dimensions {
              source
            }
          }
        }
      }
    }
  ''';

  static const String _workerAnalyticsQuery = '''
    query GetWorkerAnalytics(\$accountTag: String!, \$scriptName: String!, \$since: DateTime!, \$until: DateTime!) {
      viewer {
        accounts(filter: {accountTag: \$accountTag}) {
          timeSeries: workersInvocationsAdaptive(
            limit: 1000,
            filter: {scriptName: \$scriptName, datetime_geq: \$since, datetime_leq: \$until},
            orderBy: [datetimeFifteenMinutes_ASC]
          ) {
            sum {
              requests
              errors
            }
            max {
              cpuTime
            }
            dimensions {
              ts: datetimeFifteenMinutes
            }
          }
        }
      }
    }
  ''';

  /// Fetch DNS analytics data
  Future<DnsAnalyticsData?> fetchAnalytics({
    required String zoneId,
    required DateTime since,
    required DateTime until,
    List<String> queryNames = const [],
  }) async {
    // Fetch main analytics
    final mainResult =
        await _executeQuery<Map<String, dynamic>>(_mainAnalyticsQuery, {
          'zoneTag': zoneId,
          'since': since.toUtc().toIso8601String(),
          'until': until.toUtc().toIso8601String(),
        });

    if (mainResult == null) return null;

    final zones = mainResult['viewer']?['zones'] as List?;
    if (zones == null || zones.isEmpty) return null;

    final zoneData = zones[0] as Map<String, dynamic>;

    // Parse total
    final totalList = zoneData['total'] as List?;
    final total = (totalList?.isNotEmpty == true)
        ? (totalList![0]['count'] as int? ?? 0)
        : 0;

    // Parse time series
    final timeSeries = _parseTimeSeries(zoneData['timeSeries']);

    // Fetch per-query-name time series if query names are provided
    final byQueryNameTimeSeries = <String, List<AnalyticsTimeSeries>>{};
    if (queryNames.isNotEmpty) {
      final futures = queryNames.map(
        (name) => _fetchQueryNameTimeSeries(
          zoneId: zoneId,
          since: since,
          until: until,
          queryName: name,
        ),
      );
      final results = await Future.wait(futures);
      for (var i = 0; i < queryNames.length; i++) {
        if (results[i] != null) {
          byQueryNameTimeSeries[queryNames[i]] = results[i]!;
        }
      }
    }

    // Debug log for byDataCenter data
    final byDataCenterRaw = zoneData['byDataCenter'];
    log.debug('GraphQL byDataCenter raw: $byDataCenterRaw');

    final byDataCenter = _parseAnalyticsGroups(byDataCenterRaw);
    log.debug('GraphQL byDataCenter parsed: ${byDataCenter.length} groups');
    for (final group in byDataCenter.take(3)) {
      log.debug(
        '  - coloName=${group.dimensions['coloName']}, count=${group.count}',
      );
    }

    return DnsAnalyticsData(
      total: total,
      timeSeries: timeSeries,
      byQueryName: _parseAnalyticsGroups(zoneData['byQueryName']),
      byQueryType: _parseAnalyticsGroups(zoneData['byQueryType']),
      byResponseCode: _parseAnalyticsGroups(zoneData['byResponseCode']),
      byDataCenter: byDataCenter,
      byIpVersion: _parseAnalyticsGroups(zoneData['byIpVersion']),
      byProtocol: _parseAnalyticsGroups(zoneData['byProtocol']),
      byQueryNameTimeSeries: byQueryNameTimeSeries,
    );
  }

  /// Fetch Web analytics data
  Future<WebAnalyticsData?> fetchWebAnalytics({
    required String zoneId,
    required DateTime since,
    required DateTime until,
  }) async {
    final result =
        await _executeQuery<Map<String, dynamic>>(_webAnalyticsQuery, {
          'zoneTag': zoneId,
          'since': since.toUtc().toIso8601String(),
          'until': until.toUtc().toIso8601String(),
        });

    if (result == null) return null;

    final zones = result['viewer']?['zones'] as List?;
    if (zones == null || zones.isEmpty) return null;

    final zoneData = zones[0] as Map<String, dynamic>;

    final timeSeriesRaw = zoneData['httpRequestsAdaptiveGroups'] as List?;
    final timeSeries = (timeSeriesRaw ?? []).map((item) {
      final map = item as Map<String, dynamic>;
      final sum = map['sum'] as Map<String, dynamic>? ?? {};
      final dimensions = map['dimensions'] as Map<String, dynamic>? ?? {};
      final count = map['count'] as int? ?? 0;
      return WebTimeSeries(
        timestamp: dimensions['ts'] as String? ?? '',
        requests: count,
        bytes: sum['edgeResponseBytes'] as int? ?? 0,
        visits:
            count, // Use count as fallback for visits since we removed visits field
      );
    }).toList();

    int totalRequests = 0;
    int totalBytes = 0;
    int totalVisits = 0;
    for (final ts in timeSeries) {
      totalRequests += ts.requests;
      totalBytes += ts.bytes;
      totalVisits += ts.visits;
    }

    return WebAnalyticsData(
      totalRequests: totalRequests,
      totalBytes: totalBytes,
      totalVisits: totalVisits,
      timeSeries: timeSeries,
      byStatus: _parseAnalyticsGroups(zoneData['byStatus']),
      byCountry: _parseAnalyticsGroups(zoneData['byCountry']),
      byContentType: _parseAnalyticsGroups(zoneData['byContentType']),
      byBrowser: _parseAnalyticsGroups(zoneData['byBrowser']),
      byPath: _parseAnalyticsGroups(zoneData['byPath']),
    );
  }

  /// Fetch Performance analytics data
  Future<PerformanceAnalyticsData?> fetchPerformanceAnalytics({
    required String zoneId,
    required DateTime since,
    required DateTime until,
  }) async {
    final result =
        await _executeQuery<Map<String, dynamic>>(_performanceAnalyticsQuery, {
          'zoneTag': zoneId,
          'since': since.toUtc().toIso8601String(),
          'until': until.toUtc().toIso8601String(),
        });

    if (result == null) return null;

    final zones = result['viewer']?['zones'] as List?;
    if (zones == null || zones.isEmpty) return null;

    final zoneData = zones[0] as Map<String, dynamic>;

    // Parse total requests time series
    final totalRaw = zoneData['total'] as List?;
    final cachedRaw = zoneData['cached'] as List?;

    log.debug('Performance: totalRaw has ${totalRaw?.length ?? 0} items');
    log.debug('Performance: cachedRaw has ${cachedRaw?.length ?? 0} items');

    // Build a map of timestamp -> cached data for easy lookup
    final cachedMap = <String, Map<String, dynamic>>{};
    for (final item in cachedRaw ?? []) {
      final map = item as Map<String, dynamic>;
      final ts = (map['dimensions'] as Map?)?['ts'] as String? ?? '';
      cachedMap[ts] = map;
    }

    final timeSeries = (totalRaw ?? []).map((item) {
      final map = item as Map<String, dynamic>;
      final sum = map['sum'] as Map<String, dynamic>? ?? {};
      final ts = (map['dimensions'] as Map?)?['ts'] as String? ?? '';
      // Use num?.toInt() to handle both int and double from GraphQL
      final count = (map['count'] as num?)?.toInt() ?? 0;
      final bytes = (sum['edgeResponseBytes'] as num?)?.toInt() ?? 0;

      // Get cached data for this timestamp
      final cachedItem = cachedMap[ts];
      final cachedCount = (cachedItem?['count'] as num?)?.toInt() ?? 0;
      final cachedSum = cachedItem?['sum'] as Map<String, dynamic>? ?? {};
      final cachedBytesValue =
          (cachedSum['edgeResponseBytes'] as num?)?.toInt() ?? 0;

      return PerformanceTimeSeries(
        timestamp: ts,
        requests: count,
        cachedRequests: cachedCount,
        bytes: bytes,
        cachedBytes: cachedBytesValue,
      );
    }).toList();

    int totalRequests = 0;
    int cachedRequests = 0;
    int totalBytes = 0;
    int cachedBytes = 0;
    for (final ts in timeSeries) {
      totalRequests += ts.requests;
      cachedRequests += ts.cachedRequests;
      totalBytes += ts.bytes;
      cachedBytes += ts.cachedBytes;
    }

    log.debug(
      'Performance aggregated: requests=$totalRequests, bytes=$totalBytes, '
      'cachedRequests=$cachedRequests, cachedBytes=$cachedBytes',
    );

    return PerformanceAnalyticsData(
      totalRequests: totalRequests,
      cachedRequests: cachedRequests,
      totalBytes: totalBytes,
      cachedBytes: cachedBytes,
      timeSeries: timeSeries,
      byContentType: _parseAnalyticsGroups(zoneData['byContentType']),
    );
  }

  /// Fetch Security analytics data
  Future<SecurityAnalyticsData?> fetchSecurityAnalytics({
    required String zoneId,
    required DateTime since,
    required DateTime until,
  }) async {
    final result =
        await _executeQuery<Map<String, dynamic>>(_securityAnalyticsQuery, {
          'zoneTag': zoneId,
          'since': since.toUtc().toIso8601String(),
          'until': until.toUtc().toIso8601String(),
        });

    if (result == null) return null;

    final zones = result['viewer']?['zones'] as List?;
    if (zones == null || zones.isEmpty) return null;

    final zoneData = zones[0] as Map<String, dynamic>;

    final timeSeriesRaw = zoneData['firewallEventsAdaptiveGroups'] as List?;
    final timeSeries = (timeSeriesRaw ?? []).map((item) {
      final map = item as Map<String, dynamic>;
      return SecurityTimeSeries(
        timestamp: (map['dimensions'] as Map?)?['ts'] as String? ?? '',
        threats: map['count'] as int? ?? 0,
      );
    }).toList();

    int totalThreats = 0;
    for (final ts in timeSeries) {
      totalThreats += ts.threats;
    }

    return SecurityAnalyticsData(
      totalThreats: totalThreats,
      timeSeries: timeSeries,
      byAction: _parseAnalyticsGroups(zoneData['byAction']),
      byCountry: _parseAnalyticsGroups(zoneData['byCountry']),
      bySource: _parseAnalyticsGroups(zoneData['bySource']),
    );
  }

  /// Fetch Worker analytics data
  Future<WorkerAnalyticsData?> fetchWorkerAnalytics({
    required String accountId,
    required String scriptName,
    required DateTime since,
    required DateTime until,
  }) async {
    final result = await _executeQuery<Map<String, dynamic>>(_workerAnalyticsQuery, {
      'accountTag': accountId,
      'scriptName': scriptName,
      'since': since.toUtc().toIso8601String(),
      'until': until.toUtc().toIso8601String(),
    });

    if (result == null) return null;

    final accounts = result['viewer']?['accounts'] as List?;
    if (accounts == null || accounts.isEmpty) return null;

    final accountData = accounts[0] as Map<String, dynamic>;
    final timeSeriesRaw = accountData['timeSeries'] as List?;

    final timeSeries = (timeSeriesRaw ?? []).map((item) {
      final map = item as Map<String, dynamic>;
      final sum = map['sum'] as Map<String, dynamic>? ?? {};
      final max = map['max'] as Map<String, dynamic>? ?? {};
      final dimensions = map['dimensions'] as Map<String, dynamic>? ?? {};

      return WorkerTimeSeries(
        timestamp: dimensions['ts'] as String? ?? '',
        requests: (sum['requests'] as num?)?.toInt() ?? 0,
        errors: (sum['errors'] as num?)?.toInt() ?? 0,
        cpuTimeMax: (max['cpuTime'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return WorkerAnalyticsData(timeSeries: timeSeries);
  }

  /// Fetch time series for a specific query name
  Future<List<AnalyticsTimeSeries>?> _fetchQueryNameTimeSeries({
    required String zoneId,
    required DateTime since,
    required DateTime until,
    required String queryName,
  }) async {
    final result =
        await _executeQuery<Map<String, dynamic>>(_queryNameTimeSeriesQuery, {
          'zoneTag': zoneId,
          'since': since.toUtc().toIso8601String(),
          'until': until.toUtc().toIso8601String(),
          'queryName': queryName,
        });

    if (result == null) return null;

    final zones = result['viewer']?['zones'] as List?;
    if (zones == null || zones.isEmpty) return null;

    final zoneData = zones[0] as Map<String, dynamic>;
    return _parseTimeSeries(zoneData['timeSeries'], queryName: queryName);
  }

  /// Execute a GraphQL query
  Future<T?> _executeQuery<T>(
    String query,
    Map<String, dynamic> variables,
  ) async {
    final startTime = DateTime.now();

    try {
      log.apiRequest('POST', '/graphql', headers: variables);
      // Log the actual query for debugging unknown field errors
      log.debug('GraphQL Query: ${query.replaceAll(RegExp(r'\s+'), ' ')}');

      final response = await _dio.post<Map<String, dynamic>>(
        '/graphql',
        data: {'query': query, 'variables': variables},
      );

      final durationMs = DateTime.now().difference(startTime).inMilliseconds;

      if (response.data == null) {
        log.warning(
          'GraphQL returned null response',
          details: '${durationMs}ms',
        );
        return null;
      }

      final errors = response.data!['errors'] as List?;
      if (errors != null && errors.isNotEmpty) {
        final errorMsg = errors[0]['message'] ?? 'GraphQL error';
        log.error('GraphQL error', details: '$errorMsg (${durationMs}ms)');
        throw Exception(errorMsg);
      }

      log.apiResponse('POST', '/graphql', 200, durationMs: durationMs);
      return response.data!['data'] as T?;
    } on DioException catch (e) {
      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      final errorMessage =
          e.response?.data?['errors']?[0]?['message'] ??
          e.message ??
          'GraphQL request failed';
      log.error(
        'GraphQL request failed',
        details: '$errorMessage (${durationMs}ms)',
        error: e,
      );
      throw Exception(errorMessage);
    }
  }

  /// Parse time series from raw JSON
  List<AnalyticsTimeSeries> _parseTimeSeries(
    dynamic data, {
    String? queryName,
  }) {
    if (data == null) return [];
    if (data is! List) return [];

    return data.map((item) {
      final map = item as Map<String, dynamic>;
      final dimensions = map['dimensions'] as Map<String, dynamic>? ?? {};
      return AnalyticsTimeSeries(
        timestamp: dimensions['ts'] as String? ?? '',
        count: map['count'] as int? ?? 0,
        queryName: queryName,
      );
    }).toList();
  }

  /// Parse analytics groups from raw JSON
  List<AnalyticsGroup> _parseAnalyticsGroups(dynamic data, {String? metric}) {
    if (data == null) return [];
    if (data is! List) return [];

    return data.map((item) {
      final map = item as Map<String, dynamic>;
      int count = 0;
      if (metric != null) {
        final sum = map['sum'] as Map<String, dynamic>? ?? {};
        count = sum[metric] as int? ?? 0;
      } else {
        count = map['count'] as int? ?? 0;
      }

      return AnalyticsGroup(
        count: count,
        dimensions: map['dimensions'] as Map<String, dynamic>? ?? {},
      );
    }).toList();
  }
}
