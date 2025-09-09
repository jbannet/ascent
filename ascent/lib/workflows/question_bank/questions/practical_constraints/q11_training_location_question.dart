import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../views/question_types/single_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Q11: Where do you prefer to train?
/// 
/// This question assesses training location preferences and constraints.
/// It contributes to program design, exercise selection, and adherence features.
class Q11TrainingLocationQuestion extends OnboardingQuestion {
  static const String questionId = 'Q11';
  static final Q11TrainingLocationQuestion instance = Q11TrainingLocationQuestion._();
  Q11TrainingLocationQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q11TrainingLocationQuestion.questionId;
  
  @override
  String get questionText => 'Where do you prefer to train?';
  
  @override
  String get section => 'practical_constraints';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Choose your most preferred option';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.homeOnly, label: 'At home only'),
    QuestionOption(value: AnswerConstants.gymOnly, label: 'At the gym only'),
    QuestionOption(value: AnswerConstants.preferHome, label: 'Prefer home but flexible'),
    QuestionOption(value: AnswerConstants.preferGym, label: 'Prefer gym but flexible'),
    QuestionOption(value: AnswerConstants.outdoors, label: 'Outdoors when possible'),
    QuestionOption(value: AnswerConstants.anywhere, label: 'Anywhere is fine'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = [AnswerConstants.homeOnly, AnswerConstants.gymOnly, AnswerConstants.preferHome, AnswerConstants.preferGym, AnswerConstants.outdoors, AnswerConstants.anywhere];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.anywhere; // Most flexible default
  
  //MARK: TYPED ACCESSOR
  
  /// Get training location preference as String from answers
  String? getTrainingLocation(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }

  @override
  Widget buildAnswerWidget(
    Map<String, dynamic> currentAnswers,
    Function(String, dynamic) onAnswerChanged,
  ) {
    return SingleChoiceView(
      questionId: id,
      answers: currentAnswers,
      onAnswerChanged: onAnswerChanged,
      options: options,
    );
  }
}