import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../views/question_views/question_types/slider_view.dart';
import '../onboarding_question.dart';

/// Sleep hours assessment question.
class SleepHoursQuestion extends OnboardingQuestion {
  static const String questionId = 'sleep_hours';
  static final SleepHoursQuestion instance = SleepHoursQuestion._();
  SleepHoursQuestion._();
  @override
  String get id => SleepHoursQuestion.questionId;
  
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
  
  
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final hours = answer.toDouble();
    return hours >= 3 && hours <= 12;
  }
  
  dynamic getDefaultAnswer() => 7.0;
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is double) {
      _sleepHours = json;
    } else if (json is num) {
      _sleepHours = json.toDouble();
    } else if (json is String) {
      _sleepHours = double.tryParse(json);
    } else {
      _sleepHours = null;
    }
  }
  
  
  //MARK: TYPED ACCESSOR
  
  /// Get sleep hours as double from answers
  double? getSleepHours(Map<String, dynamic> answers) {
    final hours = answers[questionId];
    if (hours == null) return null;
    return hours is double ? hours : double.tryParse(hours.toString());
  }

  //MARK: TYPED ANSWER INTERFACE
  
  //MARK: ANSWER STORAGE
  
  double? _sleepHours;
  
  @override
  String? get answer => _sleepHours?.toString();
  
  /// Set the sleep hours with a typed double
  void setSleepHours(double? value) => _sleepHours = value;
  
  /// Get the sleep hours as a typed double
  double? get sleepHours => _sleepHours;
  
  /// Get the sleep hours as answerDouble
  double? get answerDouble => _sleepHours;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return Column(
      children: [
        SliderView(
          questionId: id,
          answers: {id: _sleepHours},
          onAnswerChanged: (questionId, value) {
            setSleepHours(value);
            onAnswerChanged();
          },
          config: config,
        ),
        const SizedBox(height: 40),
        Image.asset(
          'assets/images/kettlebell_sleeping.png',
          height: 180,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}