import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Workout duration question (similar to Q9 but from JSON).
class WorkoutDurationQuestion extends OnboardingQuestion {
  static const String questionId = 'workout_duration';
  static final WorkoutDurationQuestion instance = WorkoutDurationQuestion._();
  WorkoutDurationQuestion._();
  @override
  String get id => WorkoutDurationQuestion.questionId;
  
  @override
  String get questionText => 'How much time per workout?';
  
  @override
  String get section => 'schedule';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.duration15_30, label: '15-30 minutes', description: 'Quick, focused sessions'),
    QuestionOption(value: AnswerConstants.duration30_45, label: '30-45 minutes', description: 'Standard workout length'),
    QuestionOption(value: AnswerConstants.duration45_60, label: '45-60 minutes', description: 'Longer, comprehensive sessions'),
    QuestionOption(value: AnswerConstants.duration60Plus, label: '60+ minutes', description: 'Extended training sessions'),
  ];
  
  @override
  Map<String, dynamic> get config => {'isRequired': true};
  
  
  @override
  bool isValidAnswer(dynamic answer) {
    return [AnswerConstants.duration15_30, AnswerConstants.duration30_45, AnswerConstants.duration45_60, AnswerConstants.duration60Plus].contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.duration30_45;
  
  //MARK: TYPED ACCESSOR
  
  /// Get workout duration as String from answers
  String? getWorkoutDuration(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }
}