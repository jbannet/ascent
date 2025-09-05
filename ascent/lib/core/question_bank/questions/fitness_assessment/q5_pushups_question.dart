import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';
import '../../reference_data/acsm_pushup_norms.dart';

/// Q5: How many push-ups can you do in a row (with good form)?
/// 
/// This question assesses upper body strength and muscular endurance.
/// It contributes to multiple ML features related to strength capacity.
class Q5PushupsQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q5';
  
  @override
  String get questionText => 'How many push-ups can you do in a row (with good form)?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'Do as many as you can without stopping';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0.0,
    'maxValue': 200.0,
    'allowDecimals': false,
    'unit': 'reps',
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final pushUpCount = (answer as num).toInt();
    final age = context['age'] as int? ?? 35; // Default age if not provided
    final gender = context['gender'] as String? ?? 'male'; // Default gender
    
    // Get age and gender-adjusted percentile (0.0 to 1.0)
    final percentile = ACSMPushupNorms.getPercentile(pushUpCount, age, gender);
    
    // Calculate various feature contributions
    return [
      // Primary upper body strength indicator
      FeatureContribution('upper_body_strength', percentile),
      
      // Secondary contributions
      FeatureContribution('muscular_endurance', percentile * 0.8),
      FeatureContribution('overall_strength', percentile * 0.6, ContributionType.add),
      
      // Raw count for specific calculations
      FeatureContribution('pushup_count_raw', pushUpCount / 50.0), // Normalize to ~0-1 range
      
      // Training readiness based on strength
      FeatureContribution('strength_training_readiness', _calculateReadiness(percentile)),
      
      // Age-adjusted fitness indicator
      FeatureContribution('strength_fitness_age_factor', _calculateAgeFactor(percentile, age)),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final count = answer.toInt();
    return count >= 0 && count <= 200; // Reasonable range
  }
  
  @override
  dynamic getDefaultAnswer() => 0; // Default to 0 push-ups if not answered
  
  //MARK: PRIVATE HELPERS
  
  /// Calculate training readiness based on push-up performance.
  /// Higher strength = more ready for advanced training.
  double _calculateReadiness(double percentile) {
    if (percentile >= 0.75) return 1.0; // 75th+ percentile = high readiness
    if (percentile >= 0.5) return 0.7;   // 50th+ percentile = moderate readiness
    if (percentile >= 0.25) return 0.4;  // 25th+ percentile = low readiness
    return 0.1; // Below 25th percentile = very low readiness
  }
  
  /// Calculate age factor for fitness assessment.
  /// This helps adjust expectations based on how performance compares to age norms.
  double _calculateAgeFactor(double percentile, int age) {
    // If performing above average for age, factor > 0.5
    // If performing below average for age, factor < 0.5
    return percentile;
  }
}