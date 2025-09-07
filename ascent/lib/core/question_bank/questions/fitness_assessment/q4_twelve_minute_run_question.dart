import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';
import '../../fitness_profile_model/feature_contribution.dart';
import '../../reference_data/acsm_cardio_norms.dart';

/// Q4: How far can you run/walk in 12 minutes? (Cooper Test)
/// 
/// This question assesses cardiovascular fitness using the standardized Cooper 12-minute test.
/// It contributes to cardio fitness, VO2 max estimation, and training intensity features.
class Q4TwelveMinuteRunQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q4';
  
  @override
  String get questionText => 'How far can you run/walk in 12 minutes?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'Enter distance in meters (estimate if unsure)';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 500.0,    // Minimum reasonable distance
    'maxValue': 5000.0,   // Maximum reasonable distance
    'allowDecimals': false,
    'unit': 'meters',
    'placeholder': '2000',
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  void evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final distance = (answer as num).toDouble();
    final age = demographics['age']?.toInt() ?? 35;
    final gender = demographics['gender'] == 1.0 ? 'male' : (demographics['gender'] == 2.0 ? 'female' : 'male');
    
    // Get age and gender-adjusted percentile
    final percentile = ACSMCardioNorms.getPercentile(distance, age, gender);
    final estimatedVO2Max = ACSMCardioNorms.estimateVO2Max(distance);
    
    // Primary cardiovascular fitness indicators
    features['cardiovascular_fitness'] = percentile;
    features['cardio_fitness_percentile'] = percentile;
    
    // VO2 Max estimation (normalized to 0-1 scale)
    features['estimated_vo2_max'] = (estimatedVO2Max / 60.0).clamp(0.0, 1.0);
    
    // Raw performance data
    features['twelve_minute_distance'] = distance / 3000.0; // Normalize around average
    
    // Training intensity readiness
    features['cardio_intensity_readiness'] = _calculateIntensityReadiness(percentile);
    
    // Aerobic base fitness
    features['aerobic_base'] = percentile * 0.9;
    
    // Endurance training suitability
    features['endurance_training_ready'] = percentile > 0.4 ? 1.0 : 0.0;
    
    // Recovery capacity (higher fitness = better recovery)
    features['cardio_recovery_capacity'] = percentile * 0.8;
    
    // Overall fitness contribution (ADD operation)
    features['overall_fitness'] = (features['overall_fitness'] ?? 0.0) + (percentile * 0.5);
    
    // Age-adjusted performance factor
    features['cardio_age_performance'] = _calculateAgeAdjustedPerformance(percentile, age);
    
    // Training volume capacity
    features['cardio_volume_capacity'] = _calculateVolumeCapacity(percentile);
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final distance = answer.toDouble();
    return distance >= 500 && distance <= 5000; // Reasonable range for 12 minutes
  }
  
  @override
  dynamic getDefaultAnswer() => 2000; // Average distance for general population
  
  //MARK: PRIVATE HELPERS
  
  /// Calculate readiness for different cardio training intensities
  double _calculateIntensityReadiness(double percentile) {
    if (percentile >= 0.8) return 1.0;   // Ready for high intensity intervals
    if (percentile >= 0.6) return 0.8;   // Ready for moderate-high intensity
    if (percentile >= 0.4) return 0.6;   // Moderate intensity appropriate
    if (percentile >= 0.2) return 0.4;   // Low-moderate intensity only
    return 0.2; // Very low intensity base building needed
  }
  
  /// Calculate age-adjusted performance factor
  double _calculateAgeAdjustedPerformance(double percentile, int age) {
    // Older adults performing well relative to peers deserve recognition
    if (age >= 60) {
      return (percentile + 0.1).clamp(0.0, 1.0); // Boost for seniors
    } else if (age >= 50) {
      return (percentile + 0.05).clamp(0.0, 1.0); // Slight boost for middle age
    } else if (age < 25) {
      return (percentile - 0.05).clamp(0.0, 1.0); // Higher expectations for young adults
    }
    return percentile; // No adjustment for 25-49
  }
  
  /// Calculate capacity for training volume
  double _calculateVolumeCapacity(double percentile) {
    // Higher fitness = can handle more training volume
    if (percentile >= 0.8) return 1.0;   // High volume capable
    if (percentile >= 0.6) return 0.8;   // Moderate-high volume
    if (percentile >= 0.4) return 0.6;   // Moderate volume
    if (percentile >= 0.2) return 0.4;   // Low volume to start
    return 0.2; // Very conservative volume needed
  }
}