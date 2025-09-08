import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_condition.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Weight loss target question for users who selected weight loss as a goal.
/// 
/// This conditional question appears only if the user selected "lose_weight"
/// in their fitness goals and helps quantify their weight loss objective.
class WeightLossTargetQuestion extends OnboardingQuestion {
  static const String questionId = 'weight_loss_target';
  static final WeightLossTargetQuestion instance = WeightLossTargetQuestion._();
  WeightLossTargetQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => WeightLossTargetQuestion.questionId;
  
  @override
  String get questionText => 'How much weight do you want to lose?';
  
  @override
  String get section => 'goals';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.slider;
  
  @override
  QuestionCondition get condition => QuestionCondition(
    questionId: 'fitness_goals',
    operator: 'contains',
    value: AnswerConstants.loseWeight,
  );
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 1.0,
    'maxValue': 100.0,
    'step': 1.0,
    'showValue': true,
    'unit': 'lbs'
  };
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final target = answer.toDouble();
    return target >= 1 && target <= 100;
  }
  
  @override
  dynamic getDefaultAnswer() => 20.0; // Moderate goal
  
  //MARK: TYPED ACCESSOR
  
  /// Get weight loss target as double from answers (in lbs)
  double? getWeightLossTarget(Map<String, dynamic> answers) {
    final target = answers[questionId];
    if (target == null) return null;
    return target is double ? target : double.tryParse(target.toString());
  }
}