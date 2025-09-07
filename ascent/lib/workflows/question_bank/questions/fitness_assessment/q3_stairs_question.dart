import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';

/// Q3: Do you get out of breath walking up 2 flights of stairs?
/// 
/// This question assesses cardiovascular fitness and functional capacity.
/// It contributes to cardio fitness and exercise intensity features.
class Q3StairsQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q3';
  
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
    QuestionOption(value: 'not_at_all', label: 'Not at all'),
    QuestionOption(value: 'slightly', label: 'Slightly out of breath'),
    QuestionOption(value: 'moderately', label: 'Moderately out of breath'),
    QuestionOption(value: 'very', label: 'Very out of breath'),
    QuestionOption(value: 'avoid', label: 'I avoid stairs when possible'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['not_at_all', 'slightly', 'moderately', 'very', 'avoid'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'moderately'; // Conservative middle ground
  
}