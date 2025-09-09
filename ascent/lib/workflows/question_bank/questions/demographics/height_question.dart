import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/widgets/onboarding/question_input/height_selector_widget.dart';
import '../onboarding_question.dart';

/// Height demographic question for BMI calculation and weight management goals.
/// 
/// Uses a dual slider interface allowing users to select feet and inches
/// separately for better user experience. Height data enables calculation of
/// Body Mass Index (BMI) when combined with weight, supporting weight
/// management objectives and exercise recommendations.
class HeightQuestion extends OnboardingQuestion {
  static const String questionId = 'height';
  static final HeightQuestion instance = HeightQuestion._();
  HeightQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => HeightQuestion.questionId;
  
  @override
  String get questionText => 'What is your height?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.heightSelector;
  
  @override
  String? get subtitle => 'Used for weight management goals and exercise recommendations (optional)';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': false,
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer == null) return true; // Optional field
    if (answer is! Map<String, dynamic>) return false;
    
    final feet = answer['feet'];
    final inches = answer['inches'];
    
    if (feet is! int || inches is! int) return false;
    if (feet < 3 || feet > 8) return false;
    if (inches < 0 || inches > 11) return false;
    
    return true;
  }
  
  @override
  dynamic getDefaultAnswer() => null; // Optional field
  
  //MARK: TYPED ACCESSORS
  
  /// Get height data as Map from answers
  Map<String, int>? getHeightData(Map<String, dynamic> answers) {
    final heightData = answers[questionId];
    if (heightData == null || heightData is! Map<String, dynamic>) return null;
    
    final feet = heightData['feet'];
    final inches = heightData['inches'];
    
    if (feet is! int || inches is! int) return null;
    
    return {'feet': feet, 'inches': inches};
  }
  
  /// Get height in total inches from answers
  double? getHeightInches(Map<String, dynamic> answers) {
    final heightData = getHeightData(answers);
    if (heightData == null) return null;
    
    return (heightData['feet']! * 12 + heightData['inches']!).toDouble();
  }
  
  /// Get height in centimeters from answers
  double? getHeightCentimeters(Map<String, dynamic> answers) {
    final heightInches = getHeightInches(answers);
    if (heightInches == null) return null;
    return heightInches * 2.54; // Convert inches to cm
  }
  
  /// Get height in meters from answers
  double? getHeightMeters(Map<String, dynamic> answers) {
    final heightCm = getHeightCentimeters(answers);
    if (heightCm == null) return null;
    return heightCm / 100.0; // Convert cm to meters
  }
  
  /// Get formatted height string (e.g., "5'6\"")
  String? getHeightFormatted(Map<String, dynamic> answers) {
    final heightData = getHeightData(answers);
    if (heightData == null) return null;
    
    return "${heightData['feet']}'${heightData['inches']}\"";
  }

  @override
  Widget buildAnswerWidget(
    Map<String, dynamic> currentAnswers,
    Function(String, dynamic) onAnswerChanged,
  ) {
    final currentAnswer = currentAnswers[id];
    
    return HeightSelectorWidget(
      config: config,
      onChanged: (value) => onAnswerChanged(id, value),
      initialValue: currentAnswer is Map<String, dynamic>
          ? currentAnswer
          : null,
    );
  }
}