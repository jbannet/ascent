import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../models/fitness_profile_model/feature_contribution.dart';

/// Q2: Are there any activities you should avoid due to medical advice?
/// 
/// This question identifies medical restrictions that limit exercise types.
/// It contributes to exercise safety and modification features.
class Q2HighImpactQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q2';
  
  @override
  String get questionText => 'Are there any activities you should avoid due to medical advice?';
  
  @override
  String get section => 'practical_constraints';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Select all that apply';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'none', label: 'No restrictions'),
    QuestionOption(value: 'high_impact', label: 'High-impact activities (jumping, running)'),
    QuestionOption(value: 'heavy_lifting', label: 'Heavy lifting or straining'),
    QuestionOption(value: 'overhead', label: 'Overhead movements'),
    QuestionOption(value: 'twisting', label: 'Twisting or rotating motions'),
    QuestionOption(value: 'balance', label: 'Balance-challenging exercises'),
    QuestionOption(value: 'cardio_intense', label: 'Intense cardiovascular exercise'),
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
    
    final hasRestrictions = !selections.contains('none');
    final restrictionCount = hasRestrictions ? selections.length : 0;
    
    return [
      // Overall medical restriction level
      FeatureContribution('medical_restrictions', hasRestrictions ? 1.0 : 0.0),
      
      // Specific activity restrictions
      FeatureContribution('high_impact_restricted', selections.contains('high_impact') ? 1.0 : 0.0),
      FeatureContribution('heavy_lifting_restricted', selections.contains('heavy_lifting') ? 1.0 : 0.0),
      FeatureContribution('overhead_restricted', selections.contains('overhead') ? 1.0 : 0.0),
      FeatureContribution('twisting_restricted', selections.contains('twisting') ? 1.0 : 0.0),
      FeatureContribution('balance_restricted', selections.contains('balance') ? 1.0 : 0.0),
      FeatureContribution('cardio_restricted', selections.contains('cardio_intense') ? 1.0 : 0.0),
      
      // Exercise selection constraints
      FeatureContribution('exercise_variety_factor', _calculateVarietyFactor(selections)),
      
      // Training approach modifications
      FeatureContribution('requires_low_impact', selections.contains('high_impact') ? 1.0 : 0.0),
      FeatureContribution('requires_light_weights', selections.contains('heavy_lifting') ? 1.0 : 0.0),
      
      // Safety supervision needs
      FeatureContribution('supervision_recommended', _calculateSupervisionNeed(restrictionCount)),
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
  dynamic getDefaultAnswer() => ['none']; // Default to no restrictions
  
  //MARK: PRIVATE HELPERS
  
  /// Calculate exercise variety limitation factor
  double _calculateVarietyFactor(List<String> selections) {
    if (selections.contains('none')) return 1.0; // Full variety available
    
    // Each restriction reduces available variety
    final restrictionPenalty = selections.length * 0.15;
    return (1.0 - restrictionPenalty).clamp(0.2, 1.0); // Keep minimum 20% variety
  }
  
  /// Calculate need for professional supervision
  double _calculateSupervisionNeed(int restrictionCount) {
    if (restrictionCount == 0) return 0.0;
    if (restrictionCount >= 3) return 1.0; // Multiple restrictions need supervision
    return restrictionCount / 3.0; // Scale with number of restrictions
  }
}