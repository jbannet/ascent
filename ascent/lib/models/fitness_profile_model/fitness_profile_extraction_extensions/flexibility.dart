import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';

/// Extension to calculate flexibility and stretching metrics.
/// 
/// This extension focuses on core flexibility/stretching metrics:
/// 1. Flexibility assessment scores
/// 2. Range of motion indicators
/// 3. Movement quality metrics
/// 4. Age-related flexibility decline factors
/// 
/// Based on Exercise and Sport Sciences Reviews 2024, ACSM Position Stand.
/// Note: Stretching importance is calculated in relative_objective_importance.dart
extension Flexibility on FitnessProfile {
  
  /// Calculate flexibility and stretching metrics
  void calculateStretching() {
    final age = AgeQuestion.instance.calculatedAge;
    
    if (age == null) {
      throw Exception('Missing required answer for stretching calculation: age=$age');
    }
    
    // Calculate flexibility-specific metrics
    _calculateFlexibilityBaseline(age);
    _calculateRangeOfMotionMetrics(age);
    _calculateStretchingParameters(age);
  }
  
  /// Calculate baseline flexibility metrics based on age-related decline
  void _calculateFlexibilityBaseline(int age) {
    // Research shows flexibility declines ~6-10% per decade after age 30
    double flexibilityScore = 1.0;
    
    if (age >= 30) {
      final decadesPastThirty = (age - 30) / 10.0;
      flexibilityScore -= (decadesPastThirty * 0.08); // 8% per decade
    }
    
    featuresMap['flexibility_baseline'] = flexibilityScore.clamp(0.4, 1.0);
  }
  
  /// Calculate range of motion metrics
  void _calculateRangeOfMotionMetrics(int age) {
    // TODO: Add specific ROM assessments when flexibility tests are available
    
    // Age-related ROM decline patterns (research-based)
    double shoulderFlexibility = 1.0;
    double spineFlexibility = 1.0;
    double hipFlexibility = 1.0;
    
    if (age >= 40) {
      shoulderFlexibility -= (age - 40) * 0.01; // 1% per year after 40
      spineFlexibility -= (age - 40) * 0.012;   // Faster decline in spine
      hipFlexibility -= (age - 40) * 0.008;    // Slower decline in hips
    }
    
    featuresMap['shoulder_flexibility'] = shoulderFlexibility.clamp(0.5, 1.0);
    featuresMap['spine_flexibility'] = spineFlexibility.clamp(0.4, 1.0);
    featuresMap['hip_flexibility'] = hipFlexibility.clamp(0.6, 1.0);
  }
  
  /// Calculate stretching training parameters
  void _calculateStretchingParameters(int age) {
    // Older adults need longer hold times and more frequent stretching
    if (age < 40) {
      featuresMap['stretch_hold_time_sec'] = 30.0;
      featuresMap['stretch_frequency_per_week'] = 3.0;
    } else if (age < 65) {
      featuresMap['stretch_hold_time_sec'] = 45.0;
      featuresMap['stretch_frequency_per_week'] = 4.0;
    } else {
      featuresMap['stretch_hold_time_sec'] = 60.0;
      featuresMap['stretch_frequency_per_week'] = 5.0;
    }
    
    // Recovery time between stretching sessions (shorter than strength)
    featuresMap['stretch_recovery_hours'] = 24.0; // Can stretch daily
  }
}