import 'package:ascent/models/fitness_plan/plan.dart';
import 'package:ascent/models/fitness_plan/plan_progress.dart';
import 'package:ascent/models/fitness_plan/planned_week.dart';
import 'package:ascent/models/fitness_plan/workout.dart';
import 'package:ascent/enums/exercise_style.dart';
import 'package:ascent/enums/session_type.dart';

class SamplePlanData {
  static Plan createSamplePlan() {
    final now = DateTime.now();
    final startOfWeek = _getStartOfWeek(now);

    // Week 1 - This week (mix of completed and planned)
    final week1Workouts = [
      Workout(
        date: startOfWeek.add(const Duration(days: 1)), // Monday
        type: SessionType.macro,
        style: ExerciseStyle.strength,
        isCompleted: true,
      ),
      Workout(
        date: startOfWeek.add(const Duration(days: 2)), // Tuesday
        type: SessionType.micro,
        style: ExerciseStyle.cardio,
        isCompleted: true,
      ),
      Workout(
        date: startOfWeek.add(const Duration(days: 3)), // Wednesday
        type: SessionType.macro,
        style: ExerciseStyle.strength,
        isCompleted: true,
      ),
      Workout(
        date: startOfWeek.add(const Duration(days: 5)), // Friday
        type: SessionType.micro,
        style: ExerciseStyle.flexibility,
        isCompleted: false,
      ),
      Workout(
        date: startOfWeek.add(const Duration(days: 6)), // Saturday
        type: SessionType.macro,
        style: ExerciseStyle.cardio,
        isCompleted: false,
      ),
    ];

    // Week 2 - Next week (all planned)
    final week2Start = startOfWeek.add(const Duration(days: 7));
    final week2Workouts = [
      Workout(
        date: week2Start.add(const Duration(days: 1)), // Monday
        type: SessionType.macro,
        style: ExerciseStyle.strength,
        isCompleted: false,
      ),
      Workout(
        date: week2Start.add(const Duration(days: 2)), // Tuesday
        type: SessionType.micro,
        style: ExerciseStyle.balance,
        isCompleted: false,
      ),
      Workout(
        date: week2Start.add(const Duration(days: 4)), // Thursday
        type: SessionType.macro,
        style: ExerciseStyle.functional,
        isCompleted: false,
      ),
      Workout(
        date: week2Start.add(const Duration(days: 6)), // Saturday
        type: SessionType.micro,
        style: ExerciseStyle.flexibility,
        isCompleted: false,
      ),
    ];

    // Week 3 - Progressive workouts
    final week3Start = startOfWeek.add(const Duration(days: 14));
    final week3Workouts = [
      Workout(
        date: week3Start.add(const Duration(days: 1)), // Monday
        type: SessionType.macro,
        style: ExerciseStyle.cardio,
        isCompleted: false,
      ),
      Workout(
        date: week3Start.add(const Duration(days: 3)), // Wednesday
        type: SessionType.macro,
        style: ExerciseStyle.strength,
        isCompleted: false,
      ),
      Workout(
        date: week3Start.add(const Duration(days: 5)), // Friday
        type: SessionType.micro,
        style: ExerciseStyle.functional,
        isCompleted: false,
      ),
    ];

    // Week 4 - Recovery week (lighter load)
    final week4Start = startOfWeek.add(const Duration(days: 21));
    final week4Workouts = [
      Workout(
        date: week4Start.add(const Duration(days: 2)), // Tuesday
        type: SessionType.micro,
        style: ExerciseStyle.flexibility,
        isCompleted: false,
      ),
      Workout(
        date: week4Start.add(const Duration(days: 4)), // Thursday
        type: SessionType.micro,
        style: ExerciseStyle.balance,
        isCompleted: false,
      ),
      Workout(
        date: week4Start.add(const Duration(days: 6)), // Saturday
        type: SessionType.macro,
        style: ExerciseStyle.strength,
        isCompleted: false,
      ),
    ];

    // Create sample weeks
    final week1 = PlannedWeek(weekIndex: 1, workouts: week1Workouts);
    final week2 = PlannedWeek(weekIndex: 2, workouts: week2Workouts);
    final week3 = PlannedWeek(weekIndex: 3, workouts: week3Workouts);
    final week4 = PlannedWeek(weekIndex: 4, workouts: week4Workouts);

    // Create sample plan starting from this week
    return Plan(
      startDate: startOfWeek,
      planProgress: PlanProgress(),
      weeks: [week1, week2, week3, week4],
    );
  }

  /// Get the start of the week (Sunday) for a given date
  static DateTime _getStartOfWeek(DateTime date) {
    final daysSinceLastSunday = date.weekday % 7;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysSinceLastSunday));
  }
}