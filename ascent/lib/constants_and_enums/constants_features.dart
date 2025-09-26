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

/// Strength-related feature constants
class StrengthConstants {
  // Feature Keys - Percentiles and Performance
  static const String upperBodyStrengthPercentile = 'upper_body_strength_percentile';
  static const String lowerBodyStrengthPercentile = 'lower_body_strength_percentile';
  static const String strengthFitnessPercentile = 'strength_fitness_percentile';
  static const String pushupCount = 'pushup_count';
  static const String squatCount = 'squat_count';

  // Feature Keys - Functional Assessments
  static const String functionalStrengthLevel = 'functional_strength_level';
  static const String needsBasicStrength = 'needs_basic_strength';
  static const String needsFunctionalTraining = 'needs_functional_training';
  static const String needsSeatedExercises = 'needs_seated_exercises';
  static const String canDoChairStand = 'can_do_chair_stand';
  static const String fallRiskModifier = 'fall_risk_modifier';

  // Feature Keys - Training Parameters
  static const String strengthRecoveryHours = 'strength_recovery_hours';
  static const String strengthOptimalRepRangeMin = 'strength_optimal_rep_range_min';
  static const String strengthOptimalRepRangeMax = 'strength_optimal_rep_range_max';
  static const String strengthTimeBetweenSets = 'strength_time_between_sets';
  static const String strengthPercentOf1RM = 'strength_percent_of_1RM';
  static const String strengthOptimalSetsRangeMin = 'strength_optimal_sets_range_min';
  static const String strengthOptimalSetsRangeMax = 'strength_optimal_sets_range_max';

  // Percentile Thresholds
  static const double veryLowPercentile = 10.0;
  static const double belowAveragePercentile = 25.0;
  static const double averagePercentile = 50.0;
  static const double aboveAveragePercentile = 75.0;
  static const double excellentPercentile = 90.0;
  static const double defaultStrengthPercentile = 50.0;

  // Age Thresholds
  static const int youngAdultAgeThreshold = 40;
  static const int middleAgedThreshold = 50;
  static const int olderAdultThreshold = 60;

  // Recovery Hours by Age Group
  static const double youngAdultRecoveryHours = 48.0;
  static const double middleAgedRecoveryHours = 72.0;
  static const double olderAdultRecoveryHours = 96.0;

  // Rep Range Values
  static const double beginnerRepRangeMin = 10.0;
  static const double beginnerRepRangeMax = 15.0;
  static const double intermediateRepRangeMin = 8.0;
  static const double intermediateRepRangeMax = 12.0;

  // Rest Time Values (seconds)
  static const double olderAdultRestTime = 45.0;
  static const double strengthPowerRestTime = 150.0;
  static const double hypertrophyRestTime = 90.0;

  // 1RM Percentage Values
  static const double olderNovice1RMPercent = 45.0;
  static const double veryWeak1RMPercent = 40.0;
  static const double experiencedLifter1RMPercent = 80.0;
  static const double noviceIntermediate1RMPercent = 55.0;

  // Sets Range Values
  static const double beginnerSetsMin = 1.0;
  static const double beginnerSetsMax = 3.0;
  static const double advancedSetsMin = 3.0;
  static const double advancedSetsMax = 5.0;
  static const double normalSetsMin = 2.0;
  static const double normalSetsMax = 4.0;

  // Functional Strength Values
  static const double basicFunctionalLevel = 0.3;
  static const double moderateFunctionalLevel = 0.5;
  static const double goodFunctionalLevel = 0.7;
  static const double fullFunctionalLevel = 1.0;
  static const double noFunctionalLevel = 0.0;

  // Binary Flag Values
  static const double flagTrue = 1.0;
  static const double flagFalse = 0.0;

  // Percentile Values for Special Cases
  static const double veryLowButFunctionalPercentile = 15.0;
  static const double conservativeEstimatePercentile = 10.0;

  // Weighting Factors
  static const double upperBodyWeight = 0.4;
  static const double lowerBodyWeight = 0.6;
  static const double fallRiskModifierValue = 0.3;

  // Functional Squat Thresholds
  static const int fullFunctionalSquats = 15;
  static const int goodFunctionalSquats = 10;
  static const int moderateFunctionalSquats = 5;

  // Error Messages
  static const String missingAgeGenderError = 'Missing required answers for strength calculation: age=\$age, gender=\$gender';
}

/// Age-related constants used across multiple extractors
class AgeThresholds {
  static const int youngAdult = 30;
  static const int middleAged = 40;
  static const int preOlder = 50;
  static const int older = 60;
  static const int elderly = 70;

  // Functional training age thresholds
  static const int functionalTrainingYoungThreshold = 50;
  static const int functionalTrainingElderlyThreshold = 70;

  // Functional squat count thresholds by age
  static const int youngFunctionalSquatThreshold = 15;
  static const int middleAgedFunctionalSquatThreshold = 10;
  static const int elderlyFunctionalSquatThreshold = 5;
}

