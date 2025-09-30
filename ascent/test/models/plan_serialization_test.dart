import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/models/fitness_plan/week_of_workouts.dart';
import 'package:ascent/models/fitness_plan/four_weeks.dart';
import 'package:ascent/models/fitness_plan/plan.dart';
import 'package:ascent/models/fitness_plan/plan_progress.dart';
import 'package:ascent/models/fitness_plan/workout.dart';
import 'package:ascent/constants_and_enums/session_type.dart';
import 'package:ascent/constants_and_enums/workout_enums/workout_style_enum.dart';

void main() {
  group('Plan Serialization with Date-Based Week Identification', () {
    test('WeekOfWorkouts serialization preserves Sunday dates', () {
      final sunday = DateTime(2024, 1, 7); // Sunday, January 7, 2024
      final workouts = [
        Workout(type: SessionType.full, style: WorkoutStyle.upperLowerSplit, isCompleted: true),
        Workout(type: SessionType.micro, style: WorkoutStyle.enduranceDominant, isCompleted: false),
      ];

      final week = WeekOfWorkouts(
        startDate: sunday,
        workouts: workouts,
      );

      // Serialize to JSON
      final json = week.toJson();

      // Verify JSON contains expected fields (no weekIndex)
      expect(json.containsKey('week_index'), isFalse);
      expect(json['start_date'], equals(sunday.toIso8601String()));
      expect(json['workouts'], hasLength(2));

      // Deserialize from JSON
      final deserializedWeek = WeekOfWorkouts.fromJson(json);

      // Verify deserialized week matches original
      expect(deserializedWeek.startDate, equals(sunday));
      expect(deserializedWeek.workouts, hasLength(2));
      expect(deserializedWeek.workouts[0].isCompleted, isTrue);
      expect(deserializedWeek.workouts[1].isCompleted, isFalse);

      // Test new date-based methods work on deserialized week
      expect(deserializedWeek.isCurrentWeek, isFalse); // 2024 date is not current
      expect(deserializedWeek.containsDate(DateTime(2024, 1, 10)), isTrue); // Wednesday of that week
      expect(deserializedWeek.containsDate(DateTime(2024, 1, 14)), isFalse); // Sunday of next week
    });

    test('Plan serialization with FourWeeks preserves all week dates', () {
      final thisSunday = DateTime(2024, 1, 7);
      final nextSunday = thisSunday.add(Duration(days: 7));
      final week3Sunday = thisSunday.add(Duration(days: 14));
      final week4Sunday = thisSunday.add(Duration(days: 21));

      // Create weeks with proper dates
      final currentWeek = WeekOfWorkouts(
        startDate: thisSunday,
        workouts: [Workout(type: SessionType.full, style: WorkoutStyle.upperLowerSplit, isCompleted: true)],
      );

      final nextWeeks = [
        WeekOfWorkouts(startDate: nextSunday, workouts: []),
        WeekOfWorkouts(startDate: week3Sunday, workouts: []),
        WeekOfWorkouts(startDate: week4Sunday, workouts: []),
      ];

      final fourWeeks = FourWeeks(
        currentWeek: currentWeek,
        nextWeeks: nextWeeks,
      );

      final plan = Plan(
        planProgress: PlanProgress(),
        nextFourWeeks: fourWeeks,
      );

      // Serialize plan
      final planJson = plan.toJson();

      // Deserialize plan
      final deserializedPlan = Plan.fromJson(planJson);

      // Verify all weeks have correct dates
      final deserializedWeeks = deserializedPlan.next4Weeks;
      expect(deserializedWeeks, hasLength(4));

      expect(deserializedWeeks[0].startDate, equals(thisSunday));
      expect(deserializedWeeks[1].startDate, equals(nextSunday));
      expect(deserializedWeeks[2].startDate, equals(week3Sunday));
      expect(deserializedWeeks[3].startDate, equals(week4Sunday));

      // Test week comparison methods work
      expect(deserializedWeeks[0].isSameWeek(currentWeek), isTrue);
      expect(deserializedWeeks[1].isSameWeek(currentWeek), isFalse);
    });

    test('Week comparison works across serialization boundary', () {
      final sunday = DateTime(2024, 1, 7);

      final originalWeek = WeekOfWorkouts(
        startDate: sunday,
        workouts: [],
      );

      // Serialize and deserialize
      final json = originalWeek.toJson();
      final deserializedWeek = WeekOfWorkouts.fromJson(json);

      // Weeks should be considered the same despite being different objects
      expect(originalWeek.isSameWeek(deserializedWeek), isTrue);
      expect(deserializedWeek.isSameWeek(originalWeek), isTrue);

      // Both should contain the same dates
      final wednesday = DateTime(2024, 1, 10);
      expect(originalWeek.containsDate(wednesday), isTrue);
      expect(deserializedWeek.containsDate(wednesday), isTrue);
    });
  });
}