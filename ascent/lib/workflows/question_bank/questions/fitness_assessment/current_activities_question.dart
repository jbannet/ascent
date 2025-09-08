import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Current activities assessment question.
class CurrentActivitiesQuestion extends OnboardingQuestion {
  static const String questionId = 'current_activities';
  static final CurrentActivitiesQuestion instance = CurrentActivitiesQuestion._();
  CurrentActivitiesQuestion._();
  @override
  String get id => CurrentActivitiesQuestion.questionId;
  
  @override
  String get questionText => 'What types of exercise do you currently do?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Select all that apply';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.none, label: 'None - I don\'t exercise regularly'),
    QuestionOption(value: AnswerConstants.walkingHiking, label: 'Walking/hiking'),
    QuestionOption(value: AnswerConstants.runningJogging, label: 'Running/jogging'),
    QuestionOption(value: AnswerConstants.weightTraining, label: 'Weight training/bodybuilding'),
    QuestionOption(value: AnswerConstants.yoga, label: 'Yoga classes'),
    QuestionOption(value: AnswerConstants.swimming, label: 'Swimming'),
    QuestionOption(value: AnswerConstants.cycling, label: 'Cycling/spinning'),
    QuestionOption(value: AnswerConstants.teamSports, label: 'Team sports'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
    'minSelections': 1,
    'maxSelections': 5
  };
  
  
  @override
  bool isValidAnswer(dynamic answer) => true;
  
  @override
  dynamic getDefaultAnswer() => [AnswerConstants.none];
  
  
  //MARK: TYPED ACCESSOR
  
  /// Get current activities as List<String> from answers
  List<String> getCurrentActivities(Map<String, dynamic> answers) {
    final activities = answers[questionId];
    if (activities == null) return [AnswerConstants.none];
    if (activities is List) return activities.cast<String>();
    return [activities.toString()];
  }
}