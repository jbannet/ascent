import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';

/// Q4: How far can you run/walk in 12 minutes? (Cooper Test)
/// 
/// This question assesses cardiovascular fitness using the standardized Cooper 12-minute test.
/// It contributes to cardio fitness, VO2 max estimation, and training intensity features.
class Q4TwelveMinuteRunQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q4';
  
  @override
  String get questionText => 'How far can you run/walk in 12 minutes?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'Enter distance in meters (estimate if unsure)';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 500.0,    // Minimum reasonable distance
    'maxValue': 5000.0,   // Maximum reasonable distance
    'allowDecimals': false,
    'unit': 'meters',
    'placeholder': '2000',
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final distance = answer.toDouble();
    return distance >= 500 && distance <= 5000; // Reasonable range for 12 minutes
  }
  
  @override
  dynamic getDefaultAnswer() => 2000; // Average distance for general population
  
}