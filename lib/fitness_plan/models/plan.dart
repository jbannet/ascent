import 'package:json_annotation/json_annotation.dart';
import '../enums/goal.dart';
import '../converters/enum_converters.dart';
import 'planned_week.dart';
import 'session.dart';

part 'plan.g.dart';

@JsonSerializable()
class Plan {
  @JsonKey(name: 'plan_id')
  final String planId;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @GoalConverter()
  final Goal goal;
  
  @JsonKey(name: 'start_date')
  @DateTimeConverter()
  final DateTime startDate;

  final List<PlannedWeek> weeks;          // calendar
  final List<Session> sessions;    // session list

  @JsonKey(name: 'notes_coach')
  final String notesCoach;

  Plan({
    required this.planId,
    required this.userId,
    required this.goal,
    required this.startDate,
    List<PlannedWeek>? weeks,
    List<Session>? sessions,
    this.notesCoach = '',
  })  : 
        weeks = weeks ?? <PlannedWeek>[],
        sessions = sessions ?? <Session>[];

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
  Map<String, dynamic> toJson() => _$PlanToJson(this);
}