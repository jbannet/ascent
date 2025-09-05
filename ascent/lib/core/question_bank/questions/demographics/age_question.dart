import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Age demographic question for fitness assessment normalization.
/// 
/// Age is a critical factor for fitness norms, training intensity calculations,
/// and age-appropriate exercise recommendations.
class AgeQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'age';
  
  @override
  String get questionText => 'What is your age?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.numberInput;
  
  @override
  String? get subtitle => 'This helps us provide age-appropriate recommendations';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 13.0,
    'maxValue': 100.0,
    'allowDecimals': false,
    'unit': 'years',
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  void evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final age = (answer as num).toInt();
    
    // Store age in demographics
    demographics['age'] = age.toDouble();
    
    // Raw age for calculations
    features['age'] = age / 100.0; // Normalize to 0-1 scale
    features['age_raw'] = age.toDouble();
    
    // Age categories for different training considerations
    features['is_youth'] = age < 18 ? 1.0 : 0.0;
    features['is_young_adult'] = (age >= 18 && age < 30) ? 1.0 : 0.0;
    features['is_middle_aged'] = (age >= 30 && age < 50) ? 1.0 : 0.0;
    features['is_older_adult'] = (age >= 50 && age < 65) ? 1.0 : 0.0;
    features['is_senior'] = age >= 65 ? 1.0 : 0.0;
    
    // Training intensity considerations
    features['max_heart_rate_factor'] = _calculateMaxHRFactor(age);
    features['recovery_adjustment_factor'] = _calculateRecoveryFactor(age);
    features['intensity_tolerance'] = _calculateIntensityTolerance(age);
    
    // Risk and safety considerations
    features['injury_risk_age_factor'] = _calculateInjuryRiskFactor(age);
    features['requires_medical_clearance'] = age >= 50 ? 1.0 : 0.0;
    features['bone_density_concern'] = (age >= 30) ? ((age - 30) / 70.0) : 0.0;
    
    // Program design considerations
    features['prefers_low_impact'] = age >= 60 ? 1.0 : 0.0;
    features['mobility_priority'] = age >= 40 ? ((age - 40) / 60.0).clamp(0.0, 1.0) : 0.0;
    features['balance_training_importance'] = age >= 50 ? ((age - 50) / 50.0).clamp(0.0, 1.0) : 0.0;
    
    // Metabolic considerations
    features['metabolic_rate_factor'] = _calculateMetabolicFactor(age);
    features['muscle_preservation_priority'] = age >= 35 ? 1.0 : 0.0;
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is! num) return false;
    final age = answer.toInt();
    return age >= 13 && age <= 100;
  }
  
  @override
  dynamic getDefaultAnswer() => 35; // Default adult age
  
  //MARK: PRIVATE HELPERS
  
  /// Calculate max heart rate factor for training zones
  double _calculateMaxHRFactor(int age) {
    // Standard formula: 220 - age, normalized to 0-1 scale
    final maxHR = 220 - age;
    return (maxHR / 220.0).clamp(0.5, 1.0);
  }
  
  /// Calculate recovery adjustment factor
  double _calculateRecoveryFactor(int age) {
    // Younger people recover faster
    if (age < 25) return 1.0;
    if (age < 35) return 0.9;
    if (age < 45) return 0.8;
    if (age < 55) return 0.7;
    if (age < 65) return 0.6;
    return 0.5; // 65+ need more recovery time
  }
  
  /// Calculate intensity tolerance
  double _calculateIntensityTolerance(int age) {
    // Peak tolerance around 20-30, gradually decreases
    if (age >= 18 && age <= 30) return 1.0;
    if (age < 18) return 0.8; // Youth need modified intensity
    if (age <= 40) return 0.9;
    if (age <= 50) return 0.8;
    if (age <= 60) return 0.7;
    return 0.6; // Seniors need lower intensity focus
  }
  
  /// Calculate injury risk factor based on age
  double _calculateInjuryRiskFactor(int age) {
    // Risk increases with age due to tissue changes
    if (age < 25) return 0.2;
    if (age < 35) return 0.3;
    if (age < 45) return 0.4;
    if (age < 55) return 0.6;
    if (age < 65) return 0.7;
    return 0.8; // Higher risk for seniors
  }
  
  /// Calculate metabolic rate factor
  double _calculateMetabolicFactor(int age) {
    // Metabolic rate decreases with age
    if (age < 25) return 1.0;
    if (age < 35) return 0.95;
    if (age < 45) return 0.9;
    if (age < 55) return 0.85;
    if (age < 65) return 0.8;
    return 0.75; // Lower metabolic rate for seniors
  }
}