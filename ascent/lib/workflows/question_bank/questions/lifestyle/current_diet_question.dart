import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../models/fitness_profile_model/feature_contribution.dart';

/// Current diet assessment question.
class CurrentDietQuestion extends OnboardingQuestion {
  @override
  String get id => 'current_diet';
  
  @override
  String get questionText => 'How would you describe your current diet?';
  
  @override
  String get section => 'lifestyle';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'very_healthy', label: 'Very healthy', description: 'Consistently eat nutritious, balanced meals'),
    QuestionOption(value: 'mostly_healthy', label: 'Mostly healthy', description: 'Generally good choices with occasional treats'),
    QuestionOption(value: 'average', label: 'Average', description: 'Mix of healthy and less healthy foods'),
    QuestionOption(value: 'needs_improvement', label: 'Needs improvement', description: 'Know I should eat better but struggle'),
    QuestionOption(value: 'poor', label: 'Poor', description: 'Mostly processed or fast food'),
  ];
  
  @override
  Map<String, dynamic> get config => {'isRequired': true};
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final diet = answer.toString();
    final dietScore = _getDietScore(diet);
    
    return [
      FeatureContribution('diet_quality_score', dietScore),
      FeatureContribution('needs_nutrition_education', dietScore < 0.5 ? 1.0 : 0.0),
      FeatureContribution('nutrition_ready', dietScore > 0.7 ? 1.0 : 0.0),
      FeatureContribution('weight_loss_diet_support', dietScore < 0.6 ? 1.0 : 0.0),
    ];
  }
  
  @override
  bool isValidAnswer(dynamic answer) {
    return ['very_healthy', 'mostly_healthy', 'average', 'needs_improvement', 'poor'].contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'average';
  
  double _getDietScore(String diet) {
    switch (diet) {
      case 'very_healthy': return 1.0;
      case 'mostly_healthy': return 0.8;
      case 'average': return 0.5;
      case 'needs_improvement': return 0.3;
      case 'poor': return 0.1;
      default: return 0.5;
    }
  }
}