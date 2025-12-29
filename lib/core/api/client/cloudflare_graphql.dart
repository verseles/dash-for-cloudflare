import 'package:dio/dio.dart';
import '../../../features/analytics/domain/models/analytics.dart';
import '../../logging/log_service.dart';

/// GraphQL client for Cloudflare Analytics API.
class CloudflareGraphQL {
  CloudflareGraphQL(this._dio);

  final Dio _dio;

  /// Main analytics query that fetches all 7 groups
  static const String _mainAnalyticsQuery = '''
    query GetDnsAnalytics(\$zoneTag: string!, \$since: DateTime!, \$until: DateTime!) {
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
    query GetDnsAnalyticsForQueryName(\$zoneTag: string!, \$since: DateTime!, \$until: DateTime!, \$queryName: string!) {
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

    return DnsAnalyticsData(
      total: total,
      timeSeries: timeSeries,
      byQueryName: _parseAnalyticsGroups(zoneData['byQueryName']),
      byQueryType: _parseAnalyticsGroups(zoneData['byQueryType']),
      byResponseCode: _parseAnalyticsGroups(zoneData['byResponseCode']),
      byDataCenter: _parseAnalyticsGroups(zoneData['byDataCenter']),
      byIpVersion: _parseAnalyticsGroups(zoneData['byIpVersion']),
      byProtocol: _parseAnalyticsGroups(zoneData['byProtocol']),
      byQueryNameTimeSeries: byQueryNameTimeSeries,
    );
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

      final response = await _dio.post<Map<String, dynamic>>(
        '/graphql',
        data: {'query': query, 'variables': variables},
      );

      final durationMs = DateTime.now().difference(startTime).inMilliseconds;

      if (response.data == null) {
        log.warning('GraphQL returned null response', details: '${durationMs}ms');
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
  List<AnalyticsGroup> _parseAnalyticsGroups(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];

    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return AnalyticsGroup(
        count: map['count'] as int? ?? 0,
        dimensions: map['dimensions'] as Map<String, dynamic>? ?? {},
      );
    }).toList();
  }
}
