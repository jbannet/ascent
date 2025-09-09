import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../views/question_types/multiple_choice_view.dart';
import '../onboarding_question.dart';
import '../demographics/age_question.dart';
import './q4a_fall_history_question.dart';
import '../../../../constants.dart';

/// Q4B: Do you experience any of the following?
/// 
/// This question assesses additional fall risk factors beyond fall history.
/// It appears for users who have fallen OR are 65+ years old.
/// Based on CDC STEADI fall risk assessment protocol.
class Q4BFallRiskFactorsQuestion extends OnboardingQuestion {
  static const String questionId = 'Q4B';
  static final Q4BFallRiskFactorsQuestion instance = Q4BFallRiskFactorsQuestion._();
  Q4BFallRiskFactorsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q4BFallRiskFactorsQuestion.questionId;
  
  @override
  String get questionText => 'Do you experience any of the following?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Select all that apply';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: AnswerConstants.fearFalling, 
      label: 'Fear of falling',
      description: 'Worry about losing balance or falling during daily activities'
    ),
    QuestionOption(
      value: AnswerConstants.mobilityAids, 
      label: 'Use mobility aids',
      description: 'Walker, cane, or other assistive devices'
    ),
    QuestionOption(
      value: AnswerConstants.balanceProblems, 
      label: 'Balance problems',
      description: 'Feeling unsteady, lightheaded, or having trouble with balance'
    ),
    QuestionOption(
      value: AnswerConstants.none, 
      label: 'None of the above'
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
  };
  
  //MARK: CONDITIONAL DISPLAY
  
  @override
  bool shouldShow(Map<String, dynamic> answers) {
    // Show if Q4A = 'yes' (has fallen) OR age >= 65
    final hasFallen = Q4AFallHistoryQuestion.instance.fallHistoryAnswer == AnswerConstants.yes;
    final age = AgeQuestion.instance.calculatedAge;
    
    if (hasFallen) return true;
    if (age != null && age >= 65) return true;
    
    return false;
  }
  
  //MARK: TYPED ANSWER INTERFACE
  
  /// Get the fall risk factors as a typed List<String>
  List<String> get riskFactors => (answer as List<String>?) ?? [];
  
  /// Set the fall risk factors with a typed List<String>
  set riskFactors(List<String> value) => answer = value;
  
  /// Check if specific risk factors are present
  bool get hasFearOfFalling => riskFactors.contains(AnswerConstants.fearFalling);
  bool get usesMobilityAids => riskFactors.contains(AnswerConstants.mobilityAids);
  bool get hasBalanceProblems => riskFactors.contains(AnswerConstants.balanceProblems);
  bool get hasNoRiskFactors => riskFactors.contains(AnswerConstants.none);
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer == null) return false;
    if (answer is List<String>) {
      // Check for valid selections
      final validValues = [AnswerConstants.fearFalling, AnswerConstants.mobilityAids, AnswerConstants.balanceProblems, AnswerConstants.none];
      return answer.every((item) => validValues.contains(item));
    }
    return false;
  }
  
  @override
  dynamic getDefaultAnswer() => [AnswerConstants.none];

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return MultipleChoiceView(
      questionId: id,
      answers: {id: riskFactors},
      onAnswerChanged: (questionId, value) {
        riskFactors = value as List<String>;
        onAnswerChanged();
      },
      options: options,
      config: config,
    );
  }
}
