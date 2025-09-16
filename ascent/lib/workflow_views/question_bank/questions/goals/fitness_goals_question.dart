import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../views/question_types/multiple_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Fitness goals question for understanding user's primary objectives.
/// 
/// This question identifies the user's main fitness goals to tailor
/// program recommendations and exercise selection.
class FitnessGoalsQuestion extends OnboardingQuestion {
  static const String questionId = 'fitness_goals';
  static final FitnessGoalsQuestion instance = FitnessGoalsQuestion._();
  FitnessGoalsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => FitnessGoalsQuestion.questionId;
  
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
      value: AnswerConstants.loseWeight,
      label: 'Lose weight',
      description: 'Reduce overall body weight',
    ),
    QuestionOption(
      value: AnswerConstants.buildMuscle,
      label: 'Build muscle',
      description: 'Increase muscle mass and strength',
    ),
    QuestionOption(
      value: AnswerConstants.improveEndurance,
      label: 'Improve endurance',
      description: 'Build cardiovascular fitness',
    ),
    QuestionOption(
      value: AnswerConstants.increaseFlexibility,
      label: 'Increase flexibility',
      description: 'Improve range of motion and mobility',
    ),
    QuestionOption(
      value: AnswerConstants.betterHealth,
      label: 'Better overall health',
      description: 'General wellness and disease prevention',
    ),
    QuestionOption(
      value: AnswerConstants.liveLonger,
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
  
  bool isValidAnswer(dynamic answer) {
    if (answer is List) {
      final selections = answer.cast<String>();
      return selections.isNotEmpty && 
             selections.length <= 3 && 
             selections.every((item) => _isValidOption(item));
    }
    return _isValidOption(answer.toString());
  }
  
  dynamic getDefaultAnswer() => [AnswerConstants.betterHealth]; // Universal goal
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is List) {
      _fitnessGoals = json.map((e) => e.toString()).toList();
    } else if (json is String) {
      _fitnessGoals = json.split(',');
    } else {
      _fitnessGoals = null;
    }
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get fitness goals as List&lt;String&gt; from answers
  List<String> getFitnessGoals(Map<String, dynamic> answers) {
    final goals = answers[questionId];
    if (goals == null) return [AnswerConstants.betterHealth];
    if (goals is List) return goals.cast<String>();
    return [goals.toString()];
  }
  
  //MARK: PRIVATE HELPERS
  
  /// Check if selection is a valid option
  bool _isValidOption(String option) {
    final validOptions = [
      'lose_weight', 'build_muscle', 'improve_endurance',
      'increase_flexibility', 'better_health', 'live_longer'
    ];
    return validOptions.contains(option);
  }

  //MARK: ANSWER STORAGE
  
  List<String>? _fitnessGoals;
  
  @override
  String? get answer => 
    (_fitnessGoals == null || _fitnessGoals!.isEmpty) ? null : _fitnessGoals!.join(',');
  
  /// Set the fitness goals with a typed `List<String>`
  void setFitnessGoals(List<String>? value) => _fitnessGoals = value;
  
  /// Get the fitness goals as a typed `List<String>`
  List<String> get fitnessGoals => _fitnessGoals ?? [];

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return MultipleChoiceView(
      questionId: id,
      answers: {id: _fitnessGoals ?? []},
      onAnswerChanged: (questionId, value) {
        if (value is List<String>) {
          setFitnessGoals(value.isEmpty ? null : value);
        } else if (value is List) {
          var stringList = value.map((e) => e.toString()).toList();
          setFitnessGoals(stringList.isEmpty ? null : stringList);
        }
        onAnswerChanged();
      },
      options: options,
      config: config,
    );
  }
}