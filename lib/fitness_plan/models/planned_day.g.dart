// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlannedDay _$PlannedDayFromJson(Map<String, dynamic> json) => PlannedDay(
  dow: const DayOfWeekConverter().fromJson(json['dow'] as String),
  sessionId: json['session_id'] as String,
  status:
      json['status'] == null
          ? SessionStatus.planned
          : const SessionStatusConverter().fromJson(json['status'] as String),
  changedAt: _nullableDateFromJson(json['changed_at'] as String?),
  changedReason: json['changed_reason'] as String? ?? '',
);

Map<String, dynamic> _$PlannedDayToJson(PlannedDay instance) =>
    <String, dynamic>{
      'dow': const DayOfWeekConverter().toJson(instance.dow),
      'session_id': instance.sessionId,
      'status': const SessionStatusConverter().toJson(instance.status),
      'changed_at': _nullableDateToJson(instance.changedAt),
      'changed_reason': instance.changedReason,
    };
