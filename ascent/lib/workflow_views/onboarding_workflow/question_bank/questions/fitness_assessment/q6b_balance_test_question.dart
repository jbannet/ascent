import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../views/question_views/question_types/slider_view.dart';
import '../onboarding_question.dart';
import '../../../../../constants_and_enums/constants.dart';
import '../../registry/question_bank.dart';
import '../demographics/age_question.dart';
import 'q4_run_vo2_question.dart';
import 'q4a_fall_history_question.dart';

/// Q6B: How long can you stand on one foot (in seconds)?
///
/// This question assesses static balance ability, a key predictor of fall risk
/// and functional mobility. It appears for users who have fall risk factors:
/// - Age ≥ 65 years
/// - Poor mobility performance (< 0.36 miles in 12-min test)
/// - History of falls in past year
///
/// The single-leg stance test is a validated functional assessment:
/// - >30 seconds: Excellent balance
/// - 15-29 seconds: Good balance
/// - 5-14 seconds: Fair balance
/// - <5 seconds: Poor balance, high fall risk
///
/// Based on: Berg Balance Scale, Tinetti Balance Assessment
/// Used in: CDC STEADI, clinical fall risk screening
class Q6BBalanceTestQuestion extends OnboardingQuestion {
  static const String questionId = 'Q6B';
  static final Q6BBalanceTestQuestion instance = Q6BBalanceTestQuestion._();
  Q6BBalanceTestQuestion._();

  //MARK: UI PRESENTATION DATA

  @override
  String get id => Q6BBalanceTestQuestion.questionId;

  @override
  String get questionText => 'How long can you stand on one foot (in seconds)?';

  @override
  String get section => 'fitness_assessment';

  @override
  EnumQuestionType get questionType => EnumQuestionType.slider;

  @override
  String? get subtitle => 'Stand on one foot with eyes open. Stop when you need to put your foot down or grab support';

  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0,
    'maxValue': 60,
    'step': 1,
    'unit': 'seconds',
  };

  //MARK: CONDITIONAL DISPLAY

  @override
  bool shouldShow() {
    // Show if ANY risk factor present
    final ageQuestion = QuestionBank.getQuestion(QuestionIds.age) as AgeQuestion?;
    final runQuestion = QuestionBank.getQuestion(QuestionIds.runWalk) as Q4TwelveMinuteRunQuestion?;
    final fallHistoryQuestion = QuestionBank.getQuestion(QuestionIds.fallHistory) as Q4AFallHistoryQuestion?;

    final age = ageQuestion?.calculatedAge;
    final runData = runQuestion?.runPerformanceData;
    final hasFallen = fallHistoryQuestion?.fallHistoryAnswer == AnswerConstants.yes;

    // Show if ANY risk factor present
    if (age != null && age >= AnswerConstants.fallRiskAge) return true;
    if (runData != null && runData.distanceMiles < AnswerConstants.cooperAtRiskMiles) return true;
    if (hasFallen) return true;

    return false;
  }

  //MARK: ANSWER STORAGE

  double? _balanceTime;

  @override
  String? get answer => _balanceTime?.toString();

  /// Set the balance time with a typed double
  void setBalanceTime(double? value) => _balanceTime = value;

  /// Get the balance time as a typed double
  double? get balanceTime => _balanceTime;

  //MARK: TYPED ACCESSORS

  /// Get balance capacity level (0.0 to 1.0) based on balance time
  double getBalanceCapacity() {
    if (_balanceTime == null) return 0.0;

    final time = _balanceTime!;
    if (time >= 30) return 1.0;  // Excellent
    if (time >= 15) return 0.7;  // Good
    if (time >= 5) return 0.4;   // Fair
    return 0.1;                  // Poor
  }

  /// Check if balance indicates high fall risk
  bool isHighFallRisk() {
    return _balanceTime != null && _balanceTime! < 5;
  }

  /// Get descriptive balance level
  String getBalanceLevel() {
    if (_balanceTime == null) return 'Unknown';

    final time = _balanceTime!;
    if (time >= 30) return 'Excellent';
    if (time >= 15) return 'Good';
    if (time >= 5) return 'Fair';
    return 'Poor';
  }

  //MARK: VALIDATION

  bool isValidAnswer(dynamic answer) {
    if (answer == null) return false;
    if (answer is num) {
      final value = answer.toDouble();
      return value >= 0 && value <= 60;
    }
    if (answer is String) {
      final parsed = double.tryParse(answer);
      return parsed != null && parsed >= 0 && parsed <= 60;
    }
    return false;
  }

  dynamic getDefaultAnswer() => 0.0;

  @override
  void fromJsonValue(dynamic json) {
    if (json is num) {
      _balanceTime = json.toDouble();
    } else if (json is String) {
      _balanceTime = double.tryParse(json);
    } else {
      _balanceTime = null;
    }
  }

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return SliderView(
      questionId: id,
      answers: {id: _balanceTime ?? 0.0},
      onAnswerChanged: (questionId, value) {
        if (value is num) {
          setBalanceTime(value.toDouble());
        } else if (value is String) {
          setBalanceTime(double.tryParse(value));
        }
        onAnswerChanged();
      },
      config: config,
    );
  }
}