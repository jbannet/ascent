import 'package:ascent/models/fitness_profile_model/reference_data/acsm_cardio_norms.dart';
import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';
import '../../../workflows/question_bank/questions/fitness_assessment/q4_twelve_minute_run_question.dart';

/// Extension to calculate cardiovascular fitness metrics and training parameters.
/// 
/// This extension focuses on core cardio metrics:
/// 1. CARDIOVASCULAR FITNESS BASELINE: Current fitness level metrics
///    - VO2max (ml/kg/min) from Cooper test or estimation
///    - METs capacity (metabolic equivalents)
///    - Fitness percentile for age/gender
/// 
/// 2. WORKOUT CONSTRUCTION PARAMETERS: Values needed to build cardio workouts
///    - Maximum heart rate (age-based)
///    - Target heart rate zones (5 zones)
///    - MET levels for each training zone
///    - Recovery requirements
/// 
/// Note: Cardio importance is calculated in relative_objective_importance.dart
extension Cardio on FitnessProfile {
  
  /// Calculate cardiovascular fitness metrics and training parameters
  void calculateCardio() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for cardio calculation: age=$age, gender=$gender');
    }
    
    // 1. Calculate baseline fitness metrics
    _calculateCardiovascularBaseline(age, gender);
    
    // 2. Calculate workout parameters including HR zones
    _calculateCardioWorkoutParameters(age, gender);
  }
  
  /// Calculate baseline cardiovascular fitness metrics from Cooper test
  void _calculateCardiovascularBaseline(int age, String gender) {
    // Primary: Use Cooper test if available
    final cooperDistanceMiles = Q4TwelveMinuteRunQuestion.instance.getTwelveMinuteRunDistance(answers);
    if (cooperDistanceMiles != null && cooperDistanceMiles > 0) {
      // Calculate VO2max using updated ACSM reference (now uses miles)
      double vo2max = ACSMCardioNorms.estimateVO2Max(cooperDistanceMiles);
      featuresMap['vo2max'] = vo2max;
      
      // Convert to METs capacity (VO2max / 3.5)
      featuresMap['mets_capacity'] = vo2max / 3.5;
      
      // Get fitness percentile using updated ACSM data (now uses miles)
      featuresMap['cardio_fitness_percentile'] = ACSMCardioNorms.getPercentile(
        cooperDistanceMiles, age, gender
      );
    }
  }
  
  
  /// Calculate workout parameters including heart rate zones and MET levels
  void _calculateCardioWorkoutParameters(int age, String gender) {
    // Calculate Maximum Heart Rate using Tanaka formula
    // 208 - (0.7 × age) - more accurate than 220-age
    double maxHR = 208 - (0.7 * age);
    featuresMap['max_heart_rate'] = maxHR;
    
    // Simple 5-zone heart rate system using %MaxHR
    featuresMap['hr_zone1'] = maxHR * 0.55;  // Zone 1: Recovery (50-60%)
    featuresMap['hr_zone2'] = maxHR * 0.65;  // Zone 2: Aerobic base (60-70%)
    featuresMap['hr_zone3'] = maxHR * 0.75;  // Zone 3: Threshold (70-80%)
    featuresMap['hr_zone4'] = maxHR * 0.85;  // Zone 4: VO2max (80-90%)
    featuresMap['hr_zone5'] = maxHR * 0.92;  // Zone 5: Neuromuscular (90-95%)
    
    // MET-based training zones
    final mets = featuresMap['mets_capacity'] ?? 8.0;
    featuresMap['met_zone1'] = mets * 0.4;   // Recovery
    featuresMap['met_zone2'] = mets * 0.6;   // Aerobic base
    featuresMap['met_zone3'] = mets * 0.75;  // Threshold
    featuresMap['met_zone4'] = mets * 0.85;  // VO2max
    featuresMap['met_zone5'] = mets * 0.95;  // Neuromuscular
    
    // Recovery needs based on age
    featuresMap['cardio_recovery_days'] = age < 40 ? 1.0 : (age < 60 ? 2.0 : 3.0);
  }
}