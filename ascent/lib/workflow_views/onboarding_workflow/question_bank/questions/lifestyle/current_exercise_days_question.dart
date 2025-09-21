import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../widgets/onboarding/question_input/single_column_selector_widget.dart';
import '../onboarding_question.dart';

/// Current exercise frequency question that captures how many days per week
/// the user currently exercises.
///
/// This establishes a baseline for their current activity level and helps
/// personalize the fitness plan based on their existing habits.
class CurrentExerciseDaysQuestion extends OnboardingQuestion {
  static const String questionId = 'current_exercise_days';
  static final CurrentExerciseDaysQuestion instance = CurrentExerciseDaysQuestion._();
  CurrentExerciseDaysQuestion._();

  //MARK: UI PRESENTATION DATA

  @override
  String get id => CurrentExerciseDaysQuestion.questionId;

  @override
  String get questionText => 'How many days a week do you exercise?';

  @override
  String get section => 'lifestyle';

  @override
  EnumQuestionType get questionType => EnumQuestionType.custom;

  @override
  String? get subtitle => 'Include any form of physical activity or exercise';

  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'maxValue': 7,
    'minValue': 0,
    'label': 'Days per week',
  };

  //MARK: VALIDATION

  bool isValidAnswer(dynamic answer) {
    if (answer is! int) return false;
    return answer >= 0 && answer <= 7;
  }

  dynamic getDefaultAnswer() => 0;

  @override
  void fromJsonValue(dynamic json) {
    if (json is int) {
      _exerciseDays = json;
    } else if (json is num) {
      _exerciseDays = json.toInt();
    } else if (json is String) {
      _exerciseDays = int.tryParse(json);
    } else {
      _exerciseDays = null;
    }
  }

  //MARK: TYPED ACCESSOR

  /// Get current exercise days per week from answers
  int getCurrentExerciseDays(Map<String, dynamic> answers) {
    final days = answers[questionId];
    if (days == null) return 0;
    return days is int ? days : int.tryParse(days.toString()) ?? 0;
  }

  //MARK: ANSWER STORAGE

  int? _exerciseDays;

  @override
  String? get answer => _exerciseDays?.toString();

  /// Set the exercise days with a typed int
  void setExerciseDays(int? value) => _exerciseDays = value;

  /// Get the exercise days as a typed int
  int? get exerciseDays => _exerciseDays;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return SingleColumnSelectorWidget(
      config: config,
      onChanged: (value) {
        setExerciseDays(value);
        onAnswerChanged();
      },
      initialValue: _exerciseDays,
    );
  }
}