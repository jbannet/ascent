import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../base/onboarding_question.dart';
import '../../base/feature_contribution.dart';

/// Q3: Do you get out of breath walking up 2 flights of stairs?
/// 
/// This question assesses cardiovascular fitness and functional capacity.
/// It contributes to cardio fitness and exercise intensity features.
class Q3StairsQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q3';
  
  @override
  String get questionText => 'Do you get out of breath walking up 2 flights of stairs?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Think about your typical response';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'not_at_all', label: 'Not at all'),
    QuestionOption(value: 'slightly', label: 'Slightly out of breath'),
    QuestionOption(value: 'moderately', label: 'Moderately out of breath'),
    QuestionOption(value: 'very', label: 'Very out of breath'),
    QuestionOption(value: 'avoid', label: 'I avoid stairs when possible'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final response = answer.toString();
    final age = context['age'] as int? ?? 35;
    
    // Convert response to cardiovascular fitness score
    final cardioScore = _getCardioScore(response);
    final ageAdjustedScore = _adjustForAge(cardioScore, age);
    
    return [
      // Primary cardiovascular fitness indicator
      FeatureContribution('cardiovascular_fitness', cardioScore),
      
      // Age-adjusted cardiovascular capacity
      FeatureContribution('cardio_fitness_age_adjusted', ageAdjustedScore),
      
      // Functional fitness level
      FeatureContribution('functional_fitness', cardioScore * 0.9),
      
      // Exercise intensity readiness
      FeatureContribution('cardio_intensity_readiness', _calculateIntensityReadiness(cardioScore)),
      
      // Training starting level
      FeatureContribution('cardio_training_level', _getTrainingLevel(cardioScore)),
      
      // Recovery capacity indicator
      FeatureContribution('recovery_capacity', cardioScore * 0.8),
      
      // Overall fitness contribution
      FeatureContribution('overall_fitness', cardioScore * 0.4, ContributionType.add),
      
      // Endurance exercise suitability
      FeatureContribution('endurance_exercise_ready', cardioScore > 0.5 ? 1.0 : 0.0),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['not_at_all', 'slightly', 'moderately', 'very', 'avoid'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'moderately'; // Conservative middle ground
  
  //MARK: PRIVATE HELPERS
  
  /// Convert stair response to cardiovascular fitness score (0.0 to 1.0)
  double _getCardioScore(String response) {
    switch (response) {
      case 'not_at_all':
        return 1.0; // Excellent cardio fitness
      case 'slightly':
        return 0.75; // Good cardio fitness
      case 'moderately':
        return 0.5; // Average cardio fitness
      case 'very':
        return 0.25; // Below average cardio fitness
      case 'avoid':
        return 0.1; // Poor cardio fitness
      default:
        return 0.5; // Default to average
    }
  }
  
  /// Adjust cardio score for age expectations
  double _adjustForAge(double baseScore, int age) {
    // Older adults naturally have different expectations
    if (age >= 65) {
      // More forgiving for seniors - slightly boost score
      return (baseScore + 0.1).clamp(0.0, 1.0);
    } else if (age >= 50) {
      // Slight boost for middle-aged
      return (baseScore + 0.05).clamp(0.0, 1.0);
    } else if (age < 30) {
      // Higher expectations for young adults
      return (baseScore - 0.05).clamp(0.0, 1.0);
    }
    return baseScore; // No adjustment for 30-49
  }
  
  /// Calculate readiness for cardio intensity training
  double _calculateIntensityReadiness(double cardioScore) {
    if (cardioScore >= 0.75) return 1.0; // Ready for high intensity
    if (cardioScore >= 0.5) return 0.7;   // Moderate intensity appropriate
    if (cardioScore >= 0.25) return 0.4;  // Low intensity only
    return 0.1; // Very low intensity, build base first
  }
  
  /// Get appropriate training level based on cardio fitness
  double _getTrainingLevel(double cardioScore) {
    if (cardioScore >= 0.75) return 0.8; // Advanced beginner to intermediate
    if (cardioScore >= 0.5) return 0.5;   // True beginner
    return 0.2; // Deconditioned - need gentle introduction
  }
}