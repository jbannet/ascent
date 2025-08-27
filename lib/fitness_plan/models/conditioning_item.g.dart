// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditioning_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConditioningItem _$ConditioningItemFromJson(Map<String, dynamic> json) =>
    ConditioningItem(
      exerciseId: json['exercise_id'] as String,
      timeMin: (json['time_min'] as num).toInt(),
      zone: json['zone'] as String?,
    );

Map<String, dynamic> _$ConditioningItemToJson(ConditioningItem instance) =>
    <String, dynamic>{
      'exercise_id': instance.exerciseId,
      'time_min': instance.timeMin,
      'zone': instance.zone,
    };
