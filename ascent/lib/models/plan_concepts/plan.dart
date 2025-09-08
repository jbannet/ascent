import '../../enums/goal.dart';
import 'planned_week.dart';
import 'session.dart';

class Plan {
  final String planId;
  final String userId;
  final Goal goal;
  final DateTime startDate;
  final List<PlannedWeek> weeks;          // calendar
  final List<Session> sessions;    // session list
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

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      planId: json['plan_id'] as String,
      userId: json['user_id'] as String,
      goal: goalFromString(json['goal'] as String),
      startDate: _dateFromJson(json['start_date'] as String),
      weeks: (json['weeks'] as List<dynamic>? )?.map((e)=> PlannedWeek.fromJson(Map<String, dynamic>.from(e))).toList() ?? <PlannedWeek>[],
      sessions: (json['sessions'] as List<dynamic>?)?.map((e)=> Session.fromJson(Map<String, dynamic>.from(e))).toList() ?? <Session>[],
      notesCoach: (json['notes_coach'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'plan_id': planId,
    'user_id': userId,
    'goal': goalToString(goal),
    'start_date': _dateToJson(startDate),
    'weeks': weeks.map((e)=> e.toJson()).toList(),
    'sessions': sessions.map((e)=> e.toJson()).toList(),
    'notes_coach': notesCoach,
  };
}

DateTime _dateFromJson(String value) => DateTime.parse(value);
String _dateToJson(DateTime value) => value.toIso8601String().split('T').first;