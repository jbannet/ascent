import 'package:ascent/enums/exercise_style.dart';
import 'package:ascent/models/fitness_plan/workout.dart';

class StyleAllocation {
  Map<ExerciseStyle, int> minutes = {
    ExerciseStyle.strength: 0,
    ExerciseStyle.cardio: 0,
    ExerciseStyle.flexibility: 0,
    ExerciseStyle.balance: 0,
    ExerciseStyle.functional: 0,
  };

  StyleAllocation();
  get isEmpty => minutes.isEmpty || minutes.values.every((mins) => mins == 0);

  void addWorkout(Workout workout) {
    // Assuming each workout is 30 minutes for simplicity
    const int workoutDuration = 30;
    minutes[workout.style] = (minutes[workout.style] ?? 0) + workoutDuration;
  }

  StyleAllocation merge(StyleAllocation other) {
    final styleAllocation = StyleAllocation();
    styleAllocation.minutes = Map.from(minutes);
    other.minutes.forEach((style, mins) {
      styleAllocation.minutes[style] = (styleAllocation.minutes[style] ?? 0) + mins;
    });
    return styleAllocation;
  }

  Map<ExerciseStyle, double> toPercentages() {
    final totalMinutes = minutes.values.fold<int>(0, (sum, mins) => sum + mins);
    if (totalMinutes == 0) return {};

    final percentages = <ExerciseStyle, double>{};
    minutes.forEach((style, mins) {
      percentages[style] = (mins / totalMinutes) * 100;
    });
    return percentages;
  }

  //MARK: JSON
  Map<ExerciseStyle,int> toJson() {
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
