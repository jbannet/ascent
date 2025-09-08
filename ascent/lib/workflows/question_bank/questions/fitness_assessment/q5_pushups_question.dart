import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';

/// Q5: How many push-ups can you do in a row (with good form)?
/// 
/// This question assesses upper body strength and muscular endurance.
/// It contributes to multiple ML features related to strength capacity.
class Q5PushupsQuestion extends OnboardingQuestion {
  static const String questionId = 'Q5';
  static final Q5PushupsQuestion instance = Q5PushupsQuestion._();
  Q5PushupsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q5PushupsQuestion.questionId;
  
  @override
  String get questionText => 'How many push-ups can you do in a row (with good form)?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.slider;
  
  @override
  String? get subtitle => 'Slide to select your maximum push-ups';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0.0,
    'maxValue': 100.0,
    'step': 1.0,
    'showValue': true,
    'divisions': 10,
    'unit': ' reps',
    'labelFormatter': (double value) => value >= 100 ? '100+' : value.toInt().toString(),
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final count = answer.toDouble();
    return count >= 0 && count <= 100; // Slider range
  }
  
  @override
  dynamic getDefaultAnswer() => 0.0; // Default to 0 push-ups if not answered
  
  //MARK: TYPED ACCESSOR
  
  /// Get pushups count as int from answers
  int? getPushupsCount(Map<String, dynamic> answers) {
    final count = answers[questionId];
    if (count == null) return null;
    if (count is int) return count;
    if (count is double) return count.toInt();
    return int.tryParse(count.toString());
  }
}