import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../views/question_types/multiple_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Q10: What equipment do you have access to?
/// 
/// This question assesses available equipment for exercise selection and program design.
/// It contributes to exercise filtering, program complexity, and equipment preference features.
class Q10EquipmentQuestion extends OnboardingQuestion {
  static const String questionId = 'Q10';
  static final Q10EquipmentQuestion instance = Q10EquipmentQuestion._();
  Q10EquipmentQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q10EquipmentQuestion.questionId;
  
  @override
  String get questionText => 'What equipment do you have access to?';
  
  @override
  String get section => 'practical_constraints';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Select all that apply';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.none, label: 'No equipment (bodyweight only)'),
    QuestionOption(value: AnswerConstants.dumbbells, label: 'Dumbbells'),
    QuestionOption(value: AnswerConstants.resistanceBands, label: 'Resistance bands'),
    QuestionOption(value: AnswerConstants.barbell, label: 'Barbell and weights'),
    QuestionOption(value: AnswerConstants.cableMachine, label: 'Cable machine'),
    QuestionOption(value: AnswerConstants.cardioMachines, label: 'Cardio machines (treadmill, bike, etc.)'),
    QuestionOption(value: AnswerConstants.fullGym, label: 'Full gym access'),
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
  dynamic getDefaultAnswer() => [AnswerConstants.none]; // Default to bodyweight only
  
  //MARK: TYPED ACCESSOR
  
  /// Get available equipment as List&lt;String&gt; from answers
  List<String> getAvailableEquipment(Map<String, dynamic> answers) {
    final equipment = answers[questionId];
    if (equipment == null) return [AnswerConstants.none];
    if (equipment is List) return equipment.cast<String>();
    return [equipment.toString()];
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