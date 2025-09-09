import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/text_input_view.dart';
import '../onboarding_question.dart';

/// User name question for personalization and user identification.
/// 
/// This question collects the user's name for personalized experiences
/// and user account setup.
class UserNameQuestion extends OnboardingQuestion {
  static const String questionId = 'user_name';
  static final UserNameQuestion instance = UserNameQuestion._();
  UserNameQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => UserNameQuestion.questionId;
  
  @override
  String get questionText => 'What can I call you?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.textInput;
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minLength': 2,
    'maxLength': 50,
    'placeholder': 'Name or nickname',
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! String) return false;
    final name = answer.trim();
    return name.length >= 2 && name.length <= 50;
  }
  
  @override
  dynamic getDefaultAnswer() => null; // No default for names
  
  //MARK: TYPED ANSWER INTERFACE
  
  /// Get the user name as a typed String
  String? get userName => answer as String?;
  
  /// Set the user name with a typed String
  set userName(String? value) => answer = value;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return TextInputView(
      questionId: id,
      answers: {id: userName},
      onAnswerChanged: (questionId, value) {
        userName = value as String;
        onAnswerChanged();
      },
      config: config,
    );
  }
}