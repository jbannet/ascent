import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/number_input_view.dart';
import '../onboarding_question.dart';

/// Weight demographic question for BMI calculation and weight management goals.
/// 
/// Weight data enables calculation of Body Mass Index (BMI) when combined with
/// height, supporting weight management objectives and exercise recommendations.
/// This question is optional to maintain the app's performance-based philosophy
/// while supporting users who specifically want weight management features.
class WeightQuestion extends OnboardingQuestion {
  static const String questionId = 'weight';
  static final WeightQuestion instance = WeightQuestion._();
  WeightQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => WeightQuestion.questionId;
  
  @override
  String get questionText => 'What is your weight?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'Used for weight management goals and exercise recommendations (optional)';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': false,
    'allowDecimal': true,
    'minValue': 80,
    'maxValue': 500,
    'unit': 'lbs',
    'placeholder': 'Enter weight in pounds',
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer == null) return true; // Optional field
    if (answer is! num) return false;
    return answer >= 80 && answer <= 500;
  }
  
  @override
  dynamic getDefaultAnswer() => null; // Optional field
  
  //MARK: TYPED ACCESSOR
  
  /// Get weight in pounds from answers
  double? getWeightPounds(Map<String, dynamic> answers) {
    final weight = answers[questionId];
    if (weight == null) return null;
    return (weight as num).toDouble();
  }
  
  /// Get weight in kilograms from answers
  double? getWeightKilograms(Map<String, dynamic> answers) {
    final weightPounds = getWeightPounds(answers);
    if (weightPounds == null) return null;
    return weightPounds * 0.453592; // Convert pounds to kg
  }

  @override
  Widget buildAnswerWidget(
    Map<String, dynamic> currentAnswers,
    Function(String, dynamic) onAnswerChanged,
  ) {
    return NumberInputView(
      questionId: id,
      answers: currentAnswers,
      onAnswerChanged: onAnswerChanged,
      config: config,
    );
  }
}