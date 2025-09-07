/// Feature and profile constants for fitness assessment
class FeatureConstants {
  // Age bracket feature constants
  static const String ageBracketUnder18 = '<18';
  static const String ageBracket18To34 = '18-34';
  static const String ageBracket35To54 = '35-54';
  static const String ageBracket55To64 = '55-64';
  static const String ageBracket65To79 = '65-79';
  static const String ageBracket80Plus = '80+';
  
  // Exercise category feature constants
  static const String categoryStrength = 'strength';
  static const String categoryBalance = 'balance';
  static const String categoryLowImpact = 'low impact';
  static const String categoryStretching = 'stretching';
  static const String categoryCardio = 'cardio';
  static const String categoryBodyweight = 'bodyweight';
}

/// Profile constants for fitness assessment
class ProfileConstants {
  // Demographics
  static const String birthYear = 'birth_year';
  static const String age = 'age';
  
  // Training parameters
  static const String maxHeartRateFactor = 'max_heart_rate_factor';
  static const String recoveryAdjustmentFactor = 'recovery_adjustment_factor';
  static const String intensityTolerance = 'intensity_tolerance';
  static const String injuryRiskAgeFactor = 'injury_risk_age_factor';
  static const String requiresMedicalClearance = 'requires_medical_clearance';
  static const String mobilityPriority = 'mobility_priority';
  static const String balanceTrainingImportance = 'balance_training_importance';
  static const String metabolicRateFactor = 'metabolic_rate_factor';
  static const String musclePreservationPriority = 'muscle_preservation_priority';
}