import '../../enums/goal.dart';
import '../../enums/exercise_style.dart';
import '../../enums/session_status.dart';
import '../../enums/session_type.dart';
import '../../enums/day_of_week.dart';
import '../rewrite_or_delete_plan_concepts/planned_week.dart';
import '../rewrite_or_delete_plan_concepts/planned_day.dart';
import '../rewrite_or_delete_plan_concepts/session.dart';

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

  // Style allocation calculations for the 4-week view
  Map<ExerciseStyle, double> getStyleAllocation() {
    if (sessions.isEmpty) return {};

    final styleCounts = <ExerciseStyle, int>{};
    for (final session in sessions) {
      styleCounts[session.style] = (styleCounts[session.style] ?? 0) + 1;
    }

    final total = sessions.length;
    return styleCounts.map((style, count) =>
      MapEntry(style, count / total * 100));
  }

  // Get current week index based on start date
  int get currentWeekIndex {
    final now = DateTime.now();
    final daysSinceStart = now.difference(startDate).inDays;
    return (daysSinceStart / 7).floor() + 1;
  }

  // Get the Sunday date for a specific week index
  DateTime getSundayDateForWeek(int weekIndex) {
    // Calculate days since start for this week (weeks are 1-indexed)
    final daysSinceStart = (weekIndex - 1) * 7;
    final weekStartDate = startDate.add(Duration(days: daysSinceStart));

    // Find the Sunday of that week
    // DateTime.weekday: Monday = 1, Sunday = 7
    // We want Sunday = 0, so: (weekday % 7)
    int daysSinceLastSunday = weekStartDate.weekday % 7;
    return weekStartDate.subtract(Duration(days: daysSinceLastSunday));
  }

  // Get completion status for a specific week
  Map<String, int> getWeekCompletionStats(int weekIndex) {
    final week = weeks.where((w) => w.weekIndex == weekIndex).firstOrNull;
    if (week == null) return {'completed': 0, 'total': 0};

    final completedCount = week.days.where((d) => d.status == SessionStatus.completed).length;
    return {'completed': completedCount, 'total': week.days.length};
  }

  // Get next 4 weeks starting from current week (with placeholders for missing weeks)
  List<PlannedWeek> getNext4Weeks() {
    final current = currentWeekIndex;
    final result = <PlannedWeek>[];

    // Generate 4 weeks starting from current week
    for (int i = 0; i < 4; i++) {
      final weekIndex = current + i;

      // Try to find existing week
      final existingWeek = weeks.firstWhere(
        (w) => w.weekIndex == weekIndex,
        orElse: () => _generatePlaceholderWeek(weekIndex),
      );

      result.add(existingWeek);
    }

    return result;
  }

  // Generate a placeholder week with sample workouts
  PlannedWeek _generatePlaceholderWeek(int weekIndex) {
    if (sessions.isEmpty) {
      return PlannedWeek(weekIndex: weekIndex, days: []);
    }

    // Create temporary micro sessions for demo purposes (since your plan only has macro sessions)
    final tempMicroSession = Session(
      id: 'temp_micro_${weekIndex}',
      title: 'Quick Stretch',
      type: SessionType.micro,
      style: ExerciseStyle.flexibility,
      blocks: [],
    );

    final tempCardioMicro = Session(
      id: 'temp_cardio_${weekIndex}',
      title: 'Quick Cardio',
      type: SessionType.micro,
      style: ExerciseStyle.cardio,
      blocks: [],
    );

    final sampleDays = <PlannedDay>[];

    // Monday - use your existing macro session
    sampleDays.add(PlannedDay(dow: DayOfWeek.mon, sessionId: sessions[0].id, status: SessionStatus.planned));

    // Wednesday - use temporary micro session
    sampleDays.add(PlannedDay(dow: DayOfWeek.wed, sessionId: tempMicroSession.id, status: SessionStatus.planned));

    // Friday - use temporary cardio micro session
    sampleDays.add(PlannedDay(dow: DayOfWeek.fri, sessionId: tempCardioMicro.id, status: SessionStatus.planned));

    // Add temp sessions to plan so they can be found
    sessions.addAll([tempMicroSession, tempCardioMicro]);

    return PlannedWeek(weekIndex: weekIndex, days: sampleDays);
  }

  // Calculate completed minutes for different time periods
  int getCompletedMinutes({String period = 'allTime'}) {
    final completedSessions = <String>[];

    switch (period) {
      case 'thisWeek':
        final currentWeek = weeks.where((w) => w.weekIndex == currentWeekIndex).firstOrNull;
        if (currentWeek != null) {
          completedSessions.addAll(
            currentWeek.days
                .where((d) => d.status == SessionStatus.completed)
                .map((d) => d.sessionId)
          );
        }
        break;
      case 'trailing4Weeks':
        final trailing4Weeks = weeks.where((w) =>
          w.weekIndex >= currentWeekIndex - 3 && w.weekIndex <= currentWeekIndex
        );
        for (final week in trailing4Weeks) {
          completedSessions.addAll(
            week.days
                .where((d) => d.status == SessionStatus.completed)
                .map((d) => d.sessionId)
          );
        }
        break;
      case 'allTime':
      default:
        for (final week in weeks) {
          completedSessions.addAll(
            week.days
                .where((d) => d.status == SessionStatus.completed)
                .map((d) => d.sessionId)
          );
        }
        break;
    }

    return completedSessions
        .map((sessionId) => sessions.firstWhere((s) => s.id == sessionId))
        .fold(0, (total, session) => total + session.estimatedDurationMin);
  }
}

DateTime _dateFromJson(String value) => DateTime.parse(value);
String _dateToJson(DateTime value) => value.toIso8601String().split('T').first;