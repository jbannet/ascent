import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/date_picker_view.dart';
import '../onboarding_question.dart';

/// Date of birth demographic question for fitness assessment normalization.
/// 
/// Age is a critical factor for fitness norms, training intensity calculations,
/// and age-appropriate exercise recommendations. Using date of birth allows
/// for accurate age calculation over time. The answer stored is the calculated
/// age as an integer for compatibility with existing code.
class AgeQuestion extends OnboardingQuestion {
  static const String questionId = 'age';
  static final AgeQuestion instance = AgeQuestion._();
  AgeQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => AgeQuestion.questionId;
  
  @override
  String get questionText => 'What is your date of birth?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.datePicker;
  
  @override
  String? get subtitle => 'This helps us provide age-appropriate recommendations';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minDate': DateTime(DateTime.now().year - 100, 1, 1).toIso8601String(),
    'maxDate': DateTime(DateTime.now().year - 13, 12, 31).toIso8601String(),
    'dateFormat': 'MM/dd/yyyy',
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! String) return false;
    try {
      final date = DateTime.parse(answer);
      final now = DateTime.now();
      final age = now.year - date.year - (now.month < date.month || (now.month == date.month && now.day < date.day) ? 1 : 0);
      return age >= 13 && age <= 100;
    } catch (e) {
      return false;
    }
  }
  
  @override
  dynamic getDefaultAnswer() => DateTime(DateTime.now().year - 35, DateTime.now().month, DateTime.now().day).toIso8601String();
  
  //MARK: TYPED ACCESSOR
  
  /// Get date of birth as DateTime from answers
  DateTime? getDateOfBirth(Map<String, dynamic> answers) {
    final dateStr = answers[questionId] as String?;
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
  
  /// Get age as integer calculated from date of birth
  int? getAge(Map<String, dynamic> answers) {
    final dateOfBirth = getDateOfBirth(answers);
    if (dateOfBirth == null) return null;
    
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year - (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day) ? 1 : 0);
    return age;
  }

  @override
  Widget buildAnswerWidget(
    Map<String, dynamic> currentAnswers,
    Function(String, dynamic) onAnswerChanged,
  ) {
    return DatePickerView(
      questionId: id,
      answers: currentAnswers,
      onAnswerChanged: onAnswerChanged,
      config: config,
    );
  }
}