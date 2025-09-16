import 'planned_day.dart';

class PlannedWeek {
  final int weekIndex;
  final List<PlannedDay> days;

  PlannedWeek({ required this.weekIndex, List<PlannedDay>? days }) : days = days ?? <PlannedDay>[];

  factory PlannedWeek.fromJson(Map<String, dynamic> json) => PlannedWeek(
    weekIndex: json['week_index'] as int,
    days: (json['days'] as List<dynamic>? )?.map((e)=> PlannedDay.fromJson(Map<String, dynamic>.from(e))).toList() ?? <PlannedDay>[],
  );

  Map<String, dynamic> toJson() => {
    'week_index': weekIndex,
    'days': days.map((e)=> e.toJson()).toList(),
  };
}