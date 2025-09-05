import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// User name question for personalization and user identification.
/// 
/// This question collects the user's name for personalized experiences
/// and user account setup.
class UserNameQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'user_name';
  
  @override
  String get questionText => 'What\'s your name?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.textInput;
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minLength': 2,
    'maxLength': 50,
    'placeholder': 'Enter your full name',
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final name = answer.toString().trim();
    final nameLength = name.length;
    final hasMultipleWords = name.split(' ').length > 1;
    
    return [
      // Name characteristics (minimal ML impact, mostly for personalization)
      FeatureContribution('has_full_name', hasMultipleWords ? 1.0 : 0.0),
      FeatureContribution('name_length_factor', (nameLength / 50.0).clamp(0.0, 1.0)),
      
      // User engagement indicators
      FeatureContribution('provided_complete_name', hasMultipleWords ? 1.0 : 0.0),
      FeatureContribution('profile_completeness', 0.1), // Small contribution to profile completion
      
      // Personalization readiness
      FeatureContribution('personalization_ready', name.isNotEmpty ? 1.0 : 0.0),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! String) return false;
    final name = answer.trim();
    return name.length >= 2 && name.length <= 50;
  }
  
  @override
  dynamic getDefaultAnswer() => null; // No default for names
}