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
  
  //MARK: TYPED ANSWER INTERFACE
  
  /// Get the date of birth as a typed DateTime
  DateTime? get dateOfBirth => answer as DateTime?;
  
  /// Set the date of birth with a typed DateTime
  set dateOfBirth(DateTime? value) => answer = value;
  
  /// Calculate age from the stored date of birth
  int? get calculatedAge {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    final birth = dateOfBirth!;
    return now.year - birth.year - (now.month < birth.month || (now.month == birth.month && now.day < birth.day) ? 1 : 0);
  }

  //MARK: VALIDATION & SERIALIZATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final date = answer as DateTime?;
    if (date == null) return false;
    
    final now = DateTime.now();
    final age = now.year - date.year - (now.month < date.month || (now.month == date.month && now.day < date.day) ? 1 : 0);
    return age >= 13 && age <= 100;
  }

  @override
  dynamic answerToJson(dynamic value) {
    final date = value as DateTime?;
    return date?.toIso8601String();
  }

  @override
  dynamic answerFromJson(dynamic json) {
    if (json == null) return null;
    return DateTime.parse(json as String);
  }
  
  @override
  dynamic getDefaultAnswer() {
    final defaultDate = DateTime(DateTime.now().year - 35, DateTime.now().month, DateTime.now().day);
    return defaultDate;
  }

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return DatePickerView(
      questionId: id,
      answers: {id: dateOfBirth},
      onAnswerChanged: (questionId, selectedDate) {
        dateOfBirth = selectedDate as DateTime;
        onAnswerChanged();
      },
      config: config,
    );
  }
}