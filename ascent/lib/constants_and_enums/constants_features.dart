/// Feature and profile constants for fitness assessment
class FeatureConstants {
  // Age bracket feature constants (ACSM 10-year brackets)
  static const String ageBracketUnder20 = '<20';
  static const String ageBracket20To29 = '20-29';
  static const String ageBracket30To39 = '30-39';
  static const String ageBracket40To49 = '40-49';
  static const String ageBracket50To59 = '50-59';
  static const String ageBracket60To69 = '60-69';
  static const String ageBracket70Plus = '70+';
  
  // Exercise category feature constants
  static const String categoryStrength = 'strength';
  static const String categoryBalance = 'balance';
  static const String categoryStretching = 'stretching';
  static const String categoryCardio = 'cardio';
  static const String categoryFunctional = 'functional';
  static const String categoryBodyweight = 'bodyweight';

  // Session commitment feature constants
  static const String fullSessionsPerWeek = 'full_sessions_per_week';
  static const String microSessionsPerWeek = 'micro_sessions_per_week';
  static const String totalTrainingDays = 'total_training_days';
  static const String weeklyTrainingMinutes = 'weekly_training_minutes';

  // Health risk feature constants
  static const String osteoporosisRisk = 'osteoporosis_risk';
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