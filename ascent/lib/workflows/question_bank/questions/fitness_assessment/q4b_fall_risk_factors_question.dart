import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../demographics/age_question.dart';
import './q4a_fall_history_question.dart';
import '../../../../constants.dart';

/// Q4B: Do you experience any of the following?
/// 
/// This question assesses additional fall risk factors beyond fall history.
/// It appears for users who have fallen OR are 65+ years old.
/// Based on CDC STEADI fall risk assessment protocol.
class Q4BFallRiskFactorsQuestion extends OnboardingQuestion {
  static const String questionId = 'Q4B';
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q4BFallRiskFactorsQuestion.questionId;
  
  @override
  String get questionText => 'Do you experience any of the following?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Select all that apply';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: AnswerConstants.fearFalling, 
      label: 'Fear of falling',
      description: 'Worry about losing balance or falling during daily activities'
    ),
    QuestionOption(
      value: AnswerConstants.mobilityAids, 
      label: 'Use mobility aids',
      description: 'Walker, cane, or other assistive devices'
    ),
    QuestionOption(
      value: AnswerConstants.balanceProblems, 
      label: 'Balance problems',
      description: 'Feeling unsteady, lightheaded, or having trouble with balance'
    ),
    QuestionOption(
      value: AnswerConstants.none, 
      label: 'None of the above'
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
  };
  
  //MARK: CONDITIONAL DISPLAY
  
  @override
  bool shouldShow(Map<String, dynamic> answers) {
    // Show if Q4A = 'yes' (has fallen) OR age >= 65
    final hasFallen = answers[Q4AFallHistoryQuestion.questionId] as String?;
    final age = answers[AgeQuestion.questionId] as int?;
    
    if (hasFallen == 'yes') return true;
    if (age != null && age >= 65) return true;
    
    return false;
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer == null) return false;
    if (answer is String) return true; // Single selection
    if (answer is List) {
      // Check for valid selections
      final validValues = [AnswerConstants.fearFalling, AnswerConstants.mobilityAids, AnswerConstants.balanceProblems, AnswerConstants.none];
      return answer.every((item) => validValues.contains(item));
    }
    return false;
  }
  
  @override
  dynamic getDefaultAnswer() => [AnswerConstants.none];
}

