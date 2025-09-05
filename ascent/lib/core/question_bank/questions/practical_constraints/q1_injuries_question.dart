import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Q1: Do you have any current injuries or physical limitations?
/// 
/// This question assesses safety constraints that affect exercise selection.
/// It contributes to injury risk and exercise modification features.
class Q1InjuriesQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q1';
  
  @override
  String get questionText => 'Do you have any current injuries or physical limitations?';
  
  @override
  String get section => 'practical_constraints';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Select all that apply';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'none', label: 'None'),
    QuestionOption(value: 'back', label: 'Back problems'),
    QuestionOption(value: 'knee', label: 'Knee problems'),
    QuestionOption(value: 'shoulder', label: 'Shoulder problems'),
    QuestionOption(value: 'wrist_ankle', label: 'Wrist/ankle problems'),
    QuestionOption(value: 'other', label: 'Other limitations'),
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
    
    // Calculate injury risk and modification needs
    final hasInjuries = !selections.contains('none');
    final injuryCount = hasInjuries ? selections.length : 0;
    final riskLevel = _calculateRiskLevel(selections);
    
    return [
      // Primary injury risk indicator
      FeatureContribution('injury_risk_level', riskLevel),
      
      // Exercise modification requirements
      FeatureContribution('requires_modifications', hasInjuries ? 1.0 : 0.0),
      
      // Specific body region risks
      FeatureContribution('back_risk', selections.contains('back') ? 1.0 : 0.0),
      FeatureContribution('knee_risk', selections.contains('knee') ? 1.0 : 0.0),
      FeatureContribution('shoulder_risk', selections.contains('shoulder') ? 1.0 : 0.0),
      FeatureContribution('wrist_ankle_risk', selections.contains('wrist_ankle') ? 1.0 : 0.0),
      
      // Training intensity limiter
      FeatureContribution('max_intensity_factor', _calculateIntensityFactor(riskLevel)),
      
      // Exercise selection constraints
      FeatureContribution('exercise_restrictions', injuryCount / 5.0), // Normalize to 0-1
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
  dynamic getDefaultAnswer() => ['none']; // Default to no injuries
  
  //MARK: PRIVATE HELPERS
  
  /// Calculate overall injury risk level based on selections
  double _calculateRiskLevel(List<String> selections) {
    if (selections.contains('none')) return 0.0;
    
    // Weight different injury types
    double risk = 0.0;
    if (selections.contains('back')) risk += 0.4; // Back injuries are high risk
    if (selections.contains('knee')) risk += 0.3; // Knee injuries limit many exercises
    if (selections.contains('shoulder')) risk += 0.25; // Shoulder affects upper body
    if (selections.contains('wrist_ankle')) risk += 0.15; // Less limiting but still important
    if (selections.contains('other')) risk += 0.2; // Unknown risk
    
    return (risk > 1.0) ? 1.0 : risk; // Cap at 1.0
  }
  
  /// Calculate intensity limitation factor
  double _calculateIntensityFactor(double riskLevel) {
    // Higher risk = lower max intensity
    return 1.0 - (riskLevel * 0.3); // Reduce max intensity by up to 30%
  }
}