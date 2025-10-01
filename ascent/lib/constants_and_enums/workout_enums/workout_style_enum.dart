import 'package:flutter/material.dart';
import 'movement_pattern.dart';

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

  /// Get warmup patterns for this workout style
  List<MovementPattern> get warmupPatterns {
    switch (this) {
      case WorkoutStyle.fullBody:
        return [MovementPattern.dynamicStretch, MovementPattern.mobilityDrill];
      case WorkoutStyle.upperLowerSplit:
      case WorkoutStyle.pushPullLegs:
      case WorkoutStyle.concurrentHybrid:
      case WorkoutStyle.enduranceDominant:
        return [MovementPattern.dynamicStretch];
      case WorkoutStyle.circuitMetabolic:
      case WorkoutStyle.crossfitMixed:
      case WorkoutStyle.athleticConditioning:
        return [MovementPattern.dynamicStretch, MovementPattern.jump];
      case WorkoutStyle.strongmanFunctional:
      case WorkoutStyle.functionalMovement:
        return [MovementPattern.dynamicStretch, MovementPattern.mobilityDrill];
      case WorkoutStyle.yogaFocused:
      case WorkoutStyle.pilatesStyle:
        return [MovementPattern.mobilityDrill];
      case WorkoutStyle.seniorSpecific:
        return [MovementPattern.mobilityDrill, MovementPattern.staticStretch];
    }
  }

  /// Get main work patterns for this workout style
  List<MovementPattern> get mainWorkPatterns {
    switch (this) {
      case WorkoutStyle.fullBody:
        return [
          MovementPattern.squat,
          MovementPattern.hinge,
          MovementPattern.horizontalPush,
          MovementPattern.horizontalPull,
          MovementPattern.verticalPush,
        ];
      case WorkoutStyle.upperLowerSplit:
        // TODO: Should alternate between upper/lower based on history
        return [
          MovementPattern.squat,
          MovementPattern.lunge,
          MovementPattern.hinge,
          MovementPattern.antiExtension,
        ];
      case WorkoutStyle.pushPullLegs:
        // TODO: Should rotate through push/pull/legs cycle
        return [
          MovementPattern.horizontalPush,
          MovementPattern.verticalPush,
          MovementPattern.antiExtension,
        ];
      case WorkoutStyle.circuitMetabolic:
        return [
          MovementPattern.squat,
          MovementPattern.horizontalPush,
          MovementPattern.horizontalPull,
          MovementPattern.steadyStateCardio,
        ];
      case WorkoutStyle.enduranceDominant:
        return [
          MovementPattern.steadyStateCardio,
          MovementPattern.squat,
          MovementPattern.hinge,
          MovementPattern.horizontalPull,
        ];
      case WorkoutStyle.strongmanFunctional:
        return [
          MovementPattern.carry,
          MovementPattern.hinge,
          MovementPattern.throw_,
          MovementPattern.crawl,
        ];
      case WorkoutStyle.crossfitMixed:
        return [
          MovementPattern.squat,
          MovementPattern.hinge,
          MovementPattern.horizontalPush,
          MovementPattern.jump,
          MovementPattern.throw_,
          MovementPattern.steadyStateCardio,
        ];
      case WorkoutStyle.functionalMovement:
        return [
          MovementPattern.squat,
          MovementPattern.lunge,
          MovementPattern.carry,
          MovementPattern.crawl,
          MovementPattern.antiRotation,
        ];
      case WorkoutStyle.yogaFocused:
        return [
          MovementPattern.staticStretch,
          MovementPattern.dynamicStretch,
        ];
      case WorkoutStyle.seniorSpecific:
        return [
          MovementPattern.squat,
          MovementPattern.lunge,
          MovementPattern.staticStretch,
          MovementPattern.carry,
        ];
      case WorkoutStyle.pilatesStyle:
        return [
          MovementPattern.antiExtension,
          MovementPattern.antiRotation,
          MovementPattern.antiLateralFlexion,
          MovementPattern.rotation,
        ];
      case WorkoutStyle.athleticConditioning:
        return [
          MovementPattern.jump,
          MovementPattern.throw_,
          MovementPattern.squat,
          MovementPattern.hinge,
        ];
      case WorkoutStyle.concurrentHybrid:
        return [
          MovementPattern.squat,
          MovementPattern.hinge,
          MovementPattern.horizontalPush,
          MovementPattern.steadyStateCardio,
        ];
    }
  }

  /// Get cooldown patterns for this workout style
  List<MovementPattern> get cooldownPatterns {
    switch (this) {
      case WorkoutStyle.enduranceDominant:
      case WorkoutStyle.concurrentHybrid:
        return [MovementPattern.staticStretch, MovementPattern.steadyStateCardio];
      case WorkoutStyle.functionalMovement:
      case WorkoutStyle.seniorSpecific:
        return [MovementPattern.staticStretch, MovementPattern.mobilityDrill];
      default:
        return [MovementPattern.staticStretch];
    }
  }

  /// Calculate number of sets based on duration
  int calculateSets(int durationMinutes) {
    switch (this) {
      case WorkoutStyle.fullBody:
        if (durationMinutes <= 15) return 2;
        if (durationMinutes <= 45) return 3;
        return 4;
      case WorkoutStyle.upperLowerSplit:
      case WorkoutStyle.pushPullLegs:
        if (durationMinutes <= 15) return 3;
        if (durationMinutes <= 45) return 4;
        return 5;
      case WorkoutStyle.circuitMetabolic:
      case WorkoutStyle.crossfitMixed:
        if (durationMinutes <= 15) return 2;
        if (durationMinutes <= 45) return 3;
        return 4;
      case WorkoutStyle.enduranceDominant:
      case WorkoutStyle.concurrentHybrid:
        if (durationMinutes <= 15) return 2;
        if (durationMinutes <= 45) return 2;
        return 3;
      case WorkoutStyle.strongmanFunctional:
        if (durationMinutes <= 15) return 3;
        if (durationMinutes <= 45) return 4;
        return 5;
      case WorkoutStyle.functionalMovement:
        if (durationMinutes <= 15) return 2;
        if (durationMinutes <= 45) return 3;
        return 3;
      case WorkoutStyle.yogaFocused:
      case WorkoutStyle.seniorSpecific:
        return 1; // Holds/stretches, not traditional sets
      case WorkoutStyle.pilatesStyle:
        if (durationMinutes <= 15) return 1;
        if (durationMinutes <= 45) return 2;
        return 3;
      case WorkoutStyle.athleticConditioning:
        if (durationMinutes <= 15) return 3;
        if (durationMinutes <= 45) return 4;
        return 5;
    }
  }

  /// Calculate number of reps based on duration
  int calculateReps(int durationMinutes) {
    switch (this) {
      case WorkoutStyle.fullBody:
        if (durationMinutes <= 15) return 8;
        if (durationMinutes <= 45) return 10;
        return 12;
      case WorkoutStyle.upperLowerSplit:
      case WorkoutStyle.pushPullLegs:
        if (durationMinutes <= 15) return 8;
        if (durationMinutes <= 45) return 10;
        return 12;
      case WorkoutStyle.circuitMetabolic:
      case WorkoutStyle.crossfitMixed:
        return 15; // High reps for metabolic work
      case WorkoutStyle.enduranceDominant:
      case WorkoutStyle.concurrentHybrid:
        return 12; // Moderate reps for endurance
      case WorkoutStyle.strongmanFunctional:
        return 5; // Low reps, heavy loads
      case WorkoutStyle.functionalMovement:
        if (durationMinutes <= 15) return 10;
        if (durationMinutes <= 45) return 12;
        return 15;
      case WorkoutStyle.yogaFocused:
        if (durationMinutes <= 15) return 30; // seconds per hold
        if (durationMinutes <= 45) return 50;
        return 70;
      case WorkoutStyle.seniorSpecific:
        if (durationMinutes <= 15) return 8;
        if (durationMinutes <= 45) return 10;
        return 12;
      case WorkoutStyle.pilatesStyle:
        if (durationMinutes <= 15) return 12;
        if (durationMinutes <= 45) return 15;
        return 20;
      case WorkoutStyle.athleticConditioning:
        if (durationMinutes <= 15) return 6;
        if (durationMinutes <= 45) return 8;
        return 10;
    }
  }

  /// Calculate rest period in seconds based on duration
  int calculateRestSeconds(int durationMinutes) {
    switch (this) {
      case WorkoutStyle.fullBody:
        if (durationMinutes <= 15) return 45;
        if (durationMinutes <= 45) return 60;
        return 90;
      case WorkoutStyle.upperLowerSplit:
      case WorkoutStyle.pushPullLegs:
        if (durationMinutes <= 15) return 45;
        if (durationMinutes <= 45) return 75;
        return 120;
      case WorkoutStyle.circuitMetabolic:
        return 30; // Short rest for metabolic conditioning
      case WorkoutStyle.enduranceDominant:
      case WorkoutStyle.concurrentHybrid:
        return 60; // Moderate rest
      case WorkoutStyle.strongmanFunctional:
        if (durationMinutes <= 15) return 90;
        if (durationMinutes <= 45) return 120;
        return 180; // Long rest for heavy loads
      case WorkoutStyle.crossfitMixed:
        if (durationMinutes <= 15) return 30;
        if (durationMinutes <= 45) return 60;
        return 90;
      case WorkoutStyle.functionalMovement:
        if (durationMinutes <= 15) return 45;
        return 60;
      case WorkoutStyle.yogaFocused:
        return 15; // Transition time between holds
      case WorkoutStyle.seniorSpecific:
        return 60; // Longer rest for safety
      case WorkoutStyle.pilatesStyle:
        return 30; // Short rest, controlled movements
      case WorkoutStyle.athleticConditioning:
        if (durationMinutes <= 15) return 60;
        if (durationMinutes <= 45) return 90;
        return 120;
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