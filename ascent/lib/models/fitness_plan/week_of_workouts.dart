import 'dart:math';

import 'package:ascent/models/workout/workout.dart';
import 'package:ascent/models/fitness_profile_model/fitness_profile.dart';
import 'package:ascent/services_and_utilities/general_utilities/get_this_sunday.dart';
import '../../constants_and_enums/workout_enums/category_to_style_enum.dart';
import '../../constants_and_enums/constants.dart';
import '../../constants_and_enums/session_type.dart';
import '../../constants_and_enums/workout_enums/workout_style_enum.dart';

/*
* Represents completion statistics for a week
*/
class WeekCompletionStats {
  final int completed;
  final int total;  

  const WeekCompletionStats({required this.completed, required this.total});
}

/* **************************************
* Represents a week of workouts
*
*/
class WeekOfWorkouts {
  final DateTime startDate; // Sunday date of the week
  List<Workout> workouts;

  get isThisWeekCompleted => startDate.isBefore(getThisSunday()) || startDate.isAtSameMomentAs(getThisSunday());
  get completionStats => WeekCompletionStats(
    completed: workouts.where((workout) => workout.isCompleted).length,
    total: workouts.length,
  );
  get completedPercentage => completionStats.completed / completionStats.total;

  /// Check if this week is the same as another week (same Sunday)
  bool isSameWeek(WeekOfWorkouts other) {
    return startDate.year == other.startDate.year &&
           startDate.month == other.startDate.month &&
           startDate.day == other.startDate.day;
  }

  /// Get the Sunday date for any given date
  DateTime _getSundayForDate(DateTime date) {
    // DateTime.weekday: Monday = 1, Sunday = 7
    int daysSinceLastSunday = date.weekday % 7;
    return date.subtract(Duration(days: daysSinceLastSunday));
  }

  /// Check if this week contains the given date
  bool containsDate(DateTime date) {
    final sundayOfDate = _getSundayForDate(date);
    return startDate.year == sundayOfDate.year &&
           startDate.month == sundayOfDate.month &&
           startDate.day == sundayOfDate.day;
  }

  /// Check if this is the current week
  bool get isCurrentWeek => containsDate(DateTime.now());


  WeekOfWorkouts({
    required this.startDate,
    List<Workout>? workouts,
  }) : workouts = workouts ?? <Workout>[];


//MARK: JSON
  factory WeekOfWorkouts.fromJson(Map<String, dynamic> json) => WeekOfWorkouts(
     startDate: DateTime.parse(json[PlanFields.startDateField] as String),
     workouts: (json[PlanFields.workoutsField] as List<dynamic>? )?.map((e)=> Workout.fromJson(Map<String, dynamic>.from(e))).toList() ?? <Workout>[],
  );

  Map<String, dynamic> toJson() => {
     PlanFields.startDateField: startDate.toIso8601String(),
     PlanFields.workoutsField: workouts.map((e)=> e.toJson()).toList(),
  };

  factory WeekOfWorkouts.generateFromFitnessProfile(
    FitnessProfile profile,
    DateTime sundayDate,
  ) {
    // Extract workout counts
    int microWorkouts = profile.microWorkoutsPerWeek;
    int fullWorkouts = profile.fullWorkoutsPerWeek;
    int totalWorkouts = microWorkouts + fullWorkouts;

    // Extract category percentages using proper constants
    Map<Category, double> categoryWeights = profile.categoryAllocationsAsPercentages;

    // Check if all weights are 0 (shouldn't happen but handle gracefully)
    if (categoryWeights.values.every((w) => w == 0.0)) {
      throw Exception('No category weights found in fitness profile');
    }

    List<Workout> workouts = [];
    final random = Random();

    for (int i = 0; i < totalWorkouts; i++) {
      // Step 1: Pick category based on weights
      Category category = profile.selectRandomCategory(categoryWeights);

      // Step 2: Pick style from category
      WorkoutStyle style = category.pickRandomStyle(random);

      // Step 3: Assign session type
      SessionType type = i < fullWorkouts ? SessionType.full : SessionType.micro;
      int duration = type == SessionType.micro ? 15 : 45;

      workouts.add(Workout(
        type: type,
        style: style,
        durationMinutes: duration,
      ));
    }

    // Shuffle to mix micro/full throughout week
    workouts.shuffle();

    return WeekOfWorkouts(
      startDate: sundayDate,
      workouts: workouts,
    );
  }
}
