import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics.freezed.dart';
part 'analytics.g.dart';

@freezed
sealed class DnsAnalyticsData with _$DnsAnalyticsData {
  const factory DnsAnalyticsData({
    @Default(0) int total,
    @Default([]) List<AnalyticsTimeSeries> timeSeries,
    @Default([]) List<AnalyticsGroup> byQueryName,
    @Default([]) List<AnalyticsGroup> byQueryType,
    @Default([]) List<AnalyticsGroup> byResponseCode,
    @Default([]) List<AnalyticsGroup> byDataCenter,
    @Default([]) List<AnalyticsGroup> byIpVersion,
    @Default([]) List<AnalyticsGroup> byProtocol,

    /// Time series data per query name (for multi-series charts)
    @Default({}) Map<String, List<AnalyticsTimeSeries>> byQueryNameTimeSeries,
    double? avgProcessingTime,
    double? avgQps,
  }) = _DnsAnalyticsData;

  factory DnsAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$DnsAnalyticsDataFromJson(json);
}

@freezed
sealed class WebAnalyticsData with _$WebAnalyticsData {
  const factory WebAnalyticsData({
    @Default(0) int totalRequests,
    @Default(0) int totalBytes,
    @Default(0) int totalVisits,
    @Default([]) List<WebTimeSeries> timeSeries,
    @Default([]) List<AnalyticsGroup> byStatus,
    @Default([]) List<AnalyticsGroup> byCountry,
    @Default([]) List<AnalyticsGroup> byContentType,
    @Default([]) List<AnalyticsGroup> byBrowser,
  }) = _WebAnalyticsData;

  factory WebAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$WebAnalyticsDataFromJson(json);
}

@freezed
sealed class PerformanceAnalyticsData with _$PerformanceAnalyticsData {
  const factory PerformanceAnalyticsData({
    @Default(0) int totalRequests,
    @Default(0) int cachedRequests,
    @Default(0) int totalBytes,
    @Default(0) int cachedBytes,
    @Default([]) List<PerformanceTimeSeries> timeSeries,
    @Default([]) List<AnalyticsGroup> byContentType,
  }) = _PerformanceAnalyticsData;

  factory PerformanceAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$PerformanceAnalyticsDataFromJson(json);
}

@freezed
sealed class SecurityAnalyticsData with _$SecurityAnalyticsData {
  const factory SecurityAnalyticsData({
    @Default(0) int totalThreats,
    @Default([]) List<SecurityTimeSeries> timeSeries,
    @Default([]) List<AnalyticsGroup> byAction,
    @Default([]) List<AnalyticsGroup> byCountry,
    @Default([]) List<AnalyticsGroup> bySource,
  }) = _SecurityAnalyticsData;

  factory SecurityAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$SecurityAnalyticsDataFromJson(json);
}

@freezed
sealed class WebTimeSeries with _$WebTimeSeries {
  const factory WebTimeSeries({
    required String timestamp,
    @Default(0) int requests,
    @Default(0) int bytes,
    @Default(0) int visits,
  }) = _WebTimeSeries;

  factory WebTimeSeries.fromJson(Map<String, dynamic> json) =>
      _$WebTimeSeriesFromJson(json);
}

@freezed
sealed class PerformanceTimeSeries with _$PerformanceTimeSeries {
  const factory PerformanceTimeSeries({
    required String timestamp,
    @Default(0) int requests,
    @Default(0) int cachedRequests,
    @Default(0) int bytes,
    @Default(0) int cachedBytes,
  }) = _PerformanceTimeSeries;

  factory PerformanceTimeSeries.fromJson(Map<String, dynamic> json) =>
      _$PerformanceTimeSeriesFromJson(json);
}

@freezed
sealed class SecurityTimeSeries with _$SecurityTimeSeries {
  const factory SecurityTimeSeries({
    required String timestamp,
    @Default(0) int threats,
  }) = _SecurityTimeSeries;

  factory SecurityTimeSeries.fromJson(Map<String, dynamic> json) =>
      _$SecurityTimeSeriesFromJson(json);
}

@freezed
sealed class AnalyticsTimeSeries with _$AnalyticsTimeSeries {
  const factory AnalyticsTimeSeries({
    required String timestamp,
    required int count,
    String? queryName,
  }) = _AnalyticsTimeSeries;

  factory AnalyticsTimeSeries.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsTimeSeriesFromJson(json);
}

@freezed
sealed class AnalyticsGroup with _$AnalyticsGroup {
  const factory AnalyticsGroup({
    required int count,
    required Map<String, dynamic> dimensions,
  }) = _AnalyticsGroup;

  factory AnalyticsGroup.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsGroupFromJson(json);
}

@freezed
sealed class DataCenterInfo with _$DataCenterInfo {
  const factory DataCenterInfo({
    required String iata,
    required String place,
    required double lat,
    required double lng,
  }) = _DataCenterInfo;

  factory DataCenterInfo.fromJson(Map<String, dynamic> json) =>
      _$DataCenterInfoFromJson(json);
}
