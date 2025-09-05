import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_condition.dart';
import '../../base/onboarding_question.dart';
import '../../base/feature_contribution.dart';

/// Weight loss target question for users who selected weight loss as a goal.
/// 
/// This conditional question appears only if the user selected "lose_weight"
/// in their fitness goals and helps quantify their weight loss objective.
class WeightLossTargetQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'weight_loss_target';
  
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
    value: 'lose_weight',
  );
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 5.0,
    'maxValue': 100.0,
    'step': 5.0,
    'showValue': true,
    'unit': 'lbs',
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final weightLossTarget = (answer as num).toDouble();
    final targetCategory = _getTargetCategory(weightLossTarget);
    
    return [
      // Raw weight loss target
      FeatureContribution('weight_loss_target_lbs', weightLossTarget / 100.0), // Normalize
      FeatureContribution('weight_loss_target_raw', weightLossTarget),
      
      // Weight loss categories
      FeatureContribution('modest_weight_loss', targetCategory == 'modest' ? 1.0 : 0.0),
      FeatureContribution('moderate_weight_loss', targetCategory == 'moderate' ? 1.0 : 0.0),
      FeatureContribution('significant_weight_loss', targetCategory == 'significant' ? 1.0 : 0.0),
      FeatureContribution('major_weight_loss', targetCategory == 'major' ? 1.0 : 0.0),
      
      // Program intensity implications
      FeatureContribution('weight_loss_intensity_factor', _getIntensityFactor(weightLossTarget)),
      FeatureContribution('calorie_deficit_target', _getCalorieDeficitTarget(weightLossTarget)),
      
      // Timeline and sustainability factors
      FeatureContribution('realistic_weight_loss_goal', _isRealisticGoal(weightLossTarget) ? 1.0 : 0.0),
      FeatureContribution('sustainable_approach_needed', weightLossTarget > 20 ? 1.0 : 0.0),
      
      // Nutrition focus requirements
      FeatureContribution('high_nutrition_focus_needed', _needsHighNutritionFocus(weightLossTarget) ? 1.0 : 0.0),
      FeatureContribution('cardio_emphasis_factor', _getCardioEmphasis(weightLossTarget)),
      
      // Support and monitoring needs
      FeatureContribution('needs_close_monitoring', weightLossTarget > 30 ? 1.0 : 0.0),
      FeatureContribution('motivation_support_level', _getMotivationSupportLevel(weightLossTarget)),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final target = answer.toDouble();
    return target >= 5 && target <= 100;
  }
  
  @override
  dynamic getDefaultAnswer() => 20.0; // Moderate goal
  
  //MARK: PRIVATE HELPERS
  
  /// Get weight loss target category
  String _getTargetCategory(double target) {
    if (target <= 10) return 'modest';      // 5-10 lbs
    if (target <= 25) return 'moderate';    // 11-25 lbs
    if (target <= 50) return 'significant'; // 26-50 lbs
    return 'major';                         // 51+ lbs
  }
  
  /// Calculate training intensity factor
  double _getIntensityFactor(double target) {
    if (target <= 10) return 0.6;  // Moderate intensity
    if (target <= 25) return 0.8;  // Higher intensity
    if (target <= 50) return 1.0;  // High intensity
    return 0.9; // Very high but sustainable for major loss
  }
  
  /// Calculate calorie deficit target factor
  double _getCalorieDeficitTarget(double target) {
    // 1 lb = ~3500 calories, reasonable deficit is 500-1000 cal/day
    if (target <= 10) return 0.5;  // Modest deficit
    if (target <= 25) return 0.7;  // Moderate deficit
    if (target <= 50) return 0.9;  // Higher deficit
    return 0.8; // Need to be careful with very large losses
  }
  
  /// Check if weight loss goal is realistic
  bool _isRealisticGoal(double target) {
    // 1-2 lbs per week is generally sustainable
    // Up to 50 lbs is realistic for most people with proper approach
    return target <= 50;
  }
  
  /// Check if high nutrition focus is needed
  bool _needsHighNutritionFocus(double target) {
    return target > 15; // Significant weight loss needs strong nutrition component
  }
  
  /// Calculate cardio emphasis factor
  double _getCardioEmphasis(double target) {
    if (target <= 10) return 0.6;  // Moderate cardio
    if (target <= 25) return 0.8;  // Higher cardio emphasis
    if (target <= 50) return 1.0;  // High cardio emphasis
    return 0.9; // High but balanced with strength training
  }
  
  /// Calculate motivation support level needed
  double _getMotivationSupportLevel(double target) {
    if (target <= 10) return 0.5;  // Lower support needs
    if (target <= 25) return 0.7;  // Moderate support
    if (target <= 50) return 0.9;  // High support needed
    return 1.0; // Maximum support for major weight loss
  }
}