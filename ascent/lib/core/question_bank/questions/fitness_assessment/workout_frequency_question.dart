import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Workout frequency question (duplicate of Q8 but from JSON).
class WorkoutFrequencyQuestion extends OnboardingQuestion {
  @override
  String get id => 'workout_frequency';
  
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
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final days = (answer as num).toInt();
    return [
      FeatureContribution('weekly_frequency', days / 7.0),
      FeatureContribution('high_frequency_capable', days >= 5 ? 1.0 : 0.0),
      FeatureContribution('moderate_frequency', days >= 3 && days <= 4 ? 1.0 : 0.0),
      FeatureContribution('low_frequency', days <= 2 ? 1.0 : 0.0),
    ];
  }
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final days = answer.toInt();
    return days >= 1 && days <= 7;
  }
  
  @override
  dynamic getDefaultAnswer() => 3;
}