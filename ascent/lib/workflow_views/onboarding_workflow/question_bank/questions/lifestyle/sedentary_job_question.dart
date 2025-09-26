import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../models/questions/question_option.dart';
import '../../../views/question_views/question_types/single_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../../constants_and_enums/constants.dart';

/// Sedentary job assessment question to understand workplace activity levels.
///
/// This helps identify users who spend long periods sitting, which affects
/// their overall activity baseline and may influence exercise recommendations
/// for posture, mobility, and counteracting sedentary behavior.
class SedentaryJobQuestion extends OnboardingQuestion {
  static const String questionId = 'sedentary_job';
  static final SedentaryJobQuestion instance = SedentaryJobQuestion._();
  SedentaryJobQuestion._();

  //MARK: UI PRESENTATION DATA

  @override
  String get id => SedentaryJobQuestion.questionId;

  @override
  String get questionText =>
      'Does your job require you to sit for long periods of time?';

  @override
  String get section => 'lifestyle';

  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;

  @override
  String? get subtitle =>
      'This helps us recommend exercises for posture and mobility';

  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.yes, label: 'Yes'),
    QuestionOption(value: AnswerConstants.no, label: 'No'),
  ];

  @override
  Map<String, dynamic> get config => {'isRequired': true};

  //MARK: VALIDATION

  bool isValidAnswer(dynamic answer) {
    if (answer is! String) return false;
    return [AnswerConstants.yes, AnswerConstants.no].contains(answer);
  }

  dynamic getDefaultAnswer() => AnswerConstants.no;

  @override
  void fromJsonValue(dynamic json) {
    if (json is String) {
      _sedentaryJob = json;
    } else {
      _sedentaryJob = null;
    }
  }

  //MARK: TYPED ACCESSOR

  /// Get sedentary job status from answers
  String? getSedentaryJobStatus(Map<String, dynamic> answers) {
    final status = answers[questionId];
    if (status == null) return null;
    return status is String ? status : status.toString();
  }

  /// Check if user has a sedentary job
  bool hasSedentaryJob(Map<String, dynamic> answers) {
    final status = getSedentaryJobStatus(answers);
    return status == AnswerConstants.yes;
  }

  //MARK: ANSWER STORAGE

  String? _sedentaryJob;

  @override
  String? get answer => _sedentaryJob;

  /// Set the sedentary job status with a typed String
  void setSedentaryJobStatus(String? value) => _sedentaryJob = value;

  /// Get the sedentary job status as a typed String
  String? get sedentaryJobStatus => _sedentaryJob;

  bool get hasSedentaryJobFlag => _sedentaryJob == AnswerConstants.yes;

  @override
  Widget buildAnswerWidget(Function() onAnswerChanged) {
    return SingleChoiceView(
      questionId: id,
      answers: {id: _sedentaryJob},
      onAnswerChanged: (questionId, value) {
        setSedentaryJobStatus(value);
        onAnswerChanged();
      },
      options: options,
    );
  }
}
