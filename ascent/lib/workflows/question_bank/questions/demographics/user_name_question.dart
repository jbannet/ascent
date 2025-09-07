import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';

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