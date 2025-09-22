import 'package:ascent/models/fitness_plan/plan.dart';
import 'package:ascent/models/fitness_plan/plan_progress.dart';
import 'package:ascent/models/fitness_plan/week_of_workouts.dart';
import 'package:ascent/models/fitness_plan/four_weeks.dart';
import 'package:ascent/models/fitness_plan/workout.dart';
import 'package:ascent/models/fitness_profile_model/fitness_profile.dart';
import 'package:ascent/constants_and_enums/workout_style_enum.dart';
import 'package:ascent/constants_and_enums/session_type.dart';
import 'package:ascent/constants_and_enums/constants_features.dart';

class SamplePlanData {
  static Plan createSamplePlan() {
    final now = DateTime.now();
    final startOfWeek = _getStartOfWeek(now);

    // Week 1 - This week (mix of completed and planned)
    final week1Workouts = [
      Workout(
        date: startOfWeek.add(const Duration(days: 1)), // Monday
        type: SessionType.full,
        style: WorkoutStyle.upperLowerSplit,
        isCompleted: true,
      ),
      Workout(
        date: startOfWeek.add(const Duration(days: 2)), // Tuesday
        type: SessionType.micro,
        style: WorkoutStyle.enduranceDominant,
        isCompleted: true,
      ),
      Workout(
        date: startOfWeek.add(const Duration(days: 3)), // Wednesday
        type: SessionType.full,
        style: WorkoutStyle.pushPullLegs,
        isCompleted: true,
      ),
      Workout(
        date: startOfWeek.add(const Duration(days: 5)), // Friday
        type: SessionType.micro,
        style: WorkoutStyle.yogaFocused,
        isCompleted: false,
      ),
      Workout(
        date: startOfWeek.add(const Duration(days: 6)), // Saturday
        type: SessionType.full,
        style: WorkoutStyle.circuitMetabolic,
        isCompleted: false,
      ),
    ];

    // Week 2 - Next week (all planned)
    final week2Start = startOfWeek.add(const Duration(days: 7));
    final week2Workouts = [
      Workout(
        date: week2Start.add(const Duration(days: 1)), // Monday
        type: SessionType.full,
        style: WorkoutStyle.fullBody,
        isCompleted: false,
      ),
      Workout(
        date: week2Start.add(const Duration(days: 2)), // Tuesday
        type: SessionType.micro,
        style: WorkoutStyle.seniorSpecific,
        isCompleted: false,
      ),
      Workout(
        date: week2Start.add(const Duration(days: 4)), // Thursday
        type: SessionType.full,
        style: WorkoutStyle.functionalMovement,
        isCompleted: false,
      ),
      Workout(
        date: week2Start.add(const Duration(days: 6)), // Saturday
        type: SessionType.micro,
        style: WorkoutStyle.pilatesStyle,
        isCompleted: false,
      ),
    ];

    // Week 3 - Progressive workouts
    final week3Start = startOfWeek.add(const Duration(days: 14));
    final week3Workouts = [
      Workout(
        date: week3Start.add(const Duration(days: 1)), // Monday
        type: SessionType.full,
        style: WorkoutStyle.athleticConditioning,
        isCompleted: false,
      ),
      Workout(
        date: week3Start.add(const Duration(days: 3)), // Wednesday
        type: SessionType.full,
        style: WorkoutStyle.strongmanFunctional,
        isCompleted: false,
      ),
      Workout(
        date: week3Start.add(const Duration(days: 5)), // Friday
        type: SessionType.micro,
        style: WorkoutStyle.crossfitMixed,
        isCompleted: false,
      ),
    ];

    // Week 4 - Recovery week (lighter load)
    final week4Start = startOfWeek.add(const Duration(days: 21));
    final week4Workouts = [
      Workout(
        date: week4Start.add(const Duration(days: 2)), // Tuesday
        type: SessionType.micro,
        style: WorkoutStyle.yogaFocused,
        isCompleted: false,
      ),
      Workout(
        date: week4Start.add(const Duration(days: 4)), // Thursday
        type: SessionType.micro,
        style: WorkoutStyle.seniorSpecific,
        isCompleted: false,
      ),
      Workout(
        date: week4Start.add(const Duration(days: 6)), // Saturday
        type: SessionType.full,
        style: WorkoutStyle.concurrentHybrid,
        isCompleted: false,
      ),
    ];

    // Create sample weeks with proper Sunday dates
    final week1 = WeekOfWorkouts(startDate: startOfWeek, workouts: week1Workouts);
    final week2 = WeekOfWorkouts(startDate: week2Start, workouts: week2Workouts);
    final week3 = WeekOfWorkouts(startDate: week3Start, workouts: week3Workouts);
    final week4 = WeekOfWorkouts(startDate: week4Start, workouts: week4Workouts);

    // Create sample plan starting from this week
    return Plan(
      planProgress: PlanProgress(),
      nextFourWeeks: FourWeeks(
        currentWeek: week1,
        nextWeeks: [week2, week3, week4],
      ),
      fitnessProfile: _createSampleFitnessProfile(),
    );
  }

  /// Get the start of the week (Sunday) for a given date
  static DateTime _getStartOfWeek(DateTime date) {
    final daysSinceLastSunday = date.weekday % 7;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysSinceLastSunday));
  }

  /// Create sample FitnessProfile data for testing
  static FitnessProfile _createSampleFitnessProfile() {
    final featureOrder = [
      FeatureConstants.categoryCardio,
      FeatureConstants.categoryStrength,
      FeatureConstants.categoryBalance,
      FeatureConstants.categoryStretching,
      FeatureConstants.categoryFunctional,
      FeatureConstants.categoryBodyweight,
      FeatureConstants.fullSessionsPerWeek,
      FeatureConstants.microSessionsPerWeek,
    ];

    final sampleAnswers = <String, dynamic>{
      'age': 32,
      'experience_level': 'beginner',
      'goals': ['strength', 'balance', 'flexibility'],
    };

    // Use storage constructor to avoid calculateAllFeatures() call
    final profile = FitnessProfile.createFitnessProfileFromStorage(featureOrder, sampleAnswers);

    // Set realistic feature values to display meaningful category allocations
    profile.featuresMap[FeatureConstants.categoryCardio] = 0.25;     // 25%
    profile.featuresMap[FeatureConstants.categoryStrength] = 0.35;   // 35%
    profile.featuresMap[FeatureConstants.categoryBalance] = 0.20;    // 20%
    profile.featuresMap[FeatureConstants.categoryStretching] = 0.15; // 15%
    profile.featuresMap[FeatureConstants.categoryFunctional] = 0.05; // 5%
    profile.featuresMap[FeatureConstants.fullSessionsPerWeek] = 2.0;
    profile.featuresMap[FeatureConstants.microSessionsPerWeek] = 3.0;

    return profile;
  }
}
