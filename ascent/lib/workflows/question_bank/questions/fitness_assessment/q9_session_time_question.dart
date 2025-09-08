import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';

/// Q9: How much time can you dedicate to each workout session?
/// 
/// This question assesses time constraints and workout structure preferences.
/// It contributes to program design, exercise selection, and efficiency features.
class Q9SessionTimeQuestion extends OnboardingQuestion {
  static const String questionId = 'Q9';
  static final Q9SessionTimeQuestion instance = Q9SessionTimeQuestion._();
  Q9SessionTimeQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q9SessionTimeQuestion.questionId;
  
  @override
  String get questionText => 'How much time can you dedicate to each workout session?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Include warm-up, workout, and cool-down time';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: '15', label: '15 minutes or less'),
    QuestionOption(value: '30', label: '30 minutes'),
    QuestionOption(value: '45', label: '45 minutes'),
    QuestionOption(value: '60', label: '1 hour'),
    QuestionOption(value: '90', label: '1.5 hours'),
    QuestionOption(value: '120', label: '2+ hours'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['15', '30', '45', '60', '90', '120'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => '45'; // 45 minutes is a good balance
  
  //MARK: TYPED ACCESSOR
  
  /// Get session time in minutes as int from answers
  int? getSessionMinutes(Map<String, dynamic> answers) {
    final minutes = answers[questionId];
    if (minutes == null) return null;
    return minutes is int ? minutes : int.tryParse(minutes.toString());
  }
  
}