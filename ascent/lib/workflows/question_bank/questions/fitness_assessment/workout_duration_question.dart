import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../fitness_profile_model/feature_contribution.dart';

/// Workout duration question (similar to Q9 but from JSON).
class WorkoutDurationQuestion extends OnboardingQuestion {
  @override
  String get id => 'workout_duration';
  
  @override
  String get questionText => 'How much time per workout?';
  
  @override
  String get section => 'schedule';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: '15_30', label: '15-30 minutes', description: 'Quick, focused sessions'),
    QuestionOption(value: '30_45', label: '30-45 minutes', description: 'Standard workout length'),
    QuestionOption(value: '45_60', label: '45-60 minutes', description: 'Longer, comprehensive sessions'),
    QuestionOption(value: '60_plus', label: '60+ minutes', description: 'Extended training sessions'),
  ];
  
  @override
  Map<String, dynamic> get config => {'isRequired': true};
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final duration = answer.toString();
    return [
      FeatureContribution('short_workouts', duration == '15_30' ? 1.0 : 0.0),
      FeatureContribution('standard_workouts', duration == '30_45' ? 1.0 : 0.0),
      FeatureContribution('long_workouts', ['45_60', '60_plus'].contains(duration) ? 1.0 : 0.0),
      FeatureContribution('time_efficiency_needed', duration == '15_30' ? 1.0 : 0.0),
    ];
  }
  
  @override
  bool isValidAnswer(dynamic answer) {
    return ['15_30', '30_45', '45_60', '60_plus'].contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => '30_45';
}