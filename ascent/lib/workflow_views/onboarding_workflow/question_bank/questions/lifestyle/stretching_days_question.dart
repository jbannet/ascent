import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../widgets/onboarding/question_input/single_column_selector_widget.dart';
import '../onboarding_question.dart';

/// Current stretching frequency question that captures how many days per week
/// the user currently stretches.
///
/// This establishes a baseline for their current flexibility work and helps
/// personalize the fitness plan based on their existing stretching habits.
class StretchingDaysQuestion extends OnboardingQuestion {
  static const String questionId = 'stretching_days';
  static final StretchingDaysQuestion instance = StretchingDaysQuestion._();
  StretchingDaysQuestion._();

  //MARK: UI PRESENTATION DATA

  @override
  String get id => StretchingDaysQuestion.questionId;

  @override
  String get questionText => 'How many days a week do you stretch?';

  @override
  String get section => 'lifestyle';

  @override
  EnumQuestionType get questionType => EnumQuestionType.custom;

  @override
  String? get subtitle => 'Include yoga, dedicated stretching sessions, or flexibility work';

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
      _stretchingDays = json;
    } else if (json is num) {
      _stretchingDays = json.toInt();
    } else if (json is String) {
      _stretchingDays = int.tryParse(json);
    } else {
      _stretchingDays = null;
    }
  }

  //MARK: TYPED ACCESSOR

  /// Get current stretching days per week from answers
  int getStretchingDays(Map<String, dynamic> answers) {
    final days = answers[questionId];
    if (days == null) return 0;
    return days is int ? days : int.tryParse(days.toString()) ?? 0;
  }

  //MARK: ANSWER STORAGE

  int? _stretchingDays;

  @override
  String? get answer => _stretchingDays?.toString();

  /// Set the stretching days with a typed int
  void setStretchingDays(int? value) => _stretchingDays = value;

  /// Get the stretching days as a typed int
  int? get stretchingDays => _stretchingDays;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return SingleColumnSelectorWidget(
      config: config,
      onChanged: (value) {
        setStretchingDays(value);
        onAnswerChanged();
      },
      initialValue: _stretchingDays,
    );
  }
}