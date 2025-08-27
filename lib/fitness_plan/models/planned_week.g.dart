// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_week.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlannedWeek _$PlannedWeekFromJson(Map<String, dynamic> json) => PlannedWeek(
  weekIndex: (json['week_index'] as num).toInt(),
  days:
      (json['days'] as List<dynamic>?)
          ?.map((e) => PlannedDay.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$PlannedWeekToJson(PlannedWeek instance) =>
    <String, dynamic>{'week_index': instance.weekIndex, 'days': instance.days};
