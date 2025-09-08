import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Current fitness level self-assessment question.
/// 
/// This question helps establish baseline fitness level for program selection
/// and progression planning.
class CurrentFitnessLevelQuestion extends OnboardingQuestion {
  static const String questionId = 'current_fitness_level';
  static final CurrentFitnessLevelQuestion instance = CurrentFitnessLevelQuestion._();
  CurrentFitnessLevelQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => CurrentFitnessLevelQuestion.questionId;
  
  @override
  String get questionText => 'What is your current fitness level?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: AnswerConstants.beginner,
      label: 'Beginner',
      description: 'Little to no regular exercise',
    ),
    QuestionOption(
      value: AnswerConstants.intermediate,
      label: 'Intermediate',
      description: 'Exercise 1-3 times per week',
    ),
    QuestionOption(
      value: AnswerConstants.advanced,
      label: 'Advanced',
      description: 'Exercise 4-6 times per week',
    ),
    QuestionOption(
      value: AnswerConstants.expert,
      label: 'Expert',
      description: 'Daily training routine',
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validLevels = [AnswerConstants.beginner, AnswerConstants.intermediate, AnswerConstants.advanced, AnswerConstants.expert];
    return validLevels.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => AnswerConstants.beginner; // Conservative default
  
  
  //MARK: TYPED ACCESSOR
  
  /// Get fitness level as String from answers
  String? getFitnessLevel(Map<String, dynamic> answers) {
    return answers[questionId] as String?;
  }
}