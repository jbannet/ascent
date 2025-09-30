import 'dart:math';

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'workout_style_enum.dart';

enum Category {
  cardio('Cardio', Colors.red),
  strength('Strength', AppColors.basePurple),
  balance('Balance', Colors.blue),
  flexibility('Flexibility', AppColors.continueGreen),
  functional('Functional', Colors.brown);

  const Category(this.displayName, this.color);

  final String displayName;
  final Color color;

  String toJson() => name;

  static Category fromJson(String name) {
    return Category.values.firstWhere((category) => category.name == name);
  }

  List<WorkoutStyle> get defaultWorkoutStyles {
    switch (this) {
      case Category.cardio:
        return const [
          WorkoutStyle.enduranceDominant,
          WorkoutStyle.circuitMetabolic,
          WorkoutStyle.athleticConditioning,
          WorkoutStyle.fullBody,
          WorkoutStyle.concurrentHybrid,
          WorkoutStyle.pilatesStyle,
        ];
      case Category.strength:
        return const [
          WorkoutStyle.upperLowerSplit,
          WorkoutStyle.pushPullLegs,
          WorkoutStyle.concurrentHybrid,
          WorkoutStyle.fullBody,
          WorkoutStyle.athleticConditioning,
          WorkoutStyle.yogaFocused,
          WorkoutStyle.pilatesStyle,
        ];
      case Category.balance:
        return const [
          WorkoutStyle.functionalMovement,
          WorkoutStyle.yogaFocused,
          WorkoutStyle.seniorSpecific,
          WorkoutStyle.pilatesStyle,
        ];
      case Category.flexibility:
        return const [
          WorkoutStyle.yogaFocused,
          WorkoutStyle.pilatesStyle,
          WorkoutStyle.seniorSpecific,
        ];
      case Category.functional:
        return const [
          WorkoutStyle.functionalMovement,
          WorkoutStyle.strongmanFunctional,
          WorkoutStyle.crossfitMixed,
          WorkoutStyle.seniorSpecific,
        ];
    }
  }

  WorkoutStyle pickRandomStyle(Random random) {
    final styles = defaultWorkoutStyles;
    if (styles.isEmpty) {
      throw StateError('No workout styles configured for category $this');
    }
    return styles[random.nextInt(styles.length)];
  }
}
