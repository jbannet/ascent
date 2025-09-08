import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Gender demographic question for fitness assessment normalization.
/// 
/// Gender is used for fitness norm calculations, body composition estimates,
/// and gender-specific training considerations.
class GenderQuestion extends OnboardingQuestion {
  static const String questionId = 'gender';
  static final GenderQuestion instance = GenderQuestion._();
  GenderQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => GenderQuestion.questionId;
  
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
    QuestionOption(value: AnswerConstants.male, label: 'Male'),
    QuestionOption(value: AnswerConstants.female, label: 'Female'),
    QuestionOption(value: AnswerConstants.nonBinary, label: 'Non-binary'),
    QuestionOption(value: AnswerConstants.preferNotToSay, label: 'Prefer not to say'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = [AnswerConstants.male, AnswerConstants.female, AnswerConstants.nonBinary, AnswerConstants.preferNotToSay];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.preferNotToSay; // Respectful default
  
  //MARK: TYPED ACCESSOR
  
  /// Get gender as string from answers
  String? getGender(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }
}