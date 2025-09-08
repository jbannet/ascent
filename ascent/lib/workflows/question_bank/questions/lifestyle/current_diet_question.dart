import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Current diet assessment question.
class CurrentDietQuestion extends OnboardingQuestion {
  static const String questionId = 'current_diet';
  static final CurrentDietQuestion instance = CurrentDietQuestion._();
  CurrentDietQuestion._();
  @override
  String get id => CurrentDietQuestion.questionId;
  
  @override
  String get questionText => 'How would you describe your current diet?';
  
  @override
  String get section => 'lifestyle';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.veryHealthy, label: 'Very healthy', description: 'Consistently eat nutritious, balanced meals'),
    QuestionOption(value: AnswerConstants.mostlyHealthy, label: 'Mostly healthy', description: 'Generally good choices with occasional treats'),
    QuestionOption(value: AnswerConstants.average, label: 'Average', description: 'Mix of healthy and less healthy foods'),
    QuestionOption(value: AnswerConstants.needsImprovement, label: 'Needs improvement', description: 'Know I should eat better but struggle'),
    QuestionOption(value: AnswerConstants.poor, label: 'Poor', description: 'Mostly processed or fast food'),
  ];
  
  @override
  Map<String, dynamic> get config => {'isRequired': true};
  
  
  @override
  bool isValidAnswer(dynamic answer) {
    return [AnswerConstants.veryHealthy, AnswerConstants.mostlyHealthy, AnswerConstants.average, AnswerConstants.needsImprovement, AnswerConstants.poor].contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.average;
  
  //MARK: TYPED ACCESSOR
  
  /// Get current diet as String from answers
  String? getCurrentDiet(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }
}