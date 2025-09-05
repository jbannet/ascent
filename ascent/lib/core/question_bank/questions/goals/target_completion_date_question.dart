import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../base/onboarding_question.dart';
import '../../base/feature_contribution.dart';

/// Target completion date question.
class TargetCompletionDateQuestion extends OnboardingQuestion {
  @override
  String get id => 'target_completion_date';
  
  @override
  String get questionText => 'When would you like to achieve your main fitness goal?';
  
  @override
  String get section => 'goals';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.datePicker;
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minDate': '2024-09-01',
    'maxDate': '2025-12-31',
    'initialDatePickerMode': 'day'
  };
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    // For date picker, we'd need to calculate timeline
    // For now, basic features
    return [
      FeatureContribution('has_target_date', 1.0),
      FeatureContribution('goal_oriented', 1.0),
      FeatureContribution('timeline_motivated', 1.0),
    ];
  }
  
  @override
  bool isValidAnswer(dynamic answer) => answer != null;
  
  @override
  dynamic getDefaultAnswer() => null;
}