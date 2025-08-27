// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plan _$PlanFromJson(Map<String, dynamic> json) => Plan(
  planId: json['plan_id'] as String,
  userId: json['user_id'] as String,
  goal: const GoalConverter().fromJson(json['goal'] as String),
  startDate: const DateTimeConverter().fromJson(json['start_date'] as String),
  weeks:
      (json['weeks'] as List<dynamic>?)
          ?.map((e) => PlannedWeek.fromJson(e as Map<String, dynamic>))
          .toList(),
  sessions:
      (json['sessions'] as List<dynamic>?)
          ?.map((e) => Session.fromJson(e as Map<String, dynamic>))
          .toList(),
  notesCoach: json['notes_coach'] as String? ?? '',
);

Map<String, dynamic> _$PlanToJson(Plan instance) => <String, dynamic>{
  'plan_id': instance.planId,
  'user_id': instance.userId,
  'goal': const GoalConverter().toJson(instance.goal),
  'start_date': const DateTimeConverter().toJson(instance.startDate),
  'weeks': instance.weeks,
  'sessions': instance.sessions,
  'notes_coach': instance.notesCoach,
};
