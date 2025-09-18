import '../fitness_profile.dart';
import '../../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4_run_vo2_question.dart';

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
  
  /// Calculate baseline cardiovascular fitness metrics from run data
  void _calculateCardiovascularBaseline(int age, String gender) {
    // Get distance and time from the question
    final runDistanceMiles = Q4TwelveMinuteRunQuestion.instance.getRunDistanceMiles(answers);
    final runTimeMinutes = Q4TwelveMinuteRunQuestion.instance.getRunTimeMinutes(answers);

    if (runDistanceMiles != null && runDistanceMiles > 0 && runTimeMinutes != null && runTimeMinutes > 0) {
      // Calculate pace in minutes per mile
      final paceMinutesPerMile = runTimeMinutes / runDistanceMiles;

      // TODO: Convert pace to VO2max using formula from user
      // For now, use a placeholder estimation based on pace
      double vo2max = _estimateVO2MaxFromPace(paceMinutesPerMile);
      featuresMap['vo2max'] = vo2max;

      // Convert to METs capacity (VO2max / 3.5)
      featuresMap['mets_capacity'] = vo2max / 3.5;

      // TODO: Update percentile calculation when user provides conversion formula
      // For now, use a simple pace-based percentile
      featuresMap['cardio_fitness_percentile'] = _estimatePercentileFromPace(paceMinutesPerMile, age, gender);
    }
  }

  /// Placeholder function to estimate VO2max from pace
  /// This will be replaced with the user's provided formula
  double _estimateVO2MaxFromPace(double paceMinutesPerMile) {
    // Rough estimation: faster pace = higher VO2max
    // A 6-minute mile pace ≈ 70 VO2max, 10-minute mile ≈ 40 VO2max
    if (paceMinutesPerMile <= 5.0) return 75.0;
    if (paceMinutesPerMile <= 6.0) return 65.0;
    if (paceMinutesPerMile <= 7.0) return 55.0;
    if (paceMinutesPerMile <= 8.0) return 50.0;
    if (paceMinutesPerMile <= 9.0) return 45.0;
    if (paceMinutesPerMile <= 10.0) return 40.0;
    if (paceMinutesPerMile <= 12.0) return 35.0;
    return 30.0;
  }

  /// Placeholder function to estimate fitness percentile from pace
  /// This will be refined when the user provides the conversion formula
  double _estimatePercentileFromPace(double paceMinutesPerMile, int age, String gender) {
    // Simple age and gender adjustments for percentile
    double basePercentile = 50.0;

    // Adjust based on pace (faster = higher percentile)
    if (paceMinutesPerMile <= 6.0) {
      basePercentile = 90.0;
    } else if (paceMinutesPerMile <= 7.0) {
      basePercentile = 80.0;
    } else if (paceMinutesPerMile <= 8.0) {
      basePercentile = 70.0;
    } else if (paceMinutesPerMile <= 9.0) {
      basePercentile = 60.0;
    } else if (paceMinutesPerMile <= 10.0) {
      basePercentile = 50.0;
    } else if (paceMinutesPerMile <= 12.0) {
      basePercentile = 40.0;
    } else {
      basePercentile = 30.0;
    }

    // Simple age adjustment (younger = slight bonus)
    if (age < 30) {
      basePercentile += 5.0;
    } else if (age > 50) {
      basePercentile -= 5.0;
    }

    // Keep within bounds
    return basePercentile.clamp(5.0, 95.0);
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