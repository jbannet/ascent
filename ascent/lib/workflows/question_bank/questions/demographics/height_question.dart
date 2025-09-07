import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';

/// Height demographic question for body composition and biomechanical considerations.
/// 
/// Height is used for BMI calculations, body composition estimates,
/// and biomechanical exercise modifications.
class HeightQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'height';
  
  @override
  String get questionText => 'What is your height?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'Enter height in centimeters (e.g., 175 cm)';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 100.0,  // Minimum realistic height
    'maxValue': 250.0,  // Maximum realistic height
    'allowDecimals': false,
    'unit': 'cm',
    'placeholder': '175',
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final height = answer.toDouble();
    return height >= 100 && height <= 250;
  }
  
  @override
  dynamic getDefaultAnswer() => 170; // Average height
  
}