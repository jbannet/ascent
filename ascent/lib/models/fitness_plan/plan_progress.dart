import 'package:ascent/models/fitness_plan/week_of_workouts.dart';
import '../../constants_and_enums/constants.dart';

class PlanProgress {
  final List<WeekOfWorkouts> completedWeeks;

  PlanProgress({this.completedWeeks = const []});

  get currentWeekIndex => completedWeeks.length;

  int completedMinutes() {
    // Placeholder implementation
    //TODO: implement
    return 1000;
  }

  int get completedSessions {
    // Placeholder implementation
    //TODO: implement
    return 1000;
  }

  

  factory PlanProgress.fromJson(Map<String, dynamic> json) {
    return PlanProgress(
      completedWeeks: (json[PlanFields.completedWeeksField] as List<dynamic>?)
          ?.map((e) => WeekOfWorkouts.fromJson(Map<String, dynamic>.from(e)))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    PlanFields.completedWeeksField: completedWeeks.map((e) => e.toJson()).toList(),
  };

}