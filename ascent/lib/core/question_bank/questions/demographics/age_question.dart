import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';

/// Age demographic question for fitness assessment normalization.
/// 
/// Age is a critical factor for fitness norms, training intensity calculations,
/// and age-appropriate exercise recommendations.
class AgeQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'age';
  
  @override
  String get questionText => 'What is your age?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'This helps us provide age-appropriate recommendations';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 13.0,
    'maxValue': 100.0,
    'allowDecimals': false,
    'unit': 'years',
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final age = answer.toInt();
    return age >= 13 && age <= 100;
  }
  
  @override
  dynamic getDefaultAnswer() => 35; // Default adult age
}