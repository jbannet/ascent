import 'package:ascent/models/fitness_plan/exercise.dart';
import 'package:ascent/models/fitness_plan/style_allocation.dart';
import 'package:ascent/models/fitness_plan/workout.dart';
import 'package:ascent/services_and_utilities/general_utilities/get_this_sunday.dart';
import '../../constants.dart';

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
}