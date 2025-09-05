import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Sleep hours assessment question.
class SleepHoursQuestion extends OnboardingQuestion {
  @override
  String get id => 'sleep_hours';
  
  @override
  String get questionText => 'How many hours of sleep do you average per night?';
  
  @override
  String get section => 'lifestyle';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.slider;
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 3.0,
    'maxValue': 12.0,
    'step': 0.5,
    'showValue': true,
    'unit': 'hours'
  };
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final hours = (answer as num).toDouble();
    final sleepQuality = _getSleepQuality(hours);
    
    return [
      FeatureContribution('sleep_hours', hours / 12.0),
      FeatureContribution('sleep_quality_score', sleepQuality),
      FeatureContribution('adequate_recovery', hours >= 7 ? 1.0 : 0.0),
      FeatureContribution('sleep_deficit_risk', hours < 6 ? 1.0 : 0.0),
      FeatureContribution('recovery_capacity', sleepQuality),
    ];
  }
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final hours = answer.toDouble();
    return hours >= 3 && hours <= 12;
  }
  
  @override
  dynamic getDefaultAnswer() => 7.0;
  
  double _getSleepQuality(double hours) {
    if (hours >= 7 && hours <= 9) return 1.0; // Optimal
    if (hours >= 6 && hours <= 10) return 0.8; // Good
    if (hours >= 5 && hours <= 11) return 0.6; // Acceptable
    return 0.3; // Poor
  }
}