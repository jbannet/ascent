import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Fitness goals question for understanding user's primary objectives.
/// 
/// This question identifies the user's main fitness goals to tailor
/// program recommendations and exercise selection.
class FitnessGoalsQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'fitness_goals';
  
  @override
  String get questionText => 'What are your primary fitness goals?';
  
  @override
  String get section => 'goals';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Choose up to 3 goals';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: 'lose_weight',
      label: 'Lose weight',
      description: 'Reduce overall body weight',
    ),
    QuestionOption(
      value: 'build_muscle',
      label: 'Build muscle',
      description: 'Increase muscle mass and strength',
    ),
    QuestionOption(
      value: 'improve_endurance',
      label: 'Improve endurance',
      description: 'Build cardiovascular fitness',
    ),
    QuestionOption(
      value: 'increase_flexibility',
      label: 'Increase flexibility',
      description: 'Improve range of motion and mobility',
    ),
    QuestionOption(
      value: 'better_health',
      label: 'Better overall health',
      description: 'General wellness and disease prevention',
    ),
    QuestionOption(
      value: 'live_longer',
      label: 'Live longer',
      description: 'Longevity and aging well',
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
    'minSelections': 1,
    'maxSelections': 3,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final selections = answer is List ? answer.cast<String>() : [answer.toString()];
    final goalCount = selections.length;
    
    return [
      // Specific goal indicators
      FeatureContribution('goal_lose_weight', selections.contains('lose_weight') ? 1.0 : 0.0),
      FeatureContribution('goal_build_muscle', selections.contains('build_muscle') ? 1.0 : 0.0),
      FeatureContribution('goal_improve_endurance', selections.contains('improve_endurance') ? 1.0 : 0.0),
      FeatureContribution('goal_increase_flexibility', selections.contains('increase_flexibility') ? 1.0 : 0.0),
      FeatureContribution('goal_better_health', selections.contains('better_health') ? 1.0 : 0.0),
      FeatureContribution('goal_live_longer', selections.contains('live_longer') ? 1.0 : 0.0),
      
      // Goal categorization
      FeatureContribution('aesthetic_goals', _hasAestheticGoals(selections) ? 1.0 : 0.0),
      FeatureContribution('performance_goals', _hasPerformanceGoals(selections) ? 1.0 : 0.0),
      FeatureContribution('health_goals', _hasHealthGoals(selections) ? 1.0 : 0.0),
      FeatureContribution('longevity_goals', _hasLongevityGoals(selections) ? 1.0 : 0.0),
      
      // Program design implications
      FeatureContribution('needs_strength_training', _needsStrengthTraining(selections) ? 1.0 : 0.0),
      FeatureContribution('needs_cardio_training', _needsCardioTraining(selections) ? 1.0 : 0.0),
      FeatureContribution('needs_flexibility_training', selections.contains('increase_flexibility') ? 1.0 : 0.0),
      FeatureContribution('needs_weight_management', selections.contains('lose_weight') ? 1.0 : 0.0),
      
      // Training focus distribution
      FeatureContribution('strength_focus_weight', _getStrengthFocusWeight(selections)),
      FeatureContribution('cardio_focus_weight', _getCardioFocusWeight(selections)),
      FeatureContribution('flexibility_focus_weight', _getFlexibilityFocusWeight(selections)),
      
      // Goal complexity and commitment
      FeatureContribution('goal_complexity', goalCount / 3.0), // Normalize to 0-1
      FeatureContribution('focused_goals', goalCount == 1 ? 1.0 : 0.0),
      FeatureContribution('diverse_goals', goalCount == 3 ? 1.0 : 0.0),
      
      // Dietary considerations
      FeatureContribution('needs_nutrition_focus', selections.contains('lose_weight') ? 1.0 : 0.0),
      FeatureContribution('needs_protein_focus', selections.contains('build_muscle') ? 1.0 : 0.0),
      
      // Long-term sustainability
      FeatureContribution('sustainable_goals', _getSustainabilityScore(selections)),
      FeatureContribution('realistic_expectations', _getRealismScore(selections)),
      
      // Motivation alignment
      FeatureContribution('intrinsic_goal_motivation', _getIntrinsicMotivation(selections)),
      FeatureContribution('goal_achievement_likelihood', _getAchievementLikelihood(selections)),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is List) {
      final selections = answer.cast<String>();
      return selections.length >= 1 && 
             selections.length <= 3 && 
             selections.every((item) => _isValidOption(item));
    }
    return _isValidOption(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => ['better_health']; // Universal goal
  
  //MARK: PRIVATE HELPERS
  
  /// Check if selection is a valid option
  bool _isValidOption(String option) {
    final validOptions = [
      'lose_weight', 'build_muscle', 'improve_endurance',
      'increase_flexibility', 'better_health', 'live_longer'
    ];
    return validOptions.contains(option);
  }
  
  /// Check if user has aesthetic-focused goals
  bool _hasAestheticGoals(List<String> selections) {
    return selections.contains('lose_weight') || selections.contains('build_muscle');
  }
  
  /// Check if user has performance-focused goals
  bool _hasPerformanceGoals(List<String> selections) {
    return selections.contains('improve_endurance') || 
           selections.contains('increase_flexibility') || 
           selections.contains('build_muscle');
  }
  
  /// Check if user has health-focused goals
  bool _hasHealthGoals(List<String> selections) {
    return selections.contains('better_health') || selections.contains('lose_weight');
  }
  
  /// Check if user has longevity-focused goals
  bool _hasLongevityGoals(List<String> selections) {
    return selections.contains('live_longer') || selections.contains('better_health');
  }
  
  /// Check if goals require strength training
  bool _needsStrengthTraining(List<String> selections) {
    return selections.contains('build_muscle') || 
           selections.contains('better_health') ||
           selections.contains('live_longer');
  }
  
  /// Check if goals require cardio training
  bool _needsCardioTraining(List<String> selections) {
    return selections.contains('lose_weight') || 
           selections.contains('improve_endurance') ||
           selections.contains('better_health') ||
           selections.contains('live_longer');
  }
  
  /// Calculate strength training focus weight
  double _getStrengthFocusWeight(List<String> selections) {
    double weight = 0.0;
    if (selections.contains('build_muscle')) weight += 0.5;
    if (selections.contains('better_health')) weight += 0.2;
    if (selections.contains('live_longer')) weight += 0.2;
    if (selections.contains('lose_weight')) weight += 0.1; // Strength helps with weight loss
    return weight.clamp(0.0, 1.0);
  }
  
  /// Calculate cardio training focus weight
  double _getCardioFocusWeight(List<String> selections) {
    double weight = 0.0;
    if (selections.contains('lose_weight')) weight += 0.4;
    if (selections.contains('improve_endurance')) weight += 0.5;
    if (selections.contains('better_health')) weight += 0.3;
    if (selections.contains('live_longer')) weight += 0.3;
    return weight.clamp(0.0, 1.0);
  }
  
  /// Calculate flexibility training focus weight
  double _getFlexibilityFocusWeight(List<String> selections) {
    double weight = 0.0;
    if (selections.contains('increase_flexibility')) weight += 0.6;
    if (selections.contains('better_health')) weight += 0.2;
    if (selections.contains('live_longer')) weight += 0.3;
    return weight.clamp(0.0, 1.0);
  }
  
  /// Calculate goal sustainability score
  double _getSustainabilityScore(List<String> selections) {
    double score = 0.0;
    final weights = {
      'better_health': 0.3,
      'live_longer': 0.3,
      'improve_endurance': 0.2,
      'increase_flexibility': 0.2,
      'build_muscle': 0.15,
      'lose_weight': 0.1, // Can be challenging to sustain
    };
    
    for (final selection in selections) {
      score += weights[selection] ?? 0.0;
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  /// Calculate goal realism score
  double _getRealismScore(List<String> selections) {
    // Fewer, more specific goals tend to be more realistic
    if (selections.length == 1) return 1.0;
    if (selections.length == 2) return 0.8;
    return 0.6; // 3 goals can be ambitious
  }
  
  /// Calculate intrinsic motivation level
  double _getIntrinsicMotivation(List<String> selections) {
    double score = 0.0;
    final intrinsicWeights = {
      'better_health': 0.3,
      'live_longer': 0.3,
      'improve_endurance': 0.2,
      'increase_flexibility': 0.2,
      'build_muscle': 0.1,
      'lose_weight': 0.05, // Often more extrinsic
    };
    
    for (final selection in selections) {
      score += intrinsicWeights[selection] ?? 0.0;
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  /// Calculate goal achievement likelihood
  double _getAchievementLikelihood(List<String> selections) {
    double score = 0.0;
    final achievabilityWeights = {
      'increase_flexibility': 0.3, // Relatively achievable
      'improve_endurance': 0.25,
      'better_health': 0.25,
      'build_muscle': 0.2,
      'live_longer': 0.15, // Long-term, harder to measure
      'lose_weight': 0.1, // High failure rate
    };
    
    for (final selection in selections) {
      score += achievabilityWeights[selection] ?? 0.0;
    }
    
    return score.clamp(0.0, 1.0);
  }
}