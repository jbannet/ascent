import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../demographics/age_question.dart';
import './q4_twelve_minute_run_question.dart';

/// Q4A: Have you fallen in the last 12 months?
/// 
/// This question assesses fall history, which is a strong predictor of future fall risk.
/// It appears after the Cooper test for users who are older or have lower fitness levels.
/// Based on CDC STEADI fall risk assessment protocol.
class Q4AFallHistoryQuestion extends OnboardingQuestion {
  static const String questionId = 'Q4A';
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q4AFallHistoryQuestion.questionId;
  
  @override
  String get questionText => 'Have you fallen in the last 12 months?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'A fall is any event where you lost balance and landed on the floor or ground';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'yes', label: 'Yes'),
    QuestionOption(value: 'no', label: 'No'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: CONDITIONAL DISPLAY
  
  @override
  bool shouldShow(Map<String, dynamic> answers) {
    // Show if age >= 50 OR Cooper test < 1500m
    
    final age = answers[AgeQuestion.questionId] as int?;
    final cooperDistance = answers[Q4TwelveMinuteRunQuestion.questionId] as num?;
    
    if (age != null && age >= 50) return true;
    if (cooperDistance != null && cooperDistance < 1500) return true;
    
    return false;
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    return answer == 'yes' || answer == 'no';
  }
  
  @override
  dynamic getDefaultAnswer() => 'no';
}

