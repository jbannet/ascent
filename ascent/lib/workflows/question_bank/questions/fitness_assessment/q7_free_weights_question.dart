import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Q7: How comfortable are you with free weights (dumbbells, barbells)?
/// 
/// This question assesses strength training experience and equipment comfort.
/// It contributes to exercise selection, safety, and program complexity features.
class Q7FreeWeightsQuestion extends OnboardingQuestion {
  static const String questionId = 'Q7';
  static final Q7FreeWeightsQuestion instance = Q7FreeWeightsQuestion._();
  Q7FreeWeightsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q7FreeWeightsQuestion.questionId;
  
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
    QuestionOption(value: AnswerConstants.neverUsed, label: 'Never used them'),
    QuestionOption(value: AnswerConstants.triedFew, label: 'Tried a few times, felt unsure'),
    QuestionOption(value: AnswerConstants.somewhat, label: 'Somewhat comfortable with basic movements'),
    QuestionOption(value: AnswerConstants.comfortable, label: 'Comfortable with most exercises'),
    QuestionOption(value: AnswerConstants.veryExperienced, label: 'Very experienced, can train independently'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = [AnswerConstants.neverUsed, AnswerConstants.triedFew, AnswerConstants.somewhat, AnswerConstants.comfortable, AnswerConstants.veryExperienced];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.neverUsed; // Conservative default for safety
  
  //MARK: TYPED ACCESSOR
  
  /// Get free weight comfort level as String from answers
  String? getFreeWeightComfort(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }
  
}