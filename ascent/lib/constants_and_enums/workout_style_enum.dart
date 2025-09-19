import 'package:flutter/material.dart';

enum WorkoutStyle {
  fullBody('full_body', '⏱️', Colors.purple),
  upperLowerSplit('upper_lower_split', '💪', Colors.orange),
  pushPullLegs('push_pull_legs', '💪', Colors.orange),
  concurrentHybrid('concurrent_hybrid', '⏱️', Colors.teal),
  circuitMetabolic('circuit_metabolic', '🔥', Colors.red),
  enduranceDominant('endurance_dominant', '❤️', Colors.pink),
  strongmanFunctional('strongman_functional', '⛰️', Colors.brown),
  crossfitMixed('crossfit_mixed', '⏱️', Colors.indigo),
  functionalMovement('functional_movement', '💎', Colors.blue),
  yogaFocused('yoga_focused', '🧘', Colors.green),
  seniorSpecific('senior_specific', '⭐', Colors.amber),
  pilatesStyle('pilates_style', '💎', Colors.cyan),
  athleticConditioning('athletic_conditioning', '⚡', Colors.deepOrange);

  const WorkoutStyle(this.value, this.icon, this.color);

  final String value;
  final String icon;
  final Color color;

  /// One-liner for JSON serialization
  String toJson() => value;

  /// Static method for deserialization
  static WorkoutStyle fromJson(String value) {
    return WorkoutStyle.values.firstWhere((style) => style.value == value);
  }

  String get displayName {
    switch (this) {
      case WorkoutStyle.fullBody:
        return 'Full-Body (FB)';
      case WorkoutStyle.upperLowerSplit:
        return 'Upper/Lower Split (UL)';
      case WorkoutStyle.pushPullLegs:
        return 'Push/Pull/Legs (PPL)';
      case WorkoutStyle.concurrentHybrid:
        return 'Concurrent / Hybrid';
      case WorkoutStyle.circuitMetabolic:
        return 'Circuit / Metabolic Conditioning';
      case WorkoutStyle.enduranceDominant:
        return 'Endurance-Dominant';
      case WorkoutStyle.strongmanFunctional:
        return 'Strongman / Functional Strength';
      case WorkoutStyle.crossfitMixed:
        return 'CrossFit / Mixed Modal';
      case WorkoutStyle.functionalMovement:
        return 'Functional Fitness / Movement Quality';
      case WorkoutStyle.yogaFocused:
        return 'Yoga-Focused';
      case WorkoutStyle.seniorSpecific:
        return 'Senior-Specific';
      case WorkoutStyle.pilatesStyle:
        return 'Pilates Style';
      case WorkoutStyle.athleticConditioning:
        return 'Athletic Conditioning';
    }
  }
}

/// Helper function to convert string to WorkoutStyle
WorkoutStyle workoutStyleFromString(String value) {
  return WorkoutStyle.fromJson(value);
}

/// Helper function to convert WorkoutStyle to string
String workoutStyleToString(WorkoutStyle style) {
  return style.toJson();
}