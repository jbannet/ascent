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
  
  /// Validation is handled in the setter
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is String) _genderAnswer = json;
    else _genderAnswer = null;
  }
  
  //MARK: ANSWER STORAGE
  
  String? _genderAnswer;
  
  @override
  String? get answer => _genderAnswer;
  
  /// Set the gender (no validation needed - UI enforces valid options)
  void setGenderAnswer(String? value) => _genderAnswer = value;
  
  /// Get the gender as a typed String
  String? get genderAnswer => _genderAnswer;
  
  /// Check for specific gender values
  bool get isMale => _genderAnswer == AnswerConstants.male;
  bool get isFemale => _genderAnswer == AnswerConstants.female;
  bool get isNonBinary => _genderAnswer == AnswerConstants.nonBinary;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return SingleChoiceView(
      questionId: id,
      answers: {id: _genderAnswer},
      onAnswerChanged: (questionId, value) {
        setGenderAnswer(value as String?);
        onAnswerChanged();
      },
      options: options,
    );
  }
}