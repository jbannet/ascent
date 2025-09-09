import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/wheel_picker_view.dart';
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
  EnumQuestionType get questionType => EnumQuestionType.wheelPicker;
  
  @override
  String? get subtitle => 'Used for weight management goals and exercise recommendations (optional)';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': false,
    'minValue': 80,
    'maxValue': 500,
    'step': 1,
    'unit': 'lbs',
    'wheelStyle': 'weight',
  };
  
  //MARK: VALIDATION
  
  /// Validation is handled by the wheel picker UI
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is num) _weightValue = json;
    else if (json is String) _weightValue = num.tryParse(json);
    else _weightValue = null;
  }
  
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

  //MARK: TYPED ANSWER INTERFACE
  
  //MARK: ANSWER STORAGE
  
  num? _weightValue;
  
  @override
  String? get answer => _weightValue?.toString();
  
  /// Set the weight with a typed number (no validation needed)
  void setWeightValue(num? value) => _weightValue = value;
  
  /// Get the weight as a typed number
  num? get weightValue => _weightValue;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return WheelPickerView(
      questionId: id,
      answers: {id: _weightValue},
      onAnswerChanged: (questionId, value) {
        setWeightValue(value as num?);
        onAnswerChanged();
      },
      config: config,
    );
  }
}