import 'package:json_annotation/json_annotation.dart';
import 'planned_day.dart';

part 'planned_week.g.dart';

@JsonSerializable()
class PlannedWeek {
  @JsonKey(name: 'week_index')
  final int weekIndex;
  final List<PlannedDay> days;

  PlannedWeek({ required this.weekIndex, List<PlannedDay>? days }) : days = days ?? <PlannedDay>[];

  factory PlannedWeek.fromJson(Map<String, dynamic> json) => _$PlannedWeekFromJson(json);
  Map<String, dynamic> toJson() => _$PlannedWeekToJson(this);
}