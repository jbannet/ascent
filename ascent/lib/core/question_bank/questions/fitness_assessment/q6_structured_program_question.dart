import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Q6: Have you followed a structured exercise program before?
/// 
/// This question assesses training experience and program adherence capability.
/// It contributes to program complexity readiness and coaching needs features.
class Q6StructuredProgramQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q6';
  
  @override
  String get questionText => 'Have you followed a structured exercise program before?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Think about any formal fitness programs you\'ve completed';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'never', label: 'Never'),
    QuestionOption(value: 'once', label: 'Once, didn\'t complete it'),
    QuestionOption(value: 'completed_one', label: 'Completed 1 program'),
    QuestionOption(value: 'completed_few', label: 'Completed 2-3 programs'),
    QuestionOption(value: 'experienced', label: 'Many programs, very experienced'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final response = answer.toString();
    final experienceLevel = _getExperienceLevel(response);
    final adherenceScore = _getAdherenceScore(response);
    
    return [
      // Program experience and readiness
      FeatureContribution('program_experience', experienceLevel),
      FeatureContribution('structured_training_ready', experienceLevel > 0.3 ? 1.0 : 0.0),
      
      // Adherence and completion likelihood
      FeatureContribution('program_adherence_likelihood', adherenceScore),
      FeatureContribution('completion_confidence', adherenceScore),
      
      // Complexity readiness
      FeatureContribution('complex_program_ready', _calculateComplexityReadiness(experienceLevel)),
      FeatureContribution('advanced_concepts_ready', experienceLevel > 0.6 ? 1.0 : 0.0),
      
      // Coaching and guidance needs
      FeatureContribution('requires_detailed_guidance', _calculateGuidanceNeed(experienceLevel)),
      FeatureContribution('coaching_dependency', 1.0 - experienceLevel), // Inverse relationship
      
      // Program design preferences
      FeatureContribution('prefers_simple_programs', experienceLevel < 0.4 ? 1.0 : 0.0),
      FeatureContribution('can_handle_periodization', experienceLevel > 0.5 ? 1.0 : 0.0),
      
      // Motivation and self-direction
      FeatureContribution('self_directed_capability', experienceLevel * 0.8),
      FeatureContribution('motivation_sustainability', adherenceScore * 0.9),
      
      // Training maturity
      FeatureContribution('training_maturity', experienceLevel),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['never', 'once', 'completed_one', 'completed_few', 'experienced'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'never'; // Conservative default
  
  //MARK: PRIVATE HELPERS
  
  /// Convert response to experience level score (0.0 to 1.0)
  double _getExperienceLevel(String response) {
    switch (response) {
      case 'never':
        return 0.0;
      case 'once':
        return 0.2;
      case 'completed_one':
        return 0.4;
      case 'completed_few':
        return 0.7;
      case 'experienced':
        return 1.0;
      default:
        return 0.0;
    }
  }
  
  /// Calculate program adherence/completion likelihood
  double _getAdherenceScore(String response) {
    switch (response) {
      case 'never':
        return 0.5; // Unknown, give benefit of doubt
      case 'once':
        return 0.3; // Started but didn't finish - lower adherence
      case 'completed_one':
        return 0.7; // Completed one - good sign
      case 'completed_few':
        return 0.9; // Multiple completions - excellent adherence
      case 'experienced':
        return 0.95; // Very experienced - highest adherence
      default:
        return 0.5;
    }
  }
  
  /// Calculate readiness for complex program structures
  double _calculateComplexityReadiness(double experienceLevel) {
    // Complex programs include periodization, multiple phases, advanced techniques
    if (experienceLevel >= 0.7) return 1.0;   // Ready for advanced complexity
    if (experienceLevel >= 0.4) return 0.7;   // Can handle moderate complexity
    if (experienceLevel >= 0.2) return 0.4;   // Simple structures only
    return 0.1; // Very basic structures needed
  }
  
  /// Calculate need for detailed guidance and hand-holding
  double _calculateGuidanceNeed(double experienceLevel) {
    // Higher experience = less guidance needed
    return 1.0 - experienceLevel;
  }
}