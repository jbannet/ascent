import 'package:ascent/models/fitness_plan/workout.dart';

class PlannedWeek {
  final int weekIndex;
  List<Workout> workouts;

  PlannedWeek({ required this.weekIndex, List<Workout>? workouts }) :
    workouts = workouts ?? <Workout>[];

  factory PlannedWeek.fromJson(Map<String, dynamic> json) => PlannedWeek(
    weekIndex: json['week_index'] as int,
    workouts: (json['workouts'] as List<dynamic>? )?.map((e)=> Workout.fromJson(Map<String, dynamic>.from(e))).toList() ?? <Workout>[],
  );

  Map<String, dynamic> toJson() => {
    'week_index': weekIndex,
    'workouts': workouts.map((e)=> e.toJson()).toList(),
  };
}