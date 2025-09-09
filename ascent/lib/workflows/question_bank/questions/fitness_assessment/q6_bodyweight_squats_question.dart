import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/number_input_view.dart';
import '../onboarding_question.dart';

/// Q6: How many bodyweight squats can you do continuously (with good form)?
/// 
/// This question assesses lower body strength and muscular endurance.
/// It's a critical functional movement that predicts:
/// - Ability to rise from chairs/floor
/// - Fall prevention capability
/// - Lower body power
/// - Daily activity independence
/// 
/// Good form criteria:
/// - Thighs parallel to ground at bottom
/// - Heels stay on floor
/// - Knees track over toes
/// - Back stays straight
/// - Full hip and knee extension at top
class Q6BodyweightSquatsQuestion extends OnboardingQuestion {
  static const String questionId = 'Q6';
  static final Q6BodyweightSquatsQuestion instance = Q6BodyweightSquatsQuestion._();
  Q6BodyweightSquatsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q6BodyweightSquatsQuestion.questionId;
  
  @override
  String get questionText => 'How many bodyweight squats can you do continuously (with good form)?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'Go down until thighs are parallel to ground, then back up';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0.0,
    'maxValue': 200.0,
    'allowDecimals': false,
    'unit': 'reps',
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final count = answer.toInt();
    return count >= 0 && count <= 200; // Reasonable range
  }
  
  @override
  dynamic getDefaultAnswer() => 0; // Default to 0 squats if not answered
  
  //MARK: TYPED ACCESSOR
  
  /// Get squats count as int from answers
  int? getSquatsCount(Map<String, dynamic> answers) {
    final count = answers[questionId];
    if (count == null) return null;
    return count is int ? count : int.tryParse(count.toString());
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