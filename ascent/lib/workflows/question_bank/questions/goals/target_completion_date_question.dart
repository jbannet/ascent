import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';

/// Target completion date question.
class TargetCompletionDateQuestion extends OnboardingQuestion {
  static const String questionId = 'target_completion_date';
  static final TargetCompletionDateQuestion instance = TargetCompletionDateQuestion._();
  TargetCompletionDateQuestion._();
  @override
  String get id => TargetCompletionDateQuestion.questionId;
  
  @override
  String get questionText => 'When would you like to achieve your main fitness goal?';
  
  @override
  String get section => 'goals';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.datePicker;
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minDate': '2024-09-01',
    'maxDate': '2025-12-31',
    'initialDatePickerMode': 'day'
  };
  
  
  @override
  bool isValidAnswer(dynamic answer) => answer != null;
  
  @override
  dynamic getDefaultAnswer() => null;
  
  //MARK: TYPED ACCESSOR
  
  /// Get target completion date as DateTime from answers
  DateTime? getTargetCompletionDate(Map<String, dynamic> answers) {
    final date = answers[questionId];
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }
}