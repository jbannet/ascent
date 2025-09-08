import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Q1: Do you have any current injuries or physical limitations?
/// 
/// This question assesses safety constraints that affect exercise selection.
/// It contributes to injury risk and exercise modification features.
class Q1InjuriesQuestion extends OnboardingQuestion {
  static const String questionId = 'Q1';
  static final Q1InjuriesQuestion instance = Q1InjuriesQuestion._();
  Q1InjuriesQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q1InjuriesQuestion.questionId;
  
  @override
  String get questionText => 'Do you have any current injuries or physical limitations?';
  
  @override
  String get section => 'practical_constraints';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Select all that apply';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.none, label: 'None'),
    QuestionOption(value: AnswerConstants.back, label: 'Back problems'),
    QuestionOption(value: AnswerConstants.knee, label: 'Knee problems'),
    QuestionOption(value: AnswerConstants.shoulder, label: 'Shoulder problems'),
    QuestionOption(value: AnswerConstants.wristAnkle, label: 'Wrist/ankle problems'),
    QuestionOption(value: AnswerConstants.other, label: 'Other limitations'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is List) {
      return answer.isNotEmpty && answer.every((item) => item is String);
    }
    return answer is String && answer.isNotEmpty;
  }
  
  @override
  dynamic getDefaultAnswer() => [AnswerConstants.none]; // Default to no injuries
  
  //MARK: TYPED ACCESSOR
  
  /// Get injury list as List<String> from answers
  List<String> getInjuries(Map<String, dynamic> answers) {
    final injuries = answers[questionId];
    if (injuries == null) return [AnswerConstants.none];
    if (injuries is List) return injuries.cast<String>();
    return [injuries.toString()];
  }
}