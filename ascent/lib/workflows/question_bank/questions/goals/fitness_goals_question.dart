import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';

/// Fitness goals question for understanding user's primary objectives.
/// 
/// This question identifies the user's main fitness goals to tailor
/// program recommendations and exercise selection.
class FitnessGoalsQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'fitness_goals';
  
  @override
  String get questionText => 'What are your primary fitness goals?';
  
  @override
  String get section => 'goals';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Choose up to 3 goals';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: 'lose_weight',
      label: 'Lose weight',
      description: 'Reduce overall body weight',
    ),
    QuestionOption(
      value: 'build_muscle',
      label: 'Build muscle',
      description: 'Increase muscle mass and strength',
    ),
    QuestionOption(
      value: 'improve_endurance',
      label: 'Improve endurance',
      description: 'Build cardiovascular fitness',
    ),
    QuestionOption(
      value: 'increase_flexibility',
      label: 'Increase flexibility',
      description: 'Improve range of motion and mobility',
    ),
    QuestionOption(
      value: 'better_health',
      label: 'Better overall health',
      description: 'General wellness and disease prevention',
    ),
    QuestionOption(
      value: 'live_longer',
      label: 'Live longer',
      description: 'Longevity and aging well',
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
    'minSelections': 1,
    'maxSelections': 3,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is List) {
      final selections = answer.cast<String>();
      return selections.length >= 1 && 
             selections.length <= 3 && 
             selections.every((item) => _isValidOption(item));
    }
    return _isValidOption(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => ['better_health']; // Universal goal
  
  //MARK: PRIVATE HELPERS
  
  /// Check if selection is a valid option
  bool _isValidOption(String option) {
    final validOptions = [
      'lose_weight', 'build_muscle', 'improve_endurance',
      'increase_flexibility', 'better_health', 'live_longer'
    ];
    return validOptions.contains(option);
  }
}