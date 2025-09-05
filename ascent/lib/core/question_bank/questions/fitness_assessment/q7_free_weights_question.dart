import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Q7: How comfortable are you with free weights (dumbbells, barbells)?
/// 
/// This question assesses strength training experience and equipment comfort.
/// It contributes to exercise selection, safety, and program complexity features.
class Q7FreeWeightsQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q7';
  
  @override
  String get questionText => 'How comfortable are you with free weights (dumbbells, barbells)?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Consider your experience and confidence level';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'never_used', label: 'Never used them'),
    QuestionOption(value: 'tried_few', label: 'Tried a few times, felt unsure'),
    QuestionOption(value: 'somewhat', label: 'Somewhat comfortable with basic movements'),
    QuestionOption(value: 'comfortable', label: 'Comfortable with most exercises'),
    QuestionOption(value: 'very_experienced', label: 'Very experienced, can train independently'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final response = answer.toString();
    final comfortLevel = _getComfortLevel(response);
    final safetyScore = _getSafetyScore(response);
    
    return [
      // Free weight experience and comfort
      FeatureContribution('free_weight_experience', comfortLevel),
      FeatureContribution('free_weight_comfort', comfortLevel),
      
      // Safety and technique readiness
      FeatureContribution('free_weight_safety_score', safetyScore),
      FeatureContribution('requires_form_instruction', comfortLevel < 0.6 ? 1.0 : 0.0),
      FeatureContribution('supervision_needed', _calculateSupervisionNeed(comfortLevel)),
      
      // Exercise selection capabilities
      FeatureContribution('basic_free_weight_ready', comfortLevel > 0.2 ? 1.0 : 0.0),
      FeatureContribution('compound_movement_ready', comfortLevel > 0.4 ? 1.0 : 0.0),
      FeatureContribution('advanced_free_weight_ready', comfortLevel > 0.7 ? 1.0 : 0.0),
      
      // Program complexity readiness
      FeatureContribution('strength_program_complexity', _calculateComplexityLevel(comfortLevel)),
      FeatureContribution('progressive_overload_ready', comfortLevel > 0.3 ? 1.0 : 0.0),
      
      // Equipment preferences and limitations
      FeatureContribution('prefers_machines', comfortLevel < 0.4 ? 1.0 : 0.0),
      FeatureContribution('free_weight_preference', comfortLevel > 0.6 ? 1.0 : 0.0),
      
      // Training independence
      FeatureContribution('independent_training_capable', comfortLevel > 0.8 ? 1.0 : 0.0),
      FeatureContribution('coaching_dependency_strength', 1.0 - comfortLevel),
      
      // Strength training features
      FeatureContribution('strength_training_experience', comfortLevel * 0.8),
      FeatureContribution('barbell_movement_ready', comfortLevel > 0.5 ? 1.0 : 0.0),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['never_used', 'tried_few', 'somewhat', 'comfortable', 'very_experienced'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'never_used'; // Conservative default for safety
  
  //MARK: PRIVATE HELPERS
  
  /// Convert response to comfort level score (0.0 to 1.0)
  double _getComfortLevel(String response) {
    switch (response) {
      case 'never_used':
        return 0.0;
      case 'tried_few':
        return 0.2;
      case 'somewhat':
        return 0.5;
      case 'comfortable':
        return 0.8;
      case 'very_experienced':
        return 1.0;
      default:
        return 0.0;
    }
  }
  
  /// Calculate safety score based on experience
  double _getSafetyScore(String response) {
    switch (response) {
      case 'never_used':
        return 0.3; // Low safety due to inexperience
      case 'tried_few':
        return 0.4; // Slightly better but still risky
      case 'somewhat':
        return 0.6; // Moderate safety with basic knowledge
      case 'comfortable':
        return 0.85; // Good safety with experience
      case 'very_experienced':
        return 0.95; // High safety with extensive experience
      default:
        return 0.3;
    }
  }
  
  /// Calculate need for supervision during free weight exercises
  double _calculateSupervisionNeed(double comfortLevel) {
    if (comfortLevel <= 0.2) return 1.0;  // Always need supervision
    if (comfortLevel <= 0.5) return 0.8;  // Need supervision for most exercises
    if (comfortLevel <= 0.8) return 0.4;  // Occasional supervision helpful
    return 0.1; // Minimal supervision needed
  }
  
  /// Calculate appropriate program complexity for strength training
  double _calculateComplexityLevel(double comfortLevel) {
    if (comfortLevel >= 0.8) return 1.0;   // Can handle advanced programs
    if (comfortLevel >= 0.5) return 0.7;   // Intermediate complexity
    if (comfortLevel >= 0.2) return 0.4;   // Basic programs only
    return 0.1; // Very basic introduction needed
  }
}