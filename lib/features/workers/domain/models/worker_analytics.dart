import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_analytics.freezed.dart';
part 'worker_analytics.g.dart';

@freezed
sealed class WorkerAnalyticsData with _$WorkerAnalyticsData {
  const factory WorkerAnalyticsData({
    required List<WorkerTimeSeries> timeSeries,
  }) = _WorkerAnalyticsData;

  factory WorkerAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$WorkerAnalyticsDataFromJson(json);
}

@freezed
sealed class WorkerTimeSeries with _$WorkerTimeSeries {
  const factory WorkerTimeSeries({
    required String timestamp,
    required int requests,
    required int errors,
    required int cpuTimeMax,
  }) = _WorkerTimeSeries;

  factory WorkerTimeSeries.fromJson(Map<String, dynamic> json) =>
      _$WorkerTimeSeriesFromJson(json);
}
