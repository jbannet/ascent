import 'package:ascent/models/fitness_profile_model/fitness_profile.dart';
import 'package:ascent/services_and_utilities/general_utilities/get_this_sunday.dart';

import '../../constants_and_enums/constants.dart';
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

  factory FourWeeks.generateFromFitnessProfile(FitnessProfile profile) {
    DateTime sundayDate = getThisSunday();
    final currentWeek = WeekOfWorkouts.generateFromFitnessProfile(profile, sundayDate);

    // Create the next 3 weeks
    final List<WeekOfWorkouts> nextWeeksList = [];
    for (int i = 0; i < 3; i++) {
      sundayDate = sundayDate.add(Duration(days: 7));
      nextWeeksList.add(WeekOfWorkouts.generateFromFitnessProfile(profile, sundayDate));
    }

    return FourWeeks(
      currentWeek: currentWeek,
      nextWeeks: nextWeeksList,
    );
  }
}