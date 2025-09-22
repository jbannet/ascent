import 'package:flutter_test/flutter_test.dart';
import 'package:ascent/models/fitness_plan/week_of_workouts.dart';

void main() {
  group('WeekOfWorkouts Date Comparison Methods', () {
    test('isSameWeek returns true for weeks with same Sunday', () {
      final sunday1 = DateTime(2024, 1, 7); // Sunday, January 7, 2024
      final sunday2 = DateTime(2024, 1, 7); // Same Sunday

      final week1 = WeekOfWorkouts(startDate: sunday1);
      final week2 = WeekOfWorkouts(startDate: sunday2);

      expect(week1.isSameWeek(week2), isTrue);
    });

    test('isSameWeek returns false for weeks with different Sundays', () {
      final sunday1 = DateTime(2024, 1, 7);  // Sunday, January 7, 2024
      final sunday2 = DateTime(2024, 1, 14); // Sunday, January 14, 2024

      final week1 = WeekOfWorkouts(startDate: sunday1);
      final week2 = WeekOfWorkouts(startDate: sunday2);

      expect(week1.isSameWeek(week2), isFalse);
    });

    test('containsDate returns true for dates in the same week', () {
      final sunday = DateTime(2024, 1, 7); // Sunday, January 7, 2024
      final week = WeekOfWorkouts(startDate: sunday);

      // Test various days of the same week
      expect(week.containsDate(DateTime(2024, 1, 7)),  isTrue); // Sunday
      expect(week.containsDate(DateTime(2024, 1, 8)),  isTrue); // Monday
      expect(week.containsDate(DateTime(2024, 1, 9)),  isTrue); // Tuesday
      expect(week.containsDate(DateTime(2024, 1, 10)), isTrue); // Wednesday
      expect(week.containsDate(DateTime(2024, 1, 11)), isTrue); // Thursday
      expect(week.containsDate(DateTime(2024, 1, 12)), isTrue); // Friday
      expect(week.containsDate(DateTime(2024, 1, 13)), isTrue); // Saturday
    });

    test('containsDate returns false for dates in different weeks', () {
      final sunday = DateTime(2024, 1, 7); // Sunday, January 7, 2024
      final week = WeekOfWorkouts(startDate: sunday);

      // Test dates from previous and next weeks
      expect(week.containsDate(DateTime(2024, 1, 6)),  isFalse); // Saturday before
      expect(week.containsDate(DateTime(2024, 1, 14)), isFalse); // Sunday after
    });

    test('containsDate correctly normalizes dates to Sunday', () {
      final sunday = DateTime(2024, 1, 7); // Sunday, January 7, 2024
      final week = WeekOfWorkouts(startDate: sunday);

      // Test with a Wednesday (January 10, 2024) - should find the Sunday
      final wednesday = DateTime(2024, 1, 10);
      expect(week.containsDate(wednesday), isTrue);

      // Test with a Wednesday from different week
      final nextWednesday = DateTime(2024, 1, 17);
      expect(week.containsDate(nextWednesday), isFalse);
    });

    test('isCurrentWeek works correctly', () {
      final now = DateTime.now();
      final currentSunday = now.subtract(Duration(days: now.weekday % 7));
      final nextSunday = currentSunday.add(Duration(days: 7));

      final currentWeek = WeekOfWorkouts(startDate: currentSunday);
      final nextWeek = WeekOfWorkouts(startDate: nextSunday);

      expect(currentWeek.isCurrentWeek, isTrue);
      expect(nextWeek.isCurrentWeek, isFalse);
    });
  });
}