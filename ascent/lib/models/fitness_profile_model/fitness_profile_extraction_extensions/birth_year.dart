import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';

/// Extension to calculate birth year and age-related profile values.
/// 
/// Uses age to calculate birth year and training parameters.
/// Stores birth_year for persistence since age changes over time.
extension BirthYear on FitnessProfile {
  
  /// Calculate birth year and age-related training parameters
  void calculateBirthYear() {
    final age = answers[AgeQuestion.questionId] as int?;
    
    if (age == null) {
      throw Exception('Missing required answer for birth year calculation: age=$age');
    }
    
    // Store birth year for persistence and reference age
    answers[ProfileConstants.birthYear] = (DateTime.now().year - age).toDouble();
    answers[ProfileConstants.age] = age.toDouble();
    
    // Training parameter calculations
    answers[ProfileConstants.maxHeartRateFactor] = _calculateMaxHRFactor(age);
    answers[ProfileConstants.recoveryAdjustmentFactor] = _calculateRecoveryFactor(age);
    answers[ProfileConstants.intensityTolerance] = _calculateIntensityTolerance(age);
    answers[ProfileConstants.injuryRiskAgeFactor] = _calculateInjuryRiskFactor(age);
    answers[ProfileConstants.requiresMedicalClearance] = age >= 50 ? 1.0 : 0.0;
    answers[ProfileConstants.mobilityPriority] = age >= 40 ? ((age - 40) / 60.0).clamp(0.0, 1.0) : 0.0;
    answers[ProfileConstants.balanceTrainingImportance] = age >= 50 ? ((age - 50) / 50.0).clamp(0.0, 1.0) : 0.0;
    answers[ProfileConstants.metabolicRateFactor] = _calculateMetabolicFactor(age);
    answers[ProfileConstants.musclePreservationPriority] = age >= 35 ? 1.0 : 0.0;
  }
  
  /// Calculate max heart rate factor for training zones
  double _calculateMaxHRFactor(int age) {
    // Standard formula: 220 - age, normalized to 0-1 scale
    final maxHR = 220 - age;
    return (maxHR / 220.0).clamp(0.5, 1.0);
  }
  
  /// Calculate recovery adjustment factor
  double _calculateRecoveryFactor(int age) {
    // Younger people recover faster
    if (age < 25) return 1.0;
    if (age < 35) return 0.9;
    if (age < 45) return 0.8;
    if (age < 55) return 0.7;
    if (age < 65) return 0.6;
    return 0.5; // 65+ need more recovery time
  }
  
  /// Calculate intensity tolerance
  double _calculateIntensityTolerance(int age) {
    // Peak tolerance around 20-30, gradually decreases
    if (age >= 18 && age <= 30) return 1.0;
    if (age < 18) return 0.8; // Youth need modified intensity
    if (age <= 40) return 0.9;
    if (age <= 50) return 0.8;
    if (age <= 60) return 0.7;
    return 0.6; // Seniors need lower intensity focus
  }
  
  /// Calculate injury risk factor based on age
  double _calculateInjuryRiskFactor(int age) {
    // Risk increases with age due to tissue changes
    if (age < 25) return 0.2;
    if (age < 35) return 0.3;
    if (age < 45) return 0.4;
    if (age < 55) return 0.6;
    if (age < 65) return 0.7;
    return 0.8; // Higher risk for seniors
  }
  
  /// Calculate metabolic rate factor
  double _calculateMetabolicFactor(int age) {
    // Metabolic rate decreases with age
    if (age < 25) return 1.0;
    if (age < 35) return 0.95;
    if (age < 45) return 0.9;
    if (age < 55) return 0.85;
    if (age < 65) return 0.8;
    return 0.75; // Lower metabolic rate for seniors
  }
}