import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../models/questions/question_option.dart';
import '../../../views/question_views/question_types/single_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../../constants_and_enums/constants.dart';
import '../../registry/question_bank.dart';
import '../demographics/age_question.dart';
import 'q4_run_vo2_question.dart';

/// Q4A: Have you fallen in the last 12 months?
/// 
/// This question assesses fall history, which is a strong predictor of future fall risk.
/// It appears after the Cooper test for users who are older or have lower fitness levels.
/// Based on CDC STEADI fall risk assessment protocol.
class Q4AFallHistoryQuestion extends OnboardingQuestion {
  static const String questionId = 'Q4A';
  static final Q4AFallHistoryQuestion instance = Q4AFallHistoryQuestion._();
  Q4AFallHistoryQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q4AFallHistoryQuestion.questionId;
  
  @override
  String get questionText => 'Have you fallen in the last 12 months?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'A fall is any event where you lost balance and landed on the floor or ground';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.yes, label: 'Yes'),
    QuestionOption(value: AnswerConstants.no, label: 'No'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: CONDITIONAL DISPLAY
  
  @override
  bool shouldShow() {
    // Show if age >= fall risk threshold OR Cooper test indicates mobility limitation risk

    final ageQuestion = QuestionBank.getQuestion(QuestionIds.age) as AgeQuestion?;
    final runQuestion = QuestionBank.getQuestion(QuestionIds.runWalk) as Q4TwelveMinuteRunQuestion?;

    final age = ageQuestion?.calculatedAge;
    final runData = runQuestion?.runPerformanceData;

    if (age != null && age >= AnswerConstants.fallRiskAge) return true;
    if (runData != null && runData.distanceMiles < AnswerConstants.cooperAtRiskMiles) return true;

    return false;
  }
  
  //MARK: TYPED ANSWER INTERFACE
  
  //MARK: ANSWER STORAGE
  
  String? _fallHistoryAnswer;
  
  @override
  String? get answer => _fallHistoryAnswer;
  
  /// Set the fall history answer with a typed String
  void setFallHistoryAnswer(String? value) => _fallHistoryAnswer = value;
  
  /// Get the fall history answer as a typed String
  String? get fallHistoryAnswer => _fallHistoryAnswer;
  
  /// Get fall history as a boolean
  bool get hasFallen => _fallHistoryAnswer == AnswerConstants.yes;
  
  //MARK: VALIDATION
  
  bool isValidAnswer(dynamic answer) {
    return answer == AnswerConstants.yes || answer == AnswerConstants.no;
  }
  
  dynamic getDefaultAnswer() => AnswerConstants.no;
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is String) {
      _fallHistoryAnswer = json;
    } else {
      _fallHistoryAnswer = null;
    }
  }

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return SingleChoiceView(
      questionId: id,
      answers: {id: _fallHistoryAnswer},
      onAnswerChanged: (questionId, value) {
        setFallHistoryAnswer(value);
        onAnswerChanged();
      },
      options: options,
    );
  }
}
