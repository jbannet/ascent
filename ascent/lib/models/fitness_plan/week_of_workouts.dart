import 'package:ascent/models/fitness_plan/exercise.dart';
import 'package:ascent/models/fitness_plan/style_allocation.dart';
import 'package:ascent/models/fitness_plan/workout.dart';
import 'package:ascent/models/fitness_profile_model/fitness_profile.dart';
import 'package:ascent/services_and_utilities/general_utilities/get_this_sunday.dart';
import 'package:ascent/constants_and_enums/constants_features.dart';
import '../../constants_and_enums/constants.dart';
import '../../constants_and_enums/session_type.dart';
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

  get styleAllocation {
    StyleAllocation styleAllocation = StyleAllocation();
    for (var workout in workouts) {
      styleAllocation.addWorkout(workout);
    }
    return styleAllocation;
  }

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
    Map<String, double> categoryWeights = {
      'cardio': profile.featuresMap[FeatureConstants.categoryCardio] ?? 0.0,
      'strength': profile.featuresMap[FeatureConstants.categoryStrength] ?? 0.0,
      'balance': profile.featuresMap[FeatureConstants.categoryBalance] ?? 0.0,
      'flexibility': profile.featuresMap[FeatureConstants.categoryStretching] ?? 0.0,
      'functional': profile.featuresMap[FeatureConstants.categoryFunctional] ?? 0.0,
    };

    // Check if all weights are 0 (shouldn't happen but handle gracefully)
    if (categoryWeights.values.every((w) => w == 0.0)) {
      throw Exception('No category weights found in fitness profile');
    }

    List<Workout> workouts = [];
    List<String> recentStyles = []; // Track recent styles for variety

    for (int i = 0; i < totalWorkouts; i++) {
      // Step 1: Pick category based on weights
      String category = _weightedRandomSelect(categoryWeights);

      // Step 2: Pick style from category (with variety bias)
      List<String> availableStyles = WorkoutIcons.categoryToStyles[category]!;
      String style = _selectStyleWithVariety(availableStyles, recentStyles);
      recentStyles.add(style);
      if (recentStyles.length > 3) recentStyles.removeAt(0); // Keep last 3

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
  static String _weightedRandomSelect(Map<String, double> weights) {
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

  /// Select style from available styles, avoiding recent repetitions
  static String _selectStyleWithVariety(List<String> availableStyles, List<String> recentStyles) {
    final random = Random();

    // Try to avoid styles used in last 3 workouts
    List<String> freshStyles = availableStyles.where((style) => !recentStyles.contains(style)).toList();

    if (freshStyles.isNotEmpty) {
      return freshStyles[random.nextInt(freshStyles.length)];
    } else {
      // If all styles were recent, just pick randomly
      return availableStyles[random.nextInt(availableStyles.length)];
    }
  }
}