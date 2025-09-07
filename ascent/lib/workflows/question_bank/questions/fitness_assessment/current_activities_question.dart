import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../fitness_profile_model/feature_contribution.dart';

/// Current activities assessment question.
class CurrentActivitiesQuestion extends OnboardingQuestion {
  @override
  String get id => 'current_activities';
  
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
    QuestionOption(value: 'none', label: 'None - I don\'t exercise regularly'),
    QuestionOption(value: 'walking_hiking', label: 'Walking/hiking'),
    QuestionOption(value: 'running_jogging', label: 'Running/jogging'),
    QuestionOption(value: 'weight_training', label: 'Weight training/bodybuilding'),
    QuestionOption(value: 'yoga', label: 'Yoga classes'),
    QuestionOption(value: 'swimming', label: 'Swimming'),
    QuestionOption(value: 'cycling', label: 'Cycling/spinning'),
    QuestionOption(value: 'team_sports', label: 'Team sports'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
    'minSelections': 1,
    'maxSelections': 5
  };
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final selections = answer is List ? answer.cast<String>() : [answer.toString()];
    final isActive = !selections.contains('none');
    
    return [
      FeatureContribution('currently_active', isActive ? 1.0 : 0.0),
      FeatureContribution('cardio_experience', _hasCardio(selections) ? 1.0 : 0.0),
      FeatureContribution('strength_experience', selections.contains('weight_training') ? 1.0 : 0.0),
      FeatureContribution('flexibility_experience', selections.contains('yoga') ? 1.0 : 0.0),
      FeatureContribution('activity_variety', selections.length / 8.0),
    ];
  }
  
  @override
  bool isValidAnswer(dynamic answer) => true;
  
  @override
  dynamic getDefaultAnswer() => ['none'];
  
  bool _hasCardio(List<String> selections) {
    return ['walking_hiking', 'running_jogging', 'swimming', 'cycling'].any((activity) => selections.contains(activity));
  }
}