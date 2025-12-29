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
    @Default([]) List<AnalyticsGroup> byColoName,
    @Default([]) List<AnalyticsGroup> byIpVersion,
    @Default([]) List<AnalyticsGroup> byProtocol,
    double? avgProcessingTime,
    double? avgQps,
  }) = _DnsAnalyticsData;

  factory DnsAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$DnsAnalyticsDataFromJson(json);
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
