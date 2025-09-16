import '../../enums/exercise_style.dart';
import '../../enums/session_status.dart';
import 'planned_week.dart';
import 'plan_progress.dart';

class Plan {
  final DateTime startDate;
  final List<PlannedWeek> weeks;          // calendar
  final PlanProgress planProgress; // New field for tracking progress


  Plan({
    required this.startDate,
    required this.planProgress,
    List<PlannedWeek>? weeks,
  })  :
        weeks = weeks ?? <PlannedWeek>[];

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      startDate: _dateFromJson(json['start_date'] as String),
      planProgress: PlanProgress(),
      weeks: (json['weeks'] as List<dynamic>? )?.map((e)=> PlannedWeek.fromJson(Map<String, dynamic>.from(e))).toList() ?? <PlannedWeek>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'start_date': _dateToJson(startDate),
    'weeks': weeks.map((e)=> e.toJson()).toList(),
  };

  // Style allocation calculations for the 4-week view
  Map<ExerciseStyle, double> getStyleAllocation() {
    final allWorkouts = weeks.expand((week) => week.workouts).toList();
    if (allWorkouts.isEmpty) return {};

    final styleCounts = <ExerciseStyle, int>{};
    for (final workout in allWorkouts) {
      styleCounts[workout.style] = (styleCounts[workout.style] ?? 0) + 1;
    }

    final total = allWorkouts.length;
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

    final completedCount = week.workouts.where((w) => w.isCompleted).length;
    return {'completed': completedCount, 'total': week.workouts.length};
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
    return PlannedWeek(weekIndex: weekIndex, workouts: []);
  }

}

DateTime _dateFromJson(String value) => DateTime.parse(value);
String _dateToJson(DateTime value) => value.toIso8601String().split('T').first;