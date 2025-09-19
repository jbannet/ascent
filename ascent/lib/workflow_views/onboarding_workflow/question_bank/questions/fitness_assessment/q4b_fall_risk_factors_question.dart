import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../models/questions/question_option.dart';
import '../../../views/question_views/question_types/multiple_choice_view.dart';
import '../onboarding_question.dart';
import '../demographics/age_question.dart';
import 'q4a_fall_history_question.dart';
import '../../../../../constants_and_enums/constants.dart';

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
  
  //MARK: ANSWER STORAGE
  
  List<String>? _riskFactors;
  
  @override
  String? get answer => 
    (_riskFactors == null || _riskFactors!.isEmpty) ? null : _riskFactors!.join(',');
  
  /// Set the fall risk factors with a typed `List<String>`
  void setRiskFactors(List<String>? value) => _riskFactors = value;
  
  /// Get the fall risk factors as a typed `List<String>`
  List<String> get riskFactors => _riskFactors ?? [];
  
  /// Check if specific risk factors are present
  bool get hasFearOfFalling => _riskFactors?.contains(AnswerConstants.fearFalling) ?? false;
  bool get usesMobilityAids => _riskFactors?.contains(AnswerConstants.mobilityAids) ?? false;
  bool get hasBalanceProblems => _riskFactors?.contains(AnswerConstants.balanceProblems) ?? false;
  bool get hasNoRiskFactors => _riskFactors?.contains(AnswerConstants.none) ?? false;
  
  //MARK: VALIDATION
  
  bool isValidAnswer(dynamic answer) {
    if (answer == null) return false;
    if (answer is List<String>) {
      // Check for valid selections
      final validValues = [AnswerConstants.fearFalling, AnswerConstants.mobilityAids, AnswerConstants.balanceProblems, AnswerConstants.none];
      return answer.every((item) => validValues.contains(item));
    }
    return false;
  }
  
  dynamic getDefaultAnswer() => [AnswerConstants.none];
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is List) {
      _riskFactors = json.map((e) => e.toString()).toList();
    } else if (json is String) {
      _riskFactors = json.split(',');
    } else {
      _riskFactors = null;
    }
  }

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return MultipleChoiceView(
      questionId: id,
      answers: {id: _riskFactors ?? []},
      onAnswerChanged: (questionId, value) {
        if (value is List<String>) {
          setRiskFactors(value.isEmpty ? null : value);
        } else if (value is List) {
          var stringList = value.map((e) => e.toString()).toList();
          setRiskFactors(stringList.isEmpty ? null : stringList);
        }
        onAnswerChanged();
      },
      options: options,
      config: config,
    );
  }
}
