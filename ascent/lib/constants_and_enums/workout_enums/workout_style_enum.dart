import 'package:flutter/material.dart';
import 'movement_pattern.dart';
import 'pattern_with_preference.dart';

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

  /// Get main work patterns for this workout style with compound/isolation preferences
  List<PatternWithPreference> get mainWorkPatterns {
    switch (this) {
      case WorkoutStyle.fullBody:
        return [
          PatternWithPreference(MovementPattern.squat, true), // Compound
          PatternWithPreference(MovementPattern.hinge, true), // Compound
          PatternWithPreference(MovementPattern.horizontalPush, null), // Mix
          PatternWithPreference(MovementPattern.horizontalPull, true), // Compound
          PatternWithPreference(MovementPattern.verticalPush, null), // Mix
        ];
      case WorkoutStyle.upperLowerSplit:
        // TODO: Should alternate between upper/lower based on history
        return [
          PatternWithPreference(MovementPattern.squat, true), // Compound
          PatternWithPreference(MovementPattern.lunge, null), // Mix
          PatternWithPreference(MovementPattern.hinge, true), // Compound
          PatternWithPreference(MovementPattern.antiExtension, false), // Isolation core
        ];
      case WorkoutStyle.pushPullLegs:
        // TODO: Should rotate through push/pull/legs cycle
        return [
          PatternWithPreference(MovementPattern.horizontalPush, null), // Mix
          PatternWithPreference(MovementPattern.verticalPush, null), // Mix
          PatternWithPreference(MovementPattern.antiExtension, false), // Isolation core
        ];
      case WorkoutStyle.circuitMetabolic:
        return [
          PatternWithPreference(MovementPattern.squat, true), // Compound for circuits
          PatternWithPreference(MovementPattern.horizontalPush, true), // Compound
          PatternWithPreference(MovementPattern.horizontalPull, true), // Compound
          PatternWithPreference(MovementPattern.steadyStateCardio, null), // N/A
        ];
      case WorkoutStyle.enduranceDominant:
        return [
          PatternWithPreference(MovementPattern.steadyStateCardio, null), // N/A
          PatternWithPreference(MovementPattern.squat, true), // Compound
          PatternWithPreference(MovementPattern.hinge, false), // Isolation hinge for endurance
          PatternWithPreference(MovementPattern.horizontalPull, true), // Compound
        ];
      case WorkoutStyle.strongmanFunctional:
        return [
          PatternWithPreference(MovementPattern.carry, null), // Functional
          PatternWithPreference(MovementPattern.hinge, true), // Heavy compound
          PatternWithPreference(MovementPattern.throw_, null), // Functional
          PatternWithPreference(MovementPattern.crawl, null), // Functional
        ];
      case WorkoutStyle.crossfitMixed:
        return [
          PatternWithPreference(MovementPattern.squat, true), // Compound
          PatternWithPreference(MovementPattern.hinge, true), // Compound
          PatternWithPreference(MovementPattern.horizontalPush, true), // Compound
          PatternWithPreference(MovementPattern.jump, null), // Plyometric
          PatternWithPreference(MovementPattern.throw_, null), // Power
          PatternWithPreference(MovementPattern.steadyStateCardio, null), // N/A
        ];
      case WorkoutStyle.functionalMovement:
        return [
          PatternWithPreference(MovementPattern.squat, true), // Compound
          PatternWithPreference(MovementPattern.lunge, null), // Mix
          PatternWithPreference(MovementPattern.carry, null), // Functional
          PatternWithPreference(MovementPattern.crawl, null), // Functional
          PatternWithPreference(MovementPattern.antiRotation, false), // Core isolation
        ];
      case WorkoutStyle.yogaFocused:
        return [
          PatternWithPreference(MovementPattern.staticStretch, null), // Flexibility
          PatternWithPreference(MovementPattern.dynamicStretch, null), // Flexibility
        ];
      case WorkoutStyle.seniorSpecific:
        return [
          PatternWithPreference(MovementPattern.squat, null), // Mix for safety
          PatternWithPreference(MovementPattern.lunge, false), // Isolation for control
          PatternWithPreference(MovementPattern.staticStretch, null), // Flexibility
          PatternWithPreference(MovementPattern.carry, null), // Functional
        ];
      case WorkoutStyle.pilatesStyle:
        return [
          PatternWithPreference(MovementPattern.antiExtension, false), // Core isolation
          PatternWithPreference(MovementPattern.antiRotation, false), // Core isolation
          PatternWithPreference(MovementPattern.antiLateralFlexion, false), // Core isolation
          PatternWithPreference(MovementPattern.rotation, false), // Core isolation
        ];
      case WorkoutStyle.athleticConditioning:
        return [
          PatternWithPreference(MovementPattern.jump, null), // Plyometric
          PatternWithPreference(MovementPattern.throw_, null), // Power
          PatternWithPreference(MovementPattern.squat, true), // Compound
          PatternWithPreference(MovementPattern.hinge, true), // Compound
        ];
      case WorkoutStyle.concurrentHybrid:
        return [
          PatternWithPreference(MovementPattern.squat, true), // Compound
          PatternWithPreference(MovementPattern.hinge, true), // Compound
          PatternWithPreference(MovementPattern.horizontalPush, null), // Mix
          PatternWithPreference(MovementPattern.steadyStateCardio, null), // N/A
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