/// Cardio-related feature constants
class CardioConstants {
  // Feature Keys - Performance Metrics
  static const String cardioPace = 'cardio_pace';
  static const String vo2max = 'vo2max';
  static const String metsCapacity = 'mets_capacity';
  static const String cardioFitnessPercentile = 'cardio_fitness_percentile';
  static const String maxHeartRate = 'max_heart_rate';

  // Feature Keys - Heart Rate Zones
  static const String hrZone1 = 'hr_zone1';
  static const String hrZone2 = 'hr_zone2';
  static const String hrZone3 = 'hr_zone3';
  static const String hrZone4 = 'hr_zone4';
  static const String hrZone5 = 'hr_zone5';

  // Feature Keys - MET Zones
  static const String metZone1 = 'met_zone1';
  static const String metZone2 = 'met_zone2';
  static const String metZone3 = 'met_zone3';
  static const String metZone4 = 'met_zone4';
  static const String metZone5 = 'met_zone5';

  // Heart Rate Zone Multipliers
  static const double hrZone1Multiplier = 0.55; // Recovery (50-60%)
  static const double hrZone2Multiplier = 0.65; // Aerobic base (60-70%)
  static const double hrZone3Multiplier = 0.75; // Threshold (70-80%)
  static const double hrZone4Multiplier = 0.85; // VO2max (80-90%)
  static const double hrZone5Multiplier = 0.92; // Neuromuscular (90-95%)

  // MET Zone Multipliers
  static const double metZone1Multiplier = 0.4; // Recovery
  static const double metZone2Multiplier = 0.6; // Aerobic base
  static const double metZone3Multiplier = 0.75; // Threshold
  static const double metZone4Multiplier = 0.85; // VO2max
  static const double metZone5Multiplier = 0.95; // Neuromuscular

  // VO2 Calculation Constants
  static const double vo2WalkingSpeedMultiplier = 0.2;
  static const double vo2RestingMetabolicRate = 3.5; // ml/kg/min
  static const double vo2ToMetsConversionFactor = 3.5;

  // Default Values
  static const double defaultMetsCapacity = 8.0;
  static const double defaultVO2MaxMale = 35.0;
  static const double defaultVO2MaxFemale = 30.0;

  // Percentile Ranges
  static const List<double> percentileValues = [5.0, 10.0, 25.0, 50.0, 75.0, 90.0, 95.0];

  // Age-based max heart rate calculation
  static const int standardMaxHRAge = 220;
}

/// Balance-related feature constants
/// AUTHORIZED FEATURES (per __design_fitness_profile.txt):
/// - can_do_chair_stand
/// - fall_history
/// - fall_risk_factor_count
/// - fear_of_falling
/// - needs_seated_exercises
class BalanceConstants {
  // Feature Keys - Only the 5 authorized features
  static const String canDoChairStand = 'can_do_chair_stand';
  static const String fallHistory = 'fall_history';
  static const String fallRiskFactorCount = 'fall_risk_factor_count';
  static const String fearOfFalling = 'fear_of_falling';
  static const String needsSeatedExercises = 'needs_seated_exercises';

  // Balance Capacity Thresholds (for internal calculations only)
  static const double excellentBalanceThreshold = 30.0;
  static const double goodBalanceThreshold = 15.0;
  static const double fairBalanceThreshold = 5.0;
  static const double highFallRiskThreshold = 5.0;

  // Balance Capacity Levels (for internal calculations only)
  static const double excellentBalanceCapacity = 1.0;
  static const double goodBalanceCapacity = 0.7;
  static const double fairBalanceCapacity = 0.4;
  static const double poorBalanceCapacity = 0.1;

  // Binary Flag Values
  static const double flagTrue = 1.0;
  static const double flagFalse = 0.0;
}

/// Objective importance calculation constants
class ObjectiveImportanceConstants {
  // Base Importance Scores
  static const double cardioBaseImportance = 0.25;
  static const double strengthBaseImportance = 0.3;
  static const double balanceBaseImportance = 0.1;
  static const double stretchingBaseImportance = 0.15;
  static const double functionalBaseImportance50Plus = 0.1;
  static const double functionalBaseImportanceUnder50 = 0.0;

  // Goal Alignment Score Adjustments
  static const double loseWeightCardioBonus = 0.4;
  static const double improveEnduranceCardioBonus = 0.5;
  static const double betterHealthCardioBonus = 0.3;
  static const double liveLongerCardioBonus = 0.3;
  static const double buildMuscleStrengthBonus = 0.5;
  static const double betterHealthStrengthBonus = 0.25;
  static const double liveLongerStrengthBonus = 0.25;
  static const double increaseFlexibilityStretchingBonus = 0.4;
  static const double betterHealthStretchingBonus = 0.2;
  static const double betterHealthFunctionalBonus = 0.15;

  // Fitness Gap Adjustments
  static const double cardioFitnessGapThreshold = 0.4;
  static const double cardioFitnessGapMultiplier = 0.6;

  // Age-Based Risk Factors
  static const int cardiovascularRiskAgeThreshold = 40;
  static const double cardioAgeRiskFactorPerYear = 0.008;
  static const int sarcopeniaRiskAgeThreshold = 30;
  static const double strengthAgeRiskFactorPerYear = 0.01;
  static const int flexibilityDeclineAgeThreshold = 30;
  static const double flexibilityAgeRiskFactorPerYear = 0.005;

