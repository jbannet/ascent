import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../fitness_profile_model/feature_contribution.dart';

/// Primary motivation question for understanding user's core fitness drivers.
/// 
/// This question identifies what primarily motivates the user to exercise,
/// which influences program design, messaging, and progress tracking preferences.
class PrimaryMotivationQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'primary_motivation';
  
  @override
  String get questionText => 'What motivates you most to exercise?';
  
  @override
  String get section => 'motivation';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: 'physical_changes',
      label: 'Seeing physical changes in my body',
      description: 'Visual progress through photos and measurements',
    ),
    QuestionOption(
      value: 'feeling_stronger',
      label: 'Feeling stronger and more energetic',
      description: 'Focus on how exercise makes you feel',
    ),
    QuestionOption(
      value: 'performance_goals',
      label: 'Achieving specific performance goals',
      description: 'Hitting targets like running times or lifting weights',
    ),
    QuestionOption(
      value: 'social_connection',
      label: 'Social connection and community',
      description: 'Working out with others and group activities',
    ),
    QuestionOption(
      value: 'stress_relief',
      label: 'Stress relief and mental health',
      description: 'Using exercise to manage stress and mood',
    ),
    QuestionOption(
      value: 'health_longevity',
      label: 'Health and longevity',
      description: 'Long-term health benefits and disease prevention',
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final motivation = answer.toString();
    
    return [
      // Primary motivation indicators
      FeatureContribution('motivation_physical_changes', motivation == 'physical_changes' ? 1.0 : 0.0),
      FeatureContribution('motivation_feeling_stronger', motivation == 'feeling_stronger' ? 1.0 : 0.0),
      FeatureContribution('motivation_performance', motivation == 'performance_goals' ? 1.0 : 0.0),
      FeatureContribution('motivation_social', motivation == 'social_connection' ? 1.0 : 0.0),
      FeatureContribution('motivation_stress_relief', motivation == 'stress_relief' ? 1.0 : 0.0),
      FeatureContribution('motivation_health', motivation == 'health_longevity' ? 1.0 : 0.0),
      
      // Program design implications
      FeatureContribution('prefers_aesthetic_focus', _isAestheticFocused(motivation) ? 1.0 : 0.0),
      FeatureContribution('prefers_performance_focus', _isPerformanceFocused(motivation) ? 1.0 : 0.0),
      FeatureContribution('prefers_wellness_focus', _isWellnessFocused(motivation) ? 1.0 : 0.0),
      
      // Progress tracking preferences
      FeatureContribution('values_visual_progress', motivation == 'physical_changes' ? 1.0 : 0.0),
      FeatureContribution('values_performance_metrics', motivation == 'performance_goals' ? 1.0 : 0.0),
      FeatureContribution('values_subjective_measures', _valuesSubjective(motivation) ? 1.0 : 0.0),
      
      // Social and community preferences
      FeatureContribution('prefers_group_activities', motivation == 'social_connection' ? 1.0 : 0.0),
      FeatureContribution('prefers_individual_training', motivation != 'social_connection' ? 1.0 : 0.0),
      
      // Messaging and communication style
      FeatureContribution('responds_to_achievement_messaging', _respondsToAchievement(motivation) ? 1.0 : 0.0),
      FeatureContribution('responds_to_health_messaging', _respondsToHealth(motivation) ? 1.0 : 0.0),
      FeatureContribution('responds_to_emotional_messaging', _respondsToEmotional(motivation) ? 1.0 : 0.0),
      
      // Long-term commitment indicators
      FeatureContribution('intrinsic_motivation_level', _getIntrinsicMotivation(motivation)),
      FeatureContribution('sustainability_likelihood', _getSustainability(motivation)),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = [
      'physical_changes', 'feeling_stronger', 'performance_goals',
      'social_connection', 'stress_relief', 'health_longevity'
    ];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'health_longevity'; // Health is a universal motivator
  
  //MARK: PRIVATE HELPERS
  
  /// Check if motivation is primarily aesthetic-focused
  bool _isAestheticFocused(String motivation) {
    return motivation == 'physical_changes';
  }
  
  /// Check if motivation is performance-focused
  bool _isPerformanceFocused(String motivation) {
    return ['performance_goals', 'feeling_stronger'].contains(motivation);
  }
  
  /// Check if motivation is wellness-focused
  bool _isWellnessFocused(String motivation) {
    return ['health_longevity', 'stress_relief'].contains(motivation);
  }
  
  /// Check if motivation values subjective measures
  bool _valuesSubjective(String motivation) {
    return ['feeling_stronger', 'stress_relief', 'health_longevity'].contains(motivation);
  }
  
  /// Check if motivation responds to achievement messaging
  bool _respondsToAchievement(String motivation) {
    return ['performance_goals', 'physical_changes'].contains(motivation);
  }
  
  /// Check if motivation responds to health messaging
  bool _respondsToHealth(String motivation) {
    return ['health_longevity', 'feeling_stronger'].contains(motivation);
  }
  
  /// Check if motivation responds to emotional messaging
  bool _respondsToEmotional(String motivation) {
    return ['stress_relief', 'social_connection', 'feeling_stronger'].contains(motivation);
  }
  
  /// Calculate intrinsic motivation level
  double _getIntrinsicMotivation(String motivation) {
    switch (motivation) {
      case 'feeling_stronger':
      case 'stress_relief':
      case 'health_longevity':
        return 1.0; // High intrinsic motivation
      case 'performance_goals':
        return 0.7; // Moderate intrinsic motivation
      case 'physical_changes':
        return 0.5; // Mixed intrinsic/extrinsic
      case 'social_connection':
        return 0.4; // More extrinsic
      default:
        return 0.5;
    }
  }
  
  /// Calculate sustainability likelihood
  double _getSustainability(String motivation) {
    switch (motivation) {
      case 'health_longevity':
      case 'stress_relief':
        return 1.0; // Highly sustainable motivations
      case 'feeling_stronger':
        return 0.9; // Very sustainable
      case 'performance_goals':
        return 0.7; // Moderately sustainable
      case 'social_connection':
        return 0.6; // Depends on social factors
      case 'physical_changes':
        return 0.5; // Can plateau or become discouraging
      default:
        return 0.5;
    }
  }
}