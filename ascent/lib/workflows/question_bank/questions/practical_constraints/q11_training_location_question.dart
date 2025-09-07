import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../models/fitness_profile_model/feature_contribution.dart';

/// Q11: Where do you prefer to train?
/// 
/// This question assesses training location preferences and constraints.
/// It contributes to program design, exercise selection, and adherence features.
class Q11TrainingLocationQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q11';
  
  @override
  String get questionText => 'Where do you prefer to train?';
  
  @override
  String get section => 'practical_constraints';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Choose your most preferred option';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'home_only', label: 'At home only'),
    QuestionOption(value: 'gym_only', label: 'At the gym only'),
    QuestionOption(value: 'prefer_home', label: 'Prefer home but flexible'),
    QuestionOption(value: 'prefer_gym', label: 'Prefer gym but flexible'),
    QuestionOption(value: 'outdoors', label: 'Outdoors when possible'),
    QuestionOption(value: 'anywhere', label: 'Anywhere is fine'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final location = answer.toString();
    final flexibility = _calculateLocationFlexibility(location);
    
    return [
      // Location preferences and constraints
      FeatureContribution('location_flexibility', flexibility),
      FeatureContribution('prefers_home_training', _prefersHome(location) ? 1.0 : 0.0),
      FeatureContribution('prefers_gym_training', _prefersGym(location) ? 1.0 : 0.0),
      FeatureContribution('prefers_outdoor_training', location == 'outdoors' ? 1.0 : 0.0),
      
      // Program design implications
      FeatureContribution('home_program_suitable', _isHomeSuitable(location) ? 1.0 : 0.0),
      FeatureContribution('gym_program_suitable', _isGymSuitable(location) ? 1.0 : 0.0),
      FeatureContribution('outdoor_program_suitable', _isOutdoorSuitable(location) ? 1.0 : 0.0),
      
      // Equipment and space considerations
      FeatureContribution('space_constraints', _calculateSpaceConstraints(location)),
      FeatureContribution('equipment_dependency', _calculateEquipmentDependency(location)),
      FeatureContribution('minimal_equipment_preferred', _prefersMinimalEquipment(location) ? 1.0 : 0.0),
      
      // Social and motivation factors
      FeatureContribution('social_training_preference', _calculateSocialPreference(location)),
      FeatureContribution('privacy_preference', _calculatePrivacyPreference(location)),
      FeatureContribution('external_motivation_need', _calculateMotivationNeed(location)),
      
      // Adherence and convenience factors
      FeatureContribution('convenience_priority', _calculateConveniencePriority(location)),
      FeatureContribution('schedule_flexibility_need', flexibility),
      FeatureContribution('commute_barrier_factor', _calculateCommuteBarrier(location)),
      
      // Environmental preferences
      FeatureContribution('natural_environment_preference', location == 'outdoors' ? 1.0 : 0.0),
      FeatureContribution('controlled_environment_preference', _prefersControlledEnvironment(location) ? 1.0 : 0.0),
      
      // Training style implications
      FeatureContribution('structured_gym_style', _prefersGym(location) ? 1.0 : 0.0),
      FeatureContribution('flexible_adaptive_style', flexibility),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['home_only', 'gym_only', 'prefer_home', 'prefer_gym', 'outdoors', 'anywhere'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'anywhere'; // Most flexible default
  
  //MARK: PRIVATE HELPERS
  
  /// Calculate location flexibility score
  double _calculateLocationFlexibility(String location) {
    switch (location) {
      case 'anywhere':
        return 1.0;
      case 'prefer_home':
      case 'prefer_gym':
        return 0.8;
      case 'outdoors':
        return 0.6;
      case 'home_only':
      case 'gym_only':
        return 0.2;
      default:
        return 0.5;
    }
  }
  
  /// Check if location preference includes home training
  bool _prefersHome(String location) {
    return ['home_only', 'prefer_home', 'anywhere'].contains(location);
  }
  
  /// Check if location preference includes gym training
  bool _prefersGym(String location) {
    return ['gym_only', 'prefer_gym', 'anywhere'].contains(location);
  }
  
  /// Check if home training is suitable
  bool _isHomeSuitable(String location) {
    return ['home_only', 'prefer_home', 'anywhere'].contains(location);
  }
  
  /// Check if gym training is suitable
  bool _isGymSuitable(String location) {
    return ['gym_only', 'prefer_gym', 'anywhere'].contains(location);
  }
  
  /// Check if outdoor training is suitable
  bool _isOutdoorSuitable(String location) {
    return ['outdoors', 'anywhere'].contains(location);
  }
  
  /// Calculate space constraint level
  double _calculateSpaceConstraints(String location) {
    switch (location) {
      case 'home_only':
        return 0.8; // Home space typically more limited
      case 'gym_only':
        return 0.1; // Gym has ample space
      case 'prefer_home':
        return 0.6;
      case 'prefer_gym':
        return 0.3;
      case 'outdoors':
        return 0.2; // Outdoor space is typically ample
      case 'anywhere':
        return 0.4; // Average constraints
      default:
        return 0.5;
    }
  }
  
  /// Calculate equipment dependency
  double _calculateEquipmentDependency(String location) {
    switch (location) {
      case 'gym_only':
        return 1.0; // High dependency on gym equipment
      case 'prefer_gym':
        return 0.7;
      case 'home_only':
        return 0.3; // Limited to home equipment
      case 'prefer_home':
        return 0.4;
      case 'outdoors':
        return 0.1; // Minimal equipment dependency
      case 'anywhere':
        return 0.5; // Moderate dependency
      default:
        return 0.5;
    }
  }
  
  /// Check if minimal equipment is preferred
  bool _prefersMinimalEquipment(String location) {
    return ['home_only', 'outdoors'].contains(location);
  }
  
  /// Calculate social training preference
  double _calculateSocialPreference(String location) {
    switch (location) {
      case 'gym_only':
        return 0.8; // Gyms are social environments
      case 'prefer_gym':
        return 0.6;
      case 'home_only':
        return 0.1; // Solo training
      case 'prefer_home':
        return 0.3;
      case 'outdoors':
        return 0.4; // Can be social or solo
      case 'anywhere':
        return 0.5; // Neutral
      default:
        return 0.5;
    }
  }
  
  /// Calculate privacy preference
  double _calculatePrivacyPreference(String location) {
    // Inverse of social preference
    return 1.0 - _calculateSocialPreference(location);
  }
  
  /// Calculate need for external motivation
  double _calculateMotivationNeed(String location) {
    switch (location) {
      case 'gym_only':
        return 0.3; // Gym environment provides motivation
      case 'prefer_gym':
        return 0.4;
      case 'home_only':
        return 0.8; // Higher self-motivation needed
      case 'prefer_home':
        return 0.6;
      case 'outdoors':
        return 0.5; // Natural environment can be motivating
      case 'anywhere':
        return 0.5; // Neutral
      default:
        return 0.5;
    }
  }
  
  /// Calculate convenience priority level
  double _calculateConveniencePriority(String location) {
    switch (location) {
      case 'home_only':
        return 1.0; // Maximum convenience priority
      case 'prefer_home':
        return 0.8;
      case 'anywhere':
        return 0.7; // Values convenience
      case 'outdoors':
        return 0.6;
      case 'prefer_gym':
        return 0.4;
      case 'gym_only':
        return 0.2; // Willing to travel for gym benefits
      default:
        return 0.5;
    }
  }
  
  /// Calculate commute barrier factor
  double _calculateCommuteBarrier(String location) {
    switch (location) {
      case 'home_only':
        return 1.0; // High barrier to traveling
      case 'prefer_home':
        return 0.6;
      case 'gym_only':
        return 0.1; // Low barrier, accepts commute
      case 'prefer_gym':
        return 0.3;
      case 'outdoors':
        return 0.4; // Depends on outdoor access
      case 'anywhere':
        return 0.2; // Very low barrier
      default:
        return 0.5;
    }
  }
  
  /// Check if controlled environment is preferred
  bool _prefersControlledEnvironment(String location) {
    return ['home_only', 'gym_only', 'prefer_home', 'prefer_gym'].contains(location);
  }
}