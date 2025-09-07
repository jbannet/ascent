import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';

/// Gender demographic question for fitness assessment normalization.
/// 
/// Gender is used for fitness norm calculations, body composition estimates,
/// and gender-specific training considerations.
class GenderQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'gender';
  
  @override
  String get questionText => 'What is your gender?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'This helps us provide personalized fitness recommendations';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'male', label: 'Male'),
    QuestionOption(value: 'female', label: 'Female'),
    QuestionOption(value: 'non_binary', label: 'Non-binary'),
    QuestionOption(value: 'prefer_not_to_say', label: 'Prefer not to say'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['male', 'female', 'non_binary', 'prefer_not_to_say'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'prefer_not_to_say'; // Respectful default
}