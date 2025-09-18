import 'package:ascent/models/fitness_plan/style_allocation.dart';

import '../../enums/exercise_style.dart';
import '../../services/general_utilities/get_this_sunday.dart';
import '../../constants.dart';
import 'plan_progress.dart';
import 'four_weeks.dart';
import 'week_of_workouts.dart';

class Plan {
  final FourWeeks schedule;       // Next four weeks schedule
  final PlanProgress planProgress;  // all history: progress tracking


  Plan({
    required this.planProgress,
    required schedule,
  }) : schedule = schedule;

  factory Plan.fromJson(Map<String, dynamic> json) {
    if (json[PlanFields.scheduleField] == null) {
      throw ArgumentError('${PlanFields.scheduleField} is required in JSON');
    }
    return Plan(
      planProgress: json[PlanFields.planProgressField] != null
          ? PlanProgress.fromJson(json[PlanFields.planProgressField] as Map<String, dynamic>)
          : PlanProgress(),
      schedule: FourWeeks.fromJson(json[PlanFields.scheduleField] as Map<String, dynamic>)
    );
  }

  Map<String, dynamic> toJson() => {
    PlanFields.scheduleField: schedule.toJson(),
    PlanFields.planProgressField: planProgress.toJson(),
  };

  // Delegate to schedule for style allocation
  StyleAllocation getStyleAllocation() => schedule.styleAllocationInPercentages;

  // Get current week index based on start date
  int get currentWeekIndex => planProgress.currentWeekIndex;

  // Get the Sunday of the current week
  DateTime getThisSunday() => getThisSunday();

  // Delegate to schedule for week completion stats
  Map<String, int> getCurrentWeekCompletionStats(int weekIndex) => schedule.completionStats;

  // Delegate to schedule for getting next 4 weeks
  List<WeekOfWorkouts> getNext4Weeks() => schedule.next4Weeks;

  


}

DateTime _dateFromJson(String value) => DateTime.parse(value);
String _dateToJson(DateTime value) => value.toIso8601String().split('T').first;