  // Gender-Specific Adjustments
  static const int femaleMenopauseCardioAge = 50;
  static const double femaleMenopauseCardioBonus = 0.1;
  static const int femaleBoneMassDeclineAge = 35;
  static const double femaleBoneMassStrengthBonus = 0.1;
  static const int femaleMenopauseStrengthAge = 50;
  static const double femaleMenopauseStrengthBonus = 0.15;
  static const int femaleFallRiskAge = 45;
  static const double femaleFallRiskBalanceBonus = 0.1;
  static const int femaleFunctionalRiskAge = 65;
  static const double femaleFunctionalRiskBonus = 0.1;

  // Activity Deficit Adjustments
  static const double noCardioActivityBonus = 0.25;
  static const double noStrengthActivityBonus = 0.2;
  static const double noFlexibilityActivityBonus = 0.15;

  // GLP-1 Medication Adjustments
  static const double glp1CardioReduction = 0.2;
  static const double glp1StrengthBonus = 1.0;

  // BMI-Based Adjustments
  static const int lowBmiStrengthAgeThreshold = 35;
  static const double lowBmiThreshold = 20.0;
  static const double lowBmiStrengthBonus = 0.4;
  static const double bmiConversionFactor = 703.0;

  // Balance Risk Factors
  static const double fallHistoryMaxPriority = 1.0;
  static const int balanceCriticalRiskAge = 65;
  static const double balanceCriticalRiskBonus = 0.6;
  static const int balanceModerateRiskAge = 50;
  static const double balanceModerateRiskBonus = 0.3;
  static const int balanceLowRiskAge = 40;
  static const double balanceLowRiskBonus = 0.1;
  static const double balanceProblemsBonus = 0.4;
  static const double fearFallingBonus = 0.2;
  static const double mobilityAidsBonus = 0.3;

  // Injury/Pain Adjustments
  static const double injuryHistoryFlexibilityBonus = 0.25;

  // Beginner Adjustments
  static const double beginnerStrengthBonus = 0.15;
  static const double beginnerFlexibilityBonus = 0.2;
  static const int beginnerBalanceAgeThreshold = 50;
  static const double beginnerBalanceBonus = 0.15;

  // Functional Training Age Thresholds
  static const int functionalTrainingYoungThreshold = 50;
  static const int functionalTrainingAge80Plus = 80;
  static const double functionalAge80PlusBonus = 0.7;
  static const int functionalTrainingAge70Plus = 70;
  static const double functionalAge70PlusBonus = 0.5;
  static const int functionalTrainingAge65Plus = 65;
  static const double functionalAge65PlusBonus = 0.35;
  static const int functionalTrainingAge60Plus = 60;
  static const double functionalAge60PlusBonus = 0.25;
  static const int functionalTrainingAge55Plus = 55;
  static const double functionalAge55PlusBonus = 0.15;

  // Functional Deficit Markers
  static const double fallHistoryFunctionalBonus = 0.6;
  static const double fallHistoryYoungFunctionalBonus = 0.3;
  static const double chairStandDeficitFunctionalBonus = 0.8;
  static const double chairStandDeficitYoungFunctionalBonus = 0.5;
  static const double functionalHealthGoalsAgeThreshold = 60;

  // Normalization Constants
  static const double equalWeightingFallback = 0.2;
  static const double functionalScoreClampMin = 0.0;
  static const double functionalScoreClampMax = 2.0;

  // Feature Map Keys (already defined in FeatureConstants but referenced here)
  static const String cardioFitnessPercentileKey = 'cardio_fitness_percentile';
}

/// Weight management-related feature constants
/// AUTHORIZED FEATURES (per __design_fitness_profile.txt):
/// - weight_pounds
/// - height_inches
/// - bmi
/// - weight_objective (lose/gain/maintain)
/// - needs_weight_loss (BMI > 25)
class WeightManagementConstants {
  // Feature Keys - Only the 5 authorized features
  static const String weightPounds = 'weight_pounds';
  static const String heightInches = 'height_inches';
  static const String bmi = 'bmi';
  static const String weightObjective = 'weight_objective';
  static const String needsWeightLoss = 'needs_weight_loss';

  // Unit Conversion Constants
  static const double poundsToKgConversion = 0.453592;
  static const double inchesToMeterConversion = 0.0254;

  // BMI Cutoff Values
  static const double overweightCutoff = 25.0;

  // Weight Objectives
  static const double weightLossObjective = 0.0;
  static const double weightGainObjective = 1.0;
  static const double weightMaintenanceObjective = 2.0;

  // Binary Flag Values
  static const double flagTrue = 1.0;
  static const double flagFalse = 0.0;
}

/// Flexibility-related feature constants
/// AUTHORIZED FEATURES (per __design_fitness_profile.txt):
/// - days_stretching_per_week
class FlexibilityConstants {
  // Feature Key - Only the 1 authorized feature
  static const String daysStretchingPerWeek = 'days_stretching_per_week';
}