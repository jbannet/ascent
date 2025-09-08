import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import './q4_twelve_minute_run_question.dart';
import '../../../../constants.dart';

/// Stairs breathlessness assessment question.
/// 
/// This question assesses cardiovascular fitness and functional capacity.
/// Only shown if Cooper test results indicate limited fitness (<0.93 miles in 12 minutes).
/// It contributes to cardio fitness and exercise intensity features.
class StairsQuestion extends OnboardingQuestion {
  static const String questionId = 'stairs';
  static final StairsQuestion instance = StairsQuestion._();
  StairsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => StairsQuestion.questionId;
  
  @override
  String get questionText => 'Do you get out of breath walking up 2 flights of stairs?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Think about your typical response';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: AnswerConstants.notAtAll, label: 'Not at all'),
    QuestionOption(value: AnswerConstants.slightly, label: 'Slightly out of breath'),
    QuestionOption(value: AnswerConstants.moderately, label: 'Moderately out of breath'),
    QuestionOption(value: AnswerConstants.very, label: 'Very out of breath'),
    QuestionOption(value: AnswerConstants.avoid, label: 'I avoid stairs when possible'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: CONDITIONAL DISPLAY
  
  @override
  bool shouldShow(Map<String, dynamic> answers) {
    // Only show if Cooper test indicates mobility limitation risk
    final cooperDistance = answers[Q4TwelveMinuteRunQuestion.questionId] as num?;
    
    if (cooperDistance != null && cooperDistance < AnswerConstants.cooperAtRiskMiles) return true;
    
    return false;
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = [AnswerConstants.notAtAll, AnswerConstants.slightly, AnswerConstants.moderately, AnswerConstants.very, AnswerConstants.avoid];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.moderately; // Conservative middle ground
  
  //MARK: TYPED ACCESSOR
  
  /// Get stairs response as String from answers
  String? getStairsResponse(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }
}