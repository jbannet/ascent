import 'package:ascent/constants_and_enums/workout_enums/exercise_category.dart';

class StyleAllocation {
  Map<ExerciseCategory, int> minutes = {
    ExerciseCategory.strength: 0,
    ExerciseCategory.cardio: 0,
    ExerciseCategory.flexibility: 0,
    ExerciseCategory.balance: 0,
    ExerciseCategory.functional: 0,
  };

  StyleAllocation();
  get isEmpty => minutes.isEmpty || minutes.values.every((mins) => mins == 0);

  StyleAllocation merge(StyleAllocation other) {
    final styleAllocation = StyleAllocation();
    styleAllocation.minutes = Map.from(minutes);
    other.minutes.forEach((style, mins) {
      styleAllocation.minutes[style] = (styleAllocation.minutes[style] ?? 0) + mins;
    });
    return styleAllocation;
  }

  Map<ExerciseCategory, double> toPercentages() {
    final totalMinutes = minutes.values.fold<int>(0, (sum, mins) => sum + mins);
    if (totalMinutes == 0) return {};

    final percentages = <ExerciseCategory, double>{};
    minutes.forEach((style, mins) {
      percentages[style] = (mins / totalMinutes) * 100;
    });
    return percentages;
  }

  //MARK: JSON
  Map<ExerciseCategory,int> toJson() {
    return minutes;
  }

  factory StyleAllocation.fromJson(Map<String, dynamic> json) {
    final allocation = StyleAllocation();
    json.forEach((key, value) {
      final style = exerciseStyleFromString(key);
      allocation.minutes[style] = value as int;
    });
    return allocation;
  }
}
