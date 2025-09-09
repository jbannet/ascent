import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../views/question_types/multiple_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Q2: Are there any activities you should avoid due to medical advice?
/// 
/// This question identifies medical restrictions that limit exercise types.
/// It contributes to exercise safety and modification features.
class Q2HighImpactQuestion extends OnboardingQuestion {
  static const String questionId = 'Q2';
  static final Q2HighImpactQuestion instance = Q2HighImpactQuestion._();
  Q2HighImpactQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q2HighImpactQuestion.questionId;
  
  @override
  String get questionText => 'Are there any activities you should avoid due to medical advice?';
  
  @override
  String get section => 'practical_constraints';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Select all that apply';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.none, label: 'No restrictions'),
    QuestionOption(value: AnswerConstants.highImpact, label: 'High-impact activities (jumping, running)'),
    QuestionOption(value: AnswerConstants.heavyLifting, label: 'Heavy lifting or straining'),
    QuestionOption(value: AnswerConstants.overhead, label: 'Overhead movements'),
    QuestionOption(value: AnswerConstants.twisting, label: 'Twisting or rotating motions'),
    QuestionOption(value: AnswerConstants.balanceProblems, label: 'Balance-challenging exercises'),
    QuestionOption(value: AnswerConstants.cardioIntense, label: 'Intense cardiovascular exercise'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is List) {
      return answer.isNotEmpty && answer.every((item) => item is String);
    }
    return answer is String && answer.isNotEmpty;
  }
  
  @override
  dynamic getDefaultAnswer() => [AnswerConstants.none]; // Default to no restrictions
  
  //MARK: TYPED ACCESSOR
  
  /// Get medical restrictions as List<String> from answers
  List<String> getMedicalRestrictions(Map<String, dynamic> answers) {
    final restrictions = answers[questionId];
    if (restrictions == null) return [AnswerConstants.none];
    if (restrictions is List) return restrictions.cast<String>();
    return [restrictions.toString()];
  }

  @override
  Widget buildAnswerWidget(
    Map<String, dynamic> currentAnswers,
    Function(String, dynamic) onAnswerChanged,
  ) {
    return MultipleChoiceView(
      questionId: id,
      answers: currentAnswers,
      onAnswerChanged: onAnswerChanged,
      options: options,
      config: config,
    );
  }
}