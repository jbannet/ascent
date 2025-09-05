import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Q10: What equipment do you have access to?
/// 
/// This question assesses available equipment for exercise selection and program design.
/// It contributes to exercise filtering, program complexity, and equipment preference features.
class Q10EquipmentQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q10';
  
  @override
  String get questionText => 'What equipment do you have access to?';
  
  @override
  String get section => 'practical_constraints';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Select all that apply';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'none', label: 'No equipment (bodyweight only)'),
    QuestionOption(value: 'dumbbells', label: 'Dumbbells'),
    QuestionOption(value: 'resistance_bands', label: 'Resistance bands'),
    QuestionOption(value: 'barbell', label: 'Barbell and weights'),
    QuestionOption(value: 'cable_machine', label: 'Cable machine'),
    QuestionOption(value: 'cardio_machines', label: 'Cardio machines (treadmill, bike, etc.)'),
    QuestionOption(value: 'full_gym', label: 'Full gym access'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final selections = answer is List ? answer.cast<String>() : [answer.toString()];
    final equipmentScore = _calculateEquipmentScore(selections);
    
    return [
      // Equipment availability and variety
      FeatureContribution('equipment_availability', equipmentScore),
      FeatureContribution('equipment_variety', selections.length / 7.0), // Normalize by max options
      
      // Specific equipment access
      FeatureContribution('has_dumbbells', selections.contains('dumbbells') ? 1.0 : 0.0),
      FeatureContribution('has_barbell', selections.contains('barbell') ? 1.0 : 0.0),
      FeatureContribution('has_resistance_bands', selections.contains('resistance_bands') ? 1.0 : 0.0),
      FeatureContribution('has_cable_machine', selections.contains('cable_machine') ? 1.0 : 0.0),
      FeatureContribution('has_cardio_machines', selections.contains('cardio_machines') ? 1.0 : 0.0),
      FeatureContribution('has_full_gym', selections.contains('full_gym') ? 1.0 : 0.0),
      
      // Training style implications
      FeatureContribution('bodyweight_only', selections.contains('none') ? 1.0 : 0.0),
      FeatureContribution('home_training_suitable', _calculateHomeTraining(selections)),
      FeatureContribution('gym_training_available', selections.contains('full_gym') ? 1.0 : 0.0),
      
      // Exercise selection constraints
      FeatureContribution('strength_training_capability', _calculateStrengthCapability(selections)),
      FeatureContribution('cardio_training_capability', _calculateCardioCapability(selections)),
      FeatureContribution('exercise_variety_factor', _calculateVarietyFactor(selections)),
      
      // Progressive overload potential
      FeatureContribution('progressive_overload_capability', _calculateProgressiveOverload(selections)),
      FeatureContribution('weight_progression_available', _hasWeightProgression(selections) ? 1.0 : 0.0),
      
      // Program complexity readiness
      FeatureContribution('complex_programs_feasible', equipmentScore > 0.5 ? 1.0 : 0.0),
      FeatureContribution('equipment_limitations', 1.0 - equipmentScore), // Inverse relationship
      
      // Training efficiency
      FeatureContribution('equipment_efficiency_factor', _calculateEfficiencyFactor(selections)),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is List) {
      return answer.isNotEmpty && answer.every((item) => item is String);
    }
    return answer is String && answer.isNotEmpty;
  }
  
  @override
  dynamic getDefaultAnswer() => ['none']; // Default to bodyweight only
  
  //MARK: PRIVATE HELPERS
  
  /// Calculate overall equipment availability score
  double _calculateEquipmentScore(List<String> selections) {
    if (selections.contains('full_gym')) return 1.0; // Best possible
    
    double score = 0.0;
    if (selections.contains('none')) return 0.3; // Bodyweight training is still valuable
    if (selections.contains('resistance_bands')) score += 0.2;
    if (selections.contains('dumbbells')) score += 0.3;
    if (selections.contains('barbell')) score += 0.4;
    if (selections.contains('cable_machine')) score += 0.3;
    if (selections.contains('cardio_machines')) score += 0.2;
    
    return score.clamp(0.0, 1.0);
  }
  
  /// Calculate suitability for home training
  double _calculateHomeTraining(List<String> selections) {
    if (selections.contains('full_gym')) return 0.3; // Gym-dependent
    if (selections.contains('none')) return 1.0; // Perfect for home
    
    // Portable/home equipment gets high score
    double homeScore = 0.0;
    if (selections.contains('resistance_bands')) homeScore += 0.4;
    if (selections.contains('dumbbells')) homeScore += 0.3;
    if (selections.contains('barbell')) homeScore += 0.2; // Less convenient at home
    if (selections.contains('cable_machine')) homeScore += 0.1; // Usually gym equipment
    
    return homeScore.clamp(0.0, 1.0);
  }
  
  /// Calculate strength training capability
  double _calculateStrengthCapability(List<String> selections) {
    if (selections.contains('full_gym')) return 1.0;
    if (selections.contains('barbell')) return 0.9;
    if (selections.contains('dumbbells')) return 0.8;
    if (selections.contains('cable_machine')) return 0.7;
    if (selections.contains('resistance_bands')) return 0.6;
    if (selections.contains('none')) return 0.4; // Bodyweight can build strength
    return 0.4;
  }
  
  /// Calculate cardio training capability
  double _calculateCardioCapability(List<String> selections) {
    if (selections.contains('cardio_machines')) return 1.0;
    if (selections.contains('full_gym')) return 1.0;
    return 0.7; // Bodyweight cardio is always possible
  }
  
  /// Calculate exercise variety factor
  double _calculateVarietyFactor(List<String> selections) {
    if (selections.contains('full_gym')) return 1.0;
    
    // Count unique exercise types possible
    int varietyTypes = 0;
    if (selections.contains('none')) varietyTypes += 1; // Bodyweight variety
    if (selections.contains('dumbbells')) varietyTypes += 2; // High variety
    if (selections.contains('barbell')) varietyTypes += 2; // High variety
    if (selections.contains('resistance_bands')) varietyTypes += 1;
    if (selections.contains('cable_machine')) varietyTypes += 2;
    if (selections.contains('cardio_machines')) varietyTypes += 1;
    
    return (varietyTypes / 6.0).clamp(0.0, 1.0);
  }
  
  /// Calculate progressive overload capability
  double _calculateProgressiveOverload(List<String> selections) {
    if (selections.contains('full_gym') || selections.contains('barbell') || selections.contains('dumbbells')) {
      return 1.0; // Easy weight progression
    }
    if (selections.contains('cable_machine')) return 0.8;
    if (selections.contains('resistance_bands')) return 0.6; // Limited progression
    if (selections.contains('none')) return 0.4; // Bodyweight progression is challenging
    return 0.4;
  }
  
  /// Check if weight progression is available
  bool _hasWeightProgression(List<String> selections) {
    return selections.any((item) => 
      ['dumbbells', 'barbell', 'cable_machine', 'full_gym'].contains(item));
  }
  
  /// Calculate equipment efficiency factor
  double _calculateEfficiencyFactor(List<String> selections) {
    if (selections.contains('full_gym')) return 0.9; // Lots of options but maybe overwhelming
    if (selections.contains('dumbbells')) return 1.0; // Very efficient
    if (selections.contains('resistance_bands')) return 0.9; // Efficient and portable
    if (selections.contains('none')) return 0.8; // Simple and efficient
    return 0.7;
  }
}