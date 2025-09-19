import 'package:ascent/models/fitness_plan/style_allocation.dart';
import 'package:ascent/models/fitness_profile_model/fitness_profile.dart';
import '../../constants_and_enums/constants.dart';
import 'plan_progress.dart';
import 'four_weeks.dart';
import 'week_of_workouts.dart';

class Plan {
  final FourWeeks nextFourWeeks;       // Next four weeks schedule
  final PlanProgress planProgress;  // all history: progress tracking


  Plan({
    required this.planProgress,
    required this.nextFourWeeks,
  });

  // Get current week index based on start date
  int get currentWeekIndex => planProgress.currentWeekIndex;
  // Delegate to schedule for week completion stats
  WeekCompletionStats getCurrentWeekCompletionStats(int weekIndex) => nextFourWeeks.completionStats;
  // Delegate to schedule for getting next 4 weeks
  List<WeekOfWorkouts> get next4Weeks => nextFourWeeks.next4Weeks;

  factory Plan.generateFromFitnessProfile(FitnessProfile profile) {
    // Generate the next four weeks from fitness profile
    final fourWeeks = FourWeeks.generateFromFitnessProfile(profile);
    final planProgress = PlanProgress();

    return Plan(
      nextFourWeeks: fourWeeks,
      planProgress: planProgress,
    );
  }
      

  //MARK: JSON
  factory Plan.fromJson(Map<String, dynamic> json) {
    if (json[PlanFields.scheduleField] == null) {
      throw ArgumentError('${PlanFields.scheduleField} is required in JSON');
    }
    return Plan(
      planProgress: json[PlanFields.planProgressField] != null
          ? PlanProgress.fromJson(json[PlanFields.planProgressField] as Map<String, dynamic>)
          : PlanProgress(),
      nextFourWeeks: FourWeeks.fromJson(json[PlanFields.scheduleField] as Map<String, dynamic>)
    );
  }

  Map<String, dynamic> toJson() => {
    PlanFields.scheduleField: nextFourWeeks.toJson(),
    PlanFields.planProgressField: planProgress.toJson(),
  };

}