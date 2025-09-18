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
  final List<WeekOfWorkouts> nextWeeks; //three weeks

  FourWeeks({
    required this.currentWeek,
    List<WeekOfWorkouts>? nextWeeks,
  }) : nextWeeks = (() {
    final weeks = nextWeeks ?? <WeekOfWorkouts>[];
    final filledWeeks = List<WeekOfWorkouts>.from(weeks);
    //Ensure we always have 3 next weeks
    for (int i = weeks.length; i < 3; i++) {
      // Use weekIndex = currentWeek.weekIndex + i + 1 for unique indices
      filledWeeks.add(WeekOfWorkouts(
        weekIndex: currentWeek.weekIndex + i + 1,
        startDate: DateTime.now(),
        workouts: [],
      ));
    }
    return filledWeeks;
  })();

  //MARK: Computed
  /// Get all weeks (current + next)
  List<WeekOfWorkouts> get allWeeks => [currentWeek, ...nextWeeks];

  /// Get style allocation calculations for all workouts
  StyleAllocation get styleAllocationInPercentages {
    StyleAllocation allocation = currentWeek.styleAllocation;
    for (final week in nextWeeks) {
      allocation = allocation.merge(week.styleAllocation);
    }
    return allocation;
  }

  /// Get completion status for currentweek
  WeekCompletionStats get completionStats => currentWeek.completionStats;
  
  /// Get all 4 weeks (current + next)
  List<WeekOfWorkouts> get next4Weeks => [currentWeek, ...nextWeeks];

  /// Get overall completion percentage
  double get completionPercentage {    
    return currentWeek.completedPercentage;
  }

  //MARK: JSON
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

}