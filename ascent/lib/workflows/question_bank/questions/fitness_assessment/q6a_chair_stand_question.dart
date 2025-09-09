import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../../onboarding_workflow/models/questions/question_condition.dart';
import '../../views/question_types/single_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Q6A: Are you able to get up from a chair without using your hands for support?
/// 
/// This is a follow-up question that only appears when the user reports 0 squats.
/// It assesses basic functional strength needed for daily activities.
/// 
/// The chair stand test is a validated functional assessment that predicts:
/// - Fall risk
/// - Need for assistance with daily activities
/// - Overall lower body functional strength
/// - Sarcopenia severity
/// 
/// Interpretation:
/// - Yes: Has basic functional strength, needs progressive strengthening
/// - No: Lacks functional strength, needs seated/supported exercises
/// 
/// Based on: 30-Second Chair Stand Test (Jones et al., 1999)
/// Used in: CDC STEADI, Senior Fitness Test
class Q6AChairStandQuestion extends OnboardingQuestion {
  static const String questionId = 'Q6A';
  static final Q6AChairStandQuestion instance = Q6AChairStandQuestion._();
  Q6AChairStandQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q6AChairStandQuestion.questionId;
  
  @override
  String get questionText => 'Are you able to get up from a chair without using your hands for support?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Start seated, stand up without pushing off with your hands';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: AnswerConstants.yes, 
      label: 'Yes',
      description: 'I can stand up without using my hands',
    ),
    QuestionOption(
      value: AnswerConstants.no, 
      label: 'No',
      description: 'I need to push off with my hands or cannot do it',
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  @override
  QuestionCondition? get condition => QuestionCondition(
    questionId: 'Q6',
    operator: 'equals',
    value: 0,
  );
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! String) return false;
    return [AnswerConstants.yes, AnswerConstants.no].contains(answer);
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.no; // Conservative default for safety
  
  //MARK: TYPED ACCESSORS
  
  /// Check if user can stand from chair without hands
  bool? canStandFromChair(Map<String, dynamic> answers) {
    final answer = answers[questionId];
    if (answer == null) return null;
    return answer == AnswerConstants.yes;
  }
  
  /// Get functional strength level based on chair stand ability
  double getFunctionalStrengthLevel(Map<String, dynamic> answers) {
    final canStand = canStandFromChair(answers);
    if (canStand == null) return 0.0;
    
    // If they can stand from chair (but couldn't do squats)
    // they have basic functional strength
    return canStand ? 0.3 : 0.0;
  }
  
  /// Determine if user needs seated exercises only
  bool needsSeatedExercises(Map<String, dynamic> answers) {
    final canStand = canStandFromChair(answers);
    return canStand == false;
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