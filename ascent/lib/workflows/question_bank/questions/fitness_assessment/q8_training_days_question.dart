import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';

/// Q8: How many days per week can you realistically commit to training?
/// 
/// This question assesses training frequency commitment and schedule constraints.
/// It contributes to program structure, volume, and adherence features.
class Q8TrainingDaysQuestion extends OnboardingQuestion {
  static const String questionId = 'Q8';
  static final Q8TrainingDaysQuestion instance = Q8TrainingDaysQuestion._();
  Q8TrainingDaysQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q8TrainingDaysQuestion.questionId;
  
  @override
  String get questionText => 'How many days per week can you realistically commit to training?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Be realistic about your schedule and lifestyle';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: '1', label: '1 day per week'),
    QuestionOption(value: '2', label: '2 days per week'),
    QuestionOption(value: '3', label: '3 days per week'),
    QuestionOption(value: '4', label: '4 days per week'),
    QuestionOption(value: '5', label: '5 days per week'),
    QuestionOption(value: '6', label: '6+ days per week'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['1', '2', '3', '4', '5', '6'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => '3'; // 3 days is often recommended minimum
  
  //MARK: TYPED ACCESSOR
  
  /// Get training days per week as int from answers
  int? getTrainingDays(Map<String, dynamic> answers) {
    final days = answers[questionId];
    if (days == null) return null;
    return days is int ? days : int.tryParse(days.toString());
  }
  
}