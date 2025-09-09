import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../views/question_types/single_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// GLP-1 medications question for strength training prioritization.
/// 
/// GLP-1 receptor agonists (semaglutide, liraglutide, etc.) can cause
/// significant muscle mass loss during weight loss. Users on these medications
/// require prioritized strength training to preserve lean body mass.
/// 
/// References:
/// - Wilding et al. (2021) "Once-Weekly Semaglutide in Adults with Overweight or Obesity" - NEJM
/// - Rubino et al. (2021) "Effect of Continued Weekly Subcutaneous Semaglutide" - JAMA
/// - Ida et al. (2019) "Effects of oral semaglutide on glycemic parameters" - Diabetes Research
class Glp1MedicationsQuestion extends OnboardingQuestion {
  static const String questionId = 'glp1_medications';
  static final Glp1MedicationsQuestion instance = Glp1MedicationsQuestion._();
  Glp1MedicationsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Glp1MedicationsQuestion.questionId;
  
  @override
  String get questionText => 'Are you taking GLP-1s?';
  
  @override
  String get section => 'health_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Such as Ozempic, Wegovy, Mounjaro, or similar medications. We use this to prioritize strength training.';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: AnswerConstants.yes,
      label: 'Yes',
      description: 'I am currently taking GLP-1 medications',
    ),
    QuestionOption(
      value: AnswerConstants.no,
      label: 'No',
      description: 'I am not taking GLP-1 medications',
    ),
    QuestionOption(
      value: AnswerConstants.preferNotToSay,
      label: 'Prefer not to say',
      description: 'I prefer not to disclose this information',
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': false, // Medical information should be optional
  };
  
  //MARK: VALIDATION
  
  bool isValidAnswer(dynamic answer) {
    if (answer == null) return true; // Optional field
    if (answer is! String) return false;
    
    return [
      AnswerConstants.yes,
      AnswerConstants.no, 
      AnswerConstants.preferNotToSay
    ].contains(answer);
  }
  
  dynamic getDefaultAnswer() => null; // Optional field
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is String) {
      _glp1Status = json;
    } else {
      _glp1Status = null;
    }
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get GLP-1 medication status from answers
  String? getGlp1Status(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }
  
  /// Check if user is taking GLP-1 medications
  bool isOnGlp1Medications(Map<String, dynamic> answers) {
    return getGlp1Status(answers) == AnswerConstants.yes;
  }
  
  /// Check if user disclosed GLP-1 information (answered yes or no, not prefer not to say)
  bool hasDisclosedGlp1Status(Map<String, dynamic> answers) {
    final status = getGlp1Status(answers);
    return status == AnswerConstants.yes || status == AnswerConstants.no;
  }

  //MARK: ANSWER STORAGE
  
  String? _glp1Status;
  
  @override
  String? get answer => _glp1Status;
  
  /// Set the GLP-1 medication status with a typed String
  void setGlp1Status(String? value) => _glp1Status = value;
  
  /// Get the GLP-1 medication status as a typed String
  String? get glp1Status => _glp1Status;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return SingleChoiceView(
      questionId: id,
      answers: {id: _glp1Status},
      onAnswerChanged: (questionId, value) {
        setGlp1Status(value);
        onAnswerChanged();
      },
      options: options,
    );
  }
}