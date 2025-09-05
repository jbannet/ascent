import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Height demographic question for body composition and biomechanical considerations.
/// 
/// Height is used for BMI calculations, body composition estimates,
/// and biomechanical exercise modifications.
class HeightQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'height';
  
  @override
  String get questionText => 'What is your height?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'Enter height in centimeters (e.g., 175 cm)';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 100.0,  // Minimum realistic height
    'maxValue': 250.0,  // Maximum realistic height
    'allowDecimals': false,
    'unit': 'cm',
    'placeholder': '175',
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final heightCm = (answer as num).toDouble();
    final heightCategory = _getHeightCategory(heightCm);
    
    return [
      // Raw height for calculations
      FeatureContribution('height_cm', heightCm / 200.0), // Normalize around average height
      FeatureContribution('height_raw', heightCm),
      
      // Height categories for exercise modifications
      FeatureContribution('is_very_short', heightCategory == 'very_short' ? 1.0 : 0.0),
      FeatureContribution('is_short', heightCategory == 'short' ? 1.0 : 0.0),
      FeatureContribution('is_average_height', heightCategory == 'average' ? 1.0 : 0.0),
      FeatureContribution('is_tall', heightCategory == 'tall' ? 1.0 : 0.0),
      FeatureContribution('is_very_tall', heightCategory == 'very_tall' ? 1.0 : 0.0),
      
      // Biomechanical considerations
      FeatureContribution('leverage_factor', _calculateLeverageFactor(heightCm)),
      FeatureContribution('squat_depth_consideration', _getSquatConsideration(heightCm)),
      FeatureContribution('deadlift_range_factor', _getDeadliftFactor(heightCm)),
      
      // Exercise modifications needed
      FeatureContribution('requires_rom_modifications', _requiresROMModifications(heightCm) ? 1.0 : 0.0),
      FeatureContribution('bench_press_arch_factor', _getBenchArchFactor(heightCm)),
      FeatureContribution('overhead_mobility_challenge', _getOverheadChallenge(heightCm)),
      
      // Equipment considerations
      FeatureContribution('standard_equipment_suitable', _isStandardEquipmentSuitable(heightCm) ? 1.0 : 0.0),
      FeatureContribution('needs_equipment_adjustments', _needsEquipmentAdjustments(heightCm) ? 1.0 : 0.0),
      
      // Body composition factors (for BMI context when weight is available)
      FeatureContribution('bmi_height_component', heightCm / 10000.0), // For BMI calculation (kg/m²)
      
      // Training considerations
      FeatureContribution('cardio_efficiency_height', _getCardioEfficiency(heightCm)),
      FeatureContribution('strength_leverage_advantage', _getStrengthAdvantage(heightCm)),
      
      // Safety considerations
      FeatureContribution('fall_risk_height_factor', _getFallRiskFactor(heightCm)),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final height = answer.toDouble();
    return height >= 100 && height <= 250;
  }
  
  @override
  dynamic getDefaultAnswer() => 170; // Average height
  
  //MARK: PRIVATE HELPERS
  
  /// Get height category for different considerations
  String _getHeightCategory(double heightCm) {
    if (heightCm < 150) return 'very_short';
    if (heightCm < 165) return 'short';
    if (heightCm < 185) return 'average';
    if (heightCm < 200) return 'tall';
    return 'very_tall';
  }
  
  /// Calculate leverage factor for strength exercises
  double _calculateLeverageFactor(double heightCm) {
    // Shorter individuals typically have better leverage for strength
    // Normalized so average height (175cm) = 1.0
    final baseFactor = 200.0 / heightCm;
    return baseFactor.clamp(0.7, 1.4);
  }
  
  /// Get squat depth consideration factor
  double _getSquatConsideration(double heightCm) {
    // Taller individuals often need more mobility work for squat depth
    if (heightCm < 160) return 0.2; // Easy squat depth
    if (heightCm < 175) return 0.4; // Moderate consideration
    if (heightCm < 190) return 0.6; // More consideration needed
    return 0.8; // Significant mobility work may be needed
  }
  
  /// Get deadlift range of motion factor
  double _getDeadliftFactor(double heightCm) {
    // Taller individuals have longer range of motion for deadlifts
    if (heightCm < 160) return 0.6; // Shorter ROM, potentially easier
    if (heightCm < 175) return 0.8; // Moderate ROM
    if (heightCm < 190) return 1.0; // Standard ROM
    return 1.2; // Longer ROM, more challenging
  }
  
  /// Check if ROM modifications are needed
  bool _requiresROMModifications(double heightCm) {
    return heightCm < 150 || heightCm > 195;
  }
  
  /// Get bench press arch factor
  double _getBenchArchFactor(double heightCm) {
    // Shorter individuals can typically achieve better bench arch
    if (heightCm < 160) return 1.0; // Good arch potential
    if (heightCm < 175) return 0.8; // Moderate arch
    return 0.6; // Limited arch potential
  }
  
  /// Get overhead mobility challenge factor
  double _getOverheadChallenge(double heightCm) {
    // Taller individuals often have more overhead mobility challenges
    if (heightCm < 170) return 0.3; // Lower challenge
    if (heightCm < 185) return 0.5; // Moderate challenge
    return 0.7; // Higher challenge
  }
  
  /// Check if standard gym equipment is suitable
  bool _isStandardEquipmentSuitable(double heightCm) {
    return heightCm >= 150 && heightCm <= 195; // Standard equipment design range
  }
  
  /// Check if equipment adjustments are needed
  bool _needsEquipmentAdjustments(double heightCm) {
    return heightCm < 150 || heightCm > 195;
  }
  
  /// Calculate cardio efficiency based on height
  double _getCardioEfficiency(double heightCm) {
    // Moderate heights often most efficient for running
    // Very short or very tall may have efficiency challenges
    if (heightCm >= 160 && heightCm <= 180) return 1.0; // Optimal range
    if (heightCm >= 150 && heightCm <= 190) return 0.9; // Good range
    return 0.8; // May have some efficiency challenges
  }
  
  /// Calculate strength advantage based on leverage
  double _getStrengthAdvantage(double heightCm) {
    // Shorter lever arms generally provide strength advantages
    if (heightCm < 160) return 1.0; // High advantage
    if (heightCm < 175) return 0.8; // Moderate advantage
    if (heightCm < 190) return 0.6; // Slight disadvantage
    return 0.4; // Leverage disadvantage
  }
  
  /// Calculate fall risk factor based on height
  double _getFallRiskFactor(double heightCm) {
    // Taller individuals have higher center of gravity = higher fall risk
    if (heightCm < 160) return 0.3; // Lower fall risk
    if (heightCm < 175) return 0.5; // Moderate fall risk
    if (heightCm < 190) return 0.7; // Higher fall risk
    return 0.8; // Highest fall risk
  }
}