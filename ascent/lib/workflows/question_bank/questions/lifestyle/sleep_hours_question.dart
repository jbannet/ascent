import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/slider_view.dart';
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
  
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final hours = answer.toDouble();
    return hours >= 3 && hours <= 12;
  }
  
  @override
  dynamic getDefaultAnswer() => 7.0;
  
  
  //MARK: TYPED ACCESSOR
  
  /// Get sleep hours as double from answers
  double? getSleepHours(Map<String, dynamic> answers) {
    final hours = answers[questionId];
    if (hours == null) return null;
    return hours is double ? hours : double.tryParse(hours.toString());
  }

  @override
  Widget buildAnswerWidget(
    Map<String, dynamic> currentAnswers,
    Function(String, dynamic) onAnswerChanged,
  ) {
    return Column(
      children: [
        SliderView(
          questionId: id,
          answers: currentAnswers,
          onAnswerChanged: onAnswerChanged,
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