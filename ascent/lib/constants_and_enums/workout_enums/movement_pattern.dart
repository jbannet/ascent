enum MovementPattern {
  // Lower Body Patterns
  squat,
  singleLegSquat,
  hinge,
  singleLegHinge,
  lunge,

  // Upper Body Push Patterns
  horizontalPush,
  verticalPush,

  // Upper Body Pull Patterns
  horizontalPull,
  verticalPull,

  // Core & Stability Patterns
  antiExtension,
  antiRotation,
  antiLateralFlexion,
  rotation,

  // Functional/Athletic Patterns
  carry,
  throw_,
  jump,
  crawl,

  // Cardio/Conditioning Patterns
  steadyStateCardio,
  intervalCardio,

  // Mobility/Flexibility Patterns
  staticStretch,
  dynamicStretch,
  mobilityDrill;

  String toJson() => name;

  static MovementPattern fromJson(String value) {
    return MovementPattern.values.firstWhere(
      (pattern) => pattern.name == value,
      orElse: () => throw ArgumentError('Invalid movement pattern: $value'),
    );
  }
}
