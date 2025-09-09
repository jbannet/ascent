import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/number_input_view.dart';
import '../onboarding_question.dart';

/// Q4: How far can you run/walk in 12 minutes? (Cooper Test)
/// 
/// This question assesses cardiovascular fitness using the standardized Cooper 12-minute test.
/// It contributes to cardio fitness, VO2 max estimation, and training intensity features.
class Q4TwelveMinuteRunQuestion extends OnboardingQuestion {
  static const String questionId = 'Q4';
  static final Q4TwelveMinuteRunQuestion instance = Q4TwelveMinuteRunQuestion._();
  Q4TwelveMinuteRunQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q4TwelveMinuteRunQuestion.questionId;
  
  @override
  String get questionText => 'Approximately how far can you run/walk in 12 minutes?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'Enter distance in miles (it\'s alright to answer 0 if you have trouble walking distances)';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0.0,      // Allow 0 for those who can't walk distances
    'maxValue': 3.0,      // ~10000 meters = 6.2 miles
    'allowDecimals': true, // Need decimals for miles
    'unit': 'miles',
    'placeholder': '',  // Don't shame people with a default
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final distance = answer.toDouble();
    return distance >= 0.0 && distance <= 3.0; // Allow 0 for mobility issues
  }
  
  @override
  dynamic getDefaultAnswer() => null; // ~2000 meters in miles
  
  //MARK: TYPED ACCESSOR
  
  /// Get twelve minute run distance as double from answers (in miles)
  double? getTwelveMinuteRunDistance(Map<String, dynamic> answers) {
    final distance = answers[questionId];
    if (distance == null) return null;
    return distance is double ? distance : double.tryParse(distance.toString());
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