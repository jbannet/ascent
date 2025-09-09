import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../views/question_types/single_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Gender demographic question for fitness assessment normalization.
/// 
/// Gender is used for fitness norm calculations, body composition estimates,
/// and gender-specific training considerations.
class GenderQuestion extends OnboardingQuestion {
  static const String questionId = 'gender';
  static final GenderQuestion instance = GenderQuestion._();
  GenderQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => GenderQuestion.questionId;
  
  @override
  String get questionText => 'What is your gender?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'This helps us provide personalized fitness recommendations';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.male, label: 'Male'),
    QuestionOption(value: AnswerConstants.female, label: 'Female'),
    QuestionOption(value: AnswerConstants.nonBinary, label: 'Non-binary'),
    QuestionOption(value: AnswerConstants.preferNotToSay, label: 'Prefer not to say'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = [AnswerConstants.male, AnswerConstants.female, AnswerConstants.nonBinary, AnswerConstants.preferNotToSay];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.preferNotToSay; // Respectful default
  
  //MARK: TYPED ACCESSOR
  
  //MARK: TYPED ANSWER INTERFACE
  
  /// Get the gender as a typed String
  String? get genderAnswer => answer as String?;
  
  /// Set the gender with a typed String
  set genderAnswer(String? value) => answer = value;
  
  /// Check for specific gender values
  bool get isMale => genderAnswer == AnswerConstants.male;
  bool get isFemale => genderAnswer == AnswerConstants.female;
  bool get isNonBinary => genderAnswer == AnswerConstants.nonBinary;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return SingleChoiceView(
      questionId: id,
      answers: {id: genderAnswer},
      onAnswerChanged: (questionId, value) {
        genderAnswer = value as String;
        onAnswerChanged();
      },
      options: options,
    );
  }
}