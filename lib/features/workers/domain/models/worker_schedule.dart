import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_schedule.freezed.dart';
part 'worker_schedule.g.dart';

/// Worker cron trigger schedule.
@freezed
sealed class WorkerSchedule with _$WorkerSchedule {
  const factory WorkerSchedule({
    required String cron,
    @JsonKey(name: 'created_on') DateTime? createdOn,
  }) = _WorkerSchedule;

  factory WorkerSchedule.fromJson(Map<String, dynamic> json) =>
      _$WorkerScheduleFromJson(json);
}

/// Response wrapper for schedules
@freezed
sealed class WorkerSchedulesResponse with _$WorkerSchedulesResponse {
  const factory WorkerSchedulesResponse({
    @Default([]) List<WorkerSchedule> schedules,
  }) = _WorkerSchedulesResponse;

  factory WorkerSchedulesResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkerSchedulesResponseFromJson(json);
}
