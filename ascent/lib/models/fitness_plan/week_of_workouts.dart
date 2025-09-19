import 'package:ascent/models/fitness_plan/exercise.dart';
import 'package:ascent/constants_and_enums/constants_features.dart';
import 'package:ascent/models/fitness_plan/style_allocation.dart';
import 'package:ascent/models/fitness_plan/workout.dart';
import 'package:ascent/models/fitness_profile_model/fitness_profile.dart';
import 'package:ascent/services_and_utilities/general_utilities/get_this_sunday.dart';
import 'package:flutter/foundation.dart';
import '../../constants_and_enums/constants.dart';
import '../../constants_and_enums/session_type.dart';
import '../../constants_and_enums/workout_style_enum.dart';
import '../../constants_and_enums/category_enum.dart' as ascent_category;
import 'dart:math';

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
  final int weekIndex;
  final DateTime startDate; // Sunday date of the week
  List<Workout> workouts;
  final List<Exercise> exercises;

  get isThisWeekCompleted => startDate.isBefore(getThisSunday()) || startDate.isAtSameMomentAs(getThisSunday());
  get completionStats => WeekCompletionStats(
    completed: workouts.where((workout) => workout.isCompleted).length,
    total: workouts.length,
  );
  get completedPercentage => completionStats.completed / completionStats.total;


  WeekOfWorkouts({
    required this.weekIndex,
    required this.startDate,
    List<Workout>? workouts,
    List<Exercise>? exercises,
  }) : workouts = workouts ?? <Workout>[],
       exercises = exercises ?? <Exercise>[];


//MARK: JSON
  factory WeekOfWorkouts.fromJson(Map<String, dynamic> json) => WeekOfWorkouts(
     weekIndex: json[PlanFields.weekIndexField] as int,
     startDate: DateTime.parse(json[PlanFields.startDateField] as String),
     workouts: (json[PlanFields.workoutsField] as List<dynamic>? )?.map((e)=> Workout.fromJson(Map<String, dynamic>.from(e))).toList() ?? <Workout>[],
     exercises: (json['exercises'] as List<dynamic>?)?.map((e) => Exercise.fromJson(Map<String, dynamic>.from(e))).toList() ?? <Exercise>[],
  );

  Map<String, dynamic> toJson() => {
     PlanFields.weekIndexField: weekIndex,
     PlanFields.startDateField: startDate.toIso8601String(),
     PlanFields.workoutsField: workouts.map((e)=> e.toJson()).toList(),
     'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WeekOfWorkouts.generateFromFitnessProfile(FitnessProfile profile, DateTime sundayDate) {
    // Extract workout counts
    int microWorkouts = profile.microWorkoutsPerWeek;
    int macroWorkouts = profile.fullWorkoutsPerWeek;
    int totalWorkouts = microWorkouts + macroWorkouts;

    // Extract category percentages using proper constants
    Map<ascent_category.Category, double> categoryWeights = profile.getCategoryAllocationsAsPercentages();

    // Check if all weights are 0 (shouldn't happen but handle gracefully)
    if (categoryWeights.values.every((w) => w == 0.0)) {
      throw Exception('No category weights found in fitness profile');
    }

    List<Workout> workouts = [];
    final random = Random();

    for (int i = 0; i < totalWorkouts; i++) {
      // Step 1: Pick category based on weights
      ascent_category.Category category = _weightedRandomSelect(categoryWeights);

      // Step 2: Pick style from category (with variety bias)
      List<WorkoutStyle> availableStyles = _getWorkoutStylesForCategory(category);
      WorkoutStyle style = availableStyles[random.nextInt(availableStyles.length)];

      // Step 3: Assign session type
      SessionType type = i < microWorkouts ? SessionType.micro : SessionType.macro;

      workouts.add(Workout(
        type: type,
        style: style,
      ));
    }

    // Shuffle to mix micro/macro throughout week
    workouts.shuffle();

    return WeekOfWorkouts(
      weekIndex: 1,
      startDate: sundayDate,
      workouts: workouts,
    );
  }

  /// Weighted random selection based on category percentages
  static ascent_category.Category _weightedRandomSelect(Map<ascent_category.Category, double> weights) {
    final random = Random();
    double totalWeight = weights.values.reduce((a, b) => a + b);
    double randomValue = random.nextDouble() * totalWeight;

    double cumulativeWeight = 0.0;
    for (var entry in weights.entries) {
      cumulativeWeight += entry.value;
      if (randomValue <= cumulativeWeight) {
        return entry.key;
      }
    }

    // Fallback (shouldn't happen)
    return weights.keys.first;
  }

  /// Get WorkoutStyle enum values for a given category
  static List<WorkoutStyle> _getWorkoutStylesForCategory(ascent_category.Category category) {
    final Map<ascent_category.Category, List<WorkoutStyle>> categoryToStyles = {
      ascent_category.Category.cardio: [WorkoutStyle.enduranceDominant, WorkoutStyle.circuitMetabolic, WorkoutStyle.athleticConditioning, WorkoutStyle.fullBody, WorkoutStyle.concurrentHybrid, WorkoutStyle.pilatesStyle],
      ascent_category.Category.strength: [WorkoutStyle.upperLowerSplit, WorkoutStyle.pushPullLegs, WorkoutStyle.concurrentHybrid, WorkoutStyle.fullBody, WorkoutStyle.athleticConditioning, WorkoutStyle.yogaFocused, WorkoutStyle.pilatesStyle],
      ascent_category.Category.balance: [WorkoutStyle.functionalMovement, WorkoutStyle.yogaFocused, WorkoutStyle.seniorSpecific, WorkoutStyle.pilatesStyle],
      ascent_category.Category.flexibility: [WorkoutStyle.yogaFocused, WorkoutStyle.pilatesStyle, WorkoutStyle.seniorSpecific],
      ascent_category.Category.functional: [WorkoutStyle.functionalMovement, WorkoutStyle.strongmanFunctional, WorkoutStyle.crossfitMixed, WorkoutStyle.seniorSpecific],
    };

    return categoryToStyles[category] ?? [WorkoutStyle.fullBody];
  }
}
