import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Q3: Do you get out of breath walking up 2 flights of stairs?
/// 
/// This question assesses cardiovascular fitness and functional capacity.
/// It contributes to cardio fitness and exercise intensity features.
class Q3StairsQuestion extends OnboardingQuestion {
  static const String questionId = 'Q3';
  static final Q3StairsQuestion instance = Q3StairsQuestion._();
  Q3StairsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q3StairsQuestion.questionId;
  
  @override
  String get questionText => 'Do you get out of breath walking up 2 flights of stairs?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Think about your typical response';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.notAtAll, label: 'Not at all'),
    QuestionOption(value: AnswerConstants.slightly, label: 'Slightly out of breath'),
    QuestionOption(value: AnswerConstants.moderately, label: 'Moderately out of breath'),
    QuestionOption(value: AnswerConstants.very, label: 'Very out of breath'),
    QuestionOption(value: AnswerConstants.avoid, label: 'I avoid stairs when possible'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = [AnswerConstants.notAtAll, AnswerConstants.slightly, AnswerConstants.moderately, AnswerConstants.very, AnswerConstants.avoid];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.moderately; // Conservative middle ground
  
  //MARK: TYPED ACCESSOR
  
  /// Get stairs response as String from answers
  String? getStairsResponse(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }
  
}