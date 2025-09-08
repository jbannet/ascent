import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Q6: Have you followed a structured exercise program before?
/// 
/// This question assesses training experience and program adherence capability.
/// It contributes to program complexity readiness and coaching needs features.
class Q6StructuredProgramQuestion extends OnboardingQuestion {
  static const String questionId = 'Q6';
  static final Q6StructuredProgramQuestion instance = Q6StructuredProgramQuestion._();
  Q6StructuredProgramQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q6StructuredProgramQuestion.questionId;
  
  @override
  String get questionText => 'Have you followed a structured exercise program before?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Think about formal workout plans, training programs, or fitness challenges';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.never, label: 'Never'),
    QuestionOption(value: AnswerConstants.once, label: 'Once, didn\'t complete it'),
    QuestionOption(value: AnswerConstants.completedOne, label: 'Completed 1 program'),
    QuestionOption(value: AnswerConstants.completedFew, label: 'Completed 2-3 programs'),
    QuestionOption(value: AnswerConstants.experienced, label: 'Many programs, very experienced'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = [AnswerConstants.never, AnswerConstants.once, AnswerConstants.completedOne, AnswerConstants.completedFew, AnswerConstants.experienced];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.never; // Conservative default
  
  //MARK: TYPED ACCESSOR
  
  /// Get structured program experience as String from answers
  String? getStructuredProgramExperience(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }
}