import 'package:ascent/models/fitness_plan/style_allocation.dart';

import '../../enums/exercise_style.dart';
import '../../constants.dart';
import 'week_of_workouts.dart';

/// Manages a 4-week fitness plan schedule
///
/// Contains the current week and next weeks, providing operations for:
/// - Current week tracking
/// - Next weeks management
/// - Calculating completion statistics
/// - Style allocation analysis
class FourWeeks {
  final WeekOfWorkouts currentWeek;
  final List<WeekOfWorkouts> nextWeeks;

  FourWeeks({
    required this.currentWeek,
    List<WeekOfWorkouts>? nextWeeks,
  }) : nextWeeks = nextWeeks ?? <WeekOfWorkouts>[];

  factory FourWeeks.fromJson(Map<String, dynamic> json) {
    if (json[PlanFields.currentWeekField] == null) {
      throw ArgumentError('${PlanFields.currentWeekField} is required in JSON');
    }
    return FourWeeks(
      currentWeek:
          WeekOfWorkouts.fromJson(json[PlanFields.currentWeekField] as Map<String, dynamic>),
      nextWeeks: (json[PlanFields.nextWeeksField] as List<dynamic>?)
          ?.map((e) => WeekOfWorkouts.fromJson(Map<String, dynamic>.from(e)))
          .toList() ?? <WeekOfWorkouts>[],
    );
  }

  Map<String, dynamic> toJson() => {
    PlanFields.currentWeekField: currentWeek.toJson(),
    PlanFields.nextWeeksField: nextWeeks.map((e) => e.toJson()).toList(),
  };

  /// Get all weeks (current + next)
  List<WeekOfWorkouts> get allWeeks => [currentWeek, ...nextWeeks];

  //*************************************************************************
  //MARK: Computed
  /// Get style allocation calculations for all workouts
  Map<ExerciseStyle, double> get styleAllocationInPercentages {
    StyleAllocation allocation = currentWeek.styleAllocation;
    for (final week in nextWeeks) {
      allocation = allocation.merge(week.styleAllocation);
    }
    return allocation.toPercentages();
  }

  /// Get completion status for a specific week
  Map<String, int> getWeekCompletionStats(int weekIndex) {
    final week = allWeeks.where((w) => w.weekIndex == weekIndex).firstOrNull;
    if (week == null) return {'completed': 0, 'total': 0};

    final completedCount = week.workouts.where((w) => w.isCompleted).length;
    return {'completed': completedCount, 'total': week.workouts.length};
  }

  /// Get next 4 weeks starting from current week (with placeholders for missing weeks)
  List<WeekOfWorkouts> getNext4Weeks(int currentWeekIndex) {
    final result = <WeekOfWorkouts>[];

    // Add current week if it exists
    if (currentWeek.weekIndex == currentWeekIndex) {
      result.add(currentWeek);
    } else {
      result.add(_generatePlaceholderWeek(currentWeekIndex));
    }

    // Add next 3 weeks
    for (int i = 1; i < 4; i++) {
      final weekIndex = currentWeekIndex + i;
      final existingWeek = nextWeeks.where((w) => w.weekIndex == weekIndex).firstOrNull;

      if (existingWeek != null) {
        result.add(existingWeek);
      } else {
        result.add(_generatePlaceholderWeek(weekIndex));
      }
    }

    return result;
  }

  /// Find a specific week by index
  WeekOfWorkouts? getWeekByIndex(int weekIndex) {
    if (currentWeek.weekIndex == weekIndex) return currentWeek;
    return nextWeeks.where((w) => w.weekIndex == weekIndex).firstOrNull;
  }

  /// Add a new week to the next weeks
  void addNextWeek(WeekOfWorkouts week) {
    nextWeeks.add(week);
  }

  /// Remove a week from next weeks
  void removeNextWeek(int weekIndex) {
    nextWeeks.removeWhere((w) => w.weekIndex == weekIndex);
  }

  /// Get total number of weeks in the schedule
  int get totalWeeks => 1 + nextWeeks.length;

  /// Get all workouts across all weeks
  List<dynamic> get allWorkouts => allWeeks.expand((week) => week.workouts).toList();

  /// Get total completed workouts across all weeks
  int get totalCompletedWorkouts {
    return allWorkouts.where((w) => w.isCompleted).length;
  }

  /// Get overall completion percentage
  double get completionPercentage {
    if (allWorkouts.isEmpty) return 0.0;
    return (totalCompletedWorkouts / allWorkouts.length) * 100;
  }

  /// Generate a placeholder week with empty workouts
  WeekOfWorkouts _generatePlaceholderWeek(int weekIndex) {
    return WeekOfWorkouts(weekIndex: weekIndex, startDate: DateTime.now(), workouts: []);
  }
}