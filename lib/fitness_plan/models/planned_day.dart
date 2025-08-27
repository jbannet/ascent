import 'package:json_annotation/json_annotation.dart';
import '../enums/day_of_week.dart';
import '../enums/session_status.dart';
import '../converters/enum_converters.dart';

part 'planned_day.g.dart';

@JsonSerializable()
class PlannedDay {
  @DayOfWeekConverter()
  final DayOfWeek dow;
  
  @JsonKey(name: 'session_id')
  final String sessionId;
  
  @SessionStatusConverter()
  final SessionStatus status;
  
  @JsonKey(name: 'changed_at', fromJson: _nullableDateFromJson, toJson: _nullableDateToJson)
  final DateTime? changedAt;
  
  @JsonKey(name: 'changed_reason')
  final String changedReason;

  PlannedDay({
    required this.dow,
    required this.sessionId,
    this.status = SessionStatus.planned,
    this.changedAt,
    this.changedReason = '',
  });

  factory PlannedDay.fromJson(Map<String, dynamic> json) => _$PlannedDayFromJson(json);
  Map<String, dynamic> toJson() => _$PlannedDayToJson(this);
}

DateTime? _nullableDateFromJson(String? value) => value == null ? null : DateTime.parse(value);
String? _nullableDateToJson(DateTime? value) => value?.toIso8601String();