import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';

/// Workout frequency question (duplicate of Q8 but from JSON).
class WorkoutFrequencyQuestion extends OnboardingQuestion {
  static const String questionId = 'workout_frequency';
  static final WorkoutFrequencyQuestion instance = WorkoutFrequencyQuestion._();
  WorkoutFrequencyQuestion._();
  @override
  String get id => WorkoutFrequencyQuestion.questionId;
  
  @override
  String get questionText => 'How many days per week can you exercise?';
  
  @override
  String get section => 'schedule';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.slider;
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 1.0,
    'maxValue': 7.0,
    'step': 1.0,
    'showValue': true,
    'unit': 'days'
  };
  
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final days = answer.toInt();
    return days >= 1 && days <= 7;
  }
  
  @override
  dynamic getDefaultAnswer() => 3;
  
  //MARK: TYPED ACCESSOR
  
  /// Get workout frequency as int from answers (days per week)
  int? getWorkoutFrequency(Map<String, dynamic> answers) {
    final frequency = answers[questionId];
    if (frequency == null) return null;
    return frequency is int ? frequency : int.tryParse(frequency.toString());
  }
}