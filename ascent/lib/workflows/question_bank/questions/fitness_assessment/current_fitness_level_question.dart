import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../models/fitness_profile_model/feature_contribution.dart';

/// Current fitness level self-assessment question.
/// 
/// This question helps establish baseline fitness level for program selection
/// and progression planning.
class CurrentFitnessLevelQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'current_fitness_level';
  
  @override
  String get questionText => 'What is your current fitness level?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: 'beginner',
      label: 'Beginner',
      description: 'Little to no regular exercise',
    ),
    QuestionOption(
      value: 'intermediate',
      label: 'Intermediate',
      description: 'Exercise 1-3 times per week',
    ),
    QuestionOption(
      value: 'advanced',
      label: 'Advanced',
      description: 'Exercise 4-6 times per week',
    ),
    QuestionOption(
      value: 'expert',
      label: 'Expert',
      description: 'Daily training routine',
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final level = answer.toString();
    final levelScore = _getLevelScore(level);
    
    return [
      // Fitness level indicators
      FeatureContribution('is_beginner', level == 'beginner' ? 1.0 : 0.0),
      FeatureContribution('is_intermediate', level == 'intermediate' ? 1.0 : 0.0),
      FeatureContribution('is_advanced', level == 'advanced' ? 1.0 : 0.0),
      FeatureContribution('is_expert', level == 'expert' ? 1.0 : 0.0),
      
      // Normalized fitness level (0-1 scale)
      FeatureContribution('fitness_level_score', levelScore),
      FeatureContribution('baseline_fitness', levelScore),
      
      // Program complexity readiness
      FeatureContribution('basic_program_suitable', level == 'beginner' ? 1.0 : 0.0),
      FeatureContribution('intermediate_program_suitable', ['intermediate', 'advanced', 'expert'].contains(level) ? 1.0 : 0.0),
      FeatureContribution('advanced_program_suitable', ['advanced', 'expert'].contains(level) ? 1.0 : 0.0),
      FeatureContribution('expert_program_suitable', level == 'expert' ? 1.0 : 0.0),
      
      // Training intensity readiness
      FeatureContribution('low_intensity_appropriate', ['beginner', 'intermediate'].contains(level) ? 1.0 : 0.0),
      FeatureContribution('moderate_intensity_ready', ['intermediate', 'advanced', 'expert'].contains(level) ? 1.0 : 0.0),
      FeatureContribution('high_intensity_ready', ['advanced', 'expert'].contains(level) ? 1.0 : 0.0),
      
      // Volume and frequency implications
      FeatureContribution('training_volume_capacity', _getVolumeCapacity(level)),
      FeatureContribution('training_frequency_capacity', _getFrequencyCapacity(level)),
      
      // Progression rate expectations
      FeatureContribution('rapid_progression_potential', level == 'beginner' ? 1.0 : 0.0),
      FeatureContribution('steady_progression_expected', ['intermediate', 'advanced'].contains(level) ? 1.0 : 0.0),
      FeatureContribution('slow_progression_expected', level == 'expert' ? 1.0 : 0.0),
      
      // Support and guidance needs
      FeatureContribution('needs_basic_instruction', level == 'beginner' ? 1.0 : 0.0),
      FeatureContribution('needs_moderate_guidance', level == 'intermediate' ? 1.0 : 0.0),
      FeatureContribution('mostly_independent', ['advanced', 'expert'].contains(level) ? 1.0 : 0.0),
      
      // Injury risk considerations
      FeatureContribution('injury_risk_inexperience', level == 'beginner' ? 0.8 : 0.2),
      FeatureContribution('injury_risk_overconfidence', level == 'expert' ? 0.6 : 0.3),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validLevels = ['beginner', 'intermediate', 'advanced', 'expert'];
    return validLevels.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'beginner'; // Conservative default
  
  //MARK: PRIVATE HELPERS
  
  /// Convert fitness level to numerical score
  double _getLevelScore(String level) {
    switch (level) {
      case 'beginner':
        return 0.25;
      case 'intermediate':
        return 0.5;
      case 'advanced':
        return 0.75;
      case 'expert':
        return 1.0;
      default:
        return 0.25;
    }
  }
  
  /// Calculate training volume capacity
  double _getVolumeCapacity(String level) {
    switch (level) {
      case 'beginner':
        return 0.3;  // Low volume to start
      case 'intermediate':
        return 0.6;  // Moderate volume
      case 'advanced':
        return 0.8;  // High volume
      case 'expert':
        return 1.0;  // Maximum volume capacity
      default:
        return 0.3;
    }
  }
  
  /// Calculate training frequency capacity
  double _getFrequencyCapacity(String level) {
    switch (level) {
      case 'beginner':
        return 0.4;  // 2-3 days per week
      case 'intermediate':
        return 0.6;  // 3-4 days per week
      case 'advanced':
        return 0.8;  // 4-5 days per week
      case 'expert':
        return 1.0;  // 6-7 days per week
      default:
        return 0.4;
    }
  }
}