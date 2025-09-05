import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../onboarding_question.dart';

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
  void evaluate(dynamic answer, Map<String, double> features, Map<String, double> profile) {
    final age = (answer as num).toInt();
    
    // Store demographics - use birth_year for persistence since age changes
    profile['birth_year'] = (DateTime.now().year - age).toDouble();
    profile['age'] = age.toDouble(); // Keep for reference
    
    // Standard age brackets (feature_list allowed keys)
    features['<18'] = age < 18 ? 1.0 : 0.0;
    features['18-34'] = (age >= 18 && age <= 34) ? 1.0 : 0.0;
    features['35-54'] = (age >= 35 && age <= 54) ? 1.0 : 0.0;
    features['55-64'] = (age >= 55 && age <= 64) ? 1.0 : 0.0;
    features['65-79'] = (age >= 65 && age <= 79) ? 1.0 : 0.0;
    features['80+'] = age >= 80 ? 1.0 : 0.0;
    
    // Exercise category importance based on age (scientifically-backed)
    features['strength'] = _calculateStrengthImportance(age);
    features['balance'] = _calculateBalanceImportance(age);
    features['low impact'] = _calculateLowImpactImportance(age);
    features['stretching'] = _calculateStretchingImportance(age);
    features['cardio'] = _calculateCardioImportance(age);
    features['bodyweight'] = _calculateBodyweightImportance(age);
    
    // Training parameter calculations (profile map)
    profile['max_heart_rate_factor'] = _calculateMaxHRFactor(age);
    profile['recovery_adjustment_factor'] = _calculateRecoveryFactor(age);
    profile['intensity_tolerance'] = _calculateIntensityTolerance(age);
    profile['injury_risk_age_factor'] = _calculateInjuryRiskFactor(age);
    profile['requires_medical_clearance'] = age >= 50 ? 1.0 : 0.0;
    profile['mobility_priority'] = age >= 40 ? ((age - 40) / 60.0).clamp(0.0, 1.0) : 0.0;
    profile['balance_training_importance'] = age >= 50 ? ((age - 50) / 50.0).clamp(0.0, 1.0) : 0.0;
    profile['metabolic_rate_factor'] = _calculateMetabolicFactor(age);
    profile['muscle_preservation_priority'] = age >= 35 ? 1.0 : 0.0;
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
  
  //MARK: PRIVATE HELPERS - EXERCISE CATEGORY IMPORTANCE
  
  /// Calculate strength training importance based on age
  /// 
  /// Source: ACSM Guidelines 2024, Journal of Cachexia, Sarcopenia and Muscle
  /// Rationale: Muscle mass declines 3-8% per decade after 30, accelerating to 15% after 70
  /// Resistance training is primary treatment for sarcopenia prevention
  double _calculateStrengthImportance(int age) {
    if (age < 30) return 0.6;
    if (age < 40) return 0.7;
    if (age < 50) return 0.8;
    if (age < 60) return 0.85;
    if (age < 70) return 0.9;
    return 1.0; // Maximum importance for 70+ (sarcopenia prevention critical)
  }
  
  /// Calculate balance training importance based on age
  /// 
  /// Source: CDC STEADI Program, WHO Fall Prevention Guidelines
  /// Rationale: 1 in 4 adults 65+ fall annually; falls are leading cause of injury death
  /// Balance exercises reduce fall risk by 31-40% when started at age 50+
  double _calculateBalanceImportance(int age) {
    if (age < 40) return 0.2;
    if (age < 55) return 0.4;
    if (age < 65) return 0.6;
    if (age < 75) return 0.8;
    return 1.0; // Critical for 75+ (highest fall risk)
  }
  
  /// Calculate low impact exercise importance based on age
  /// 
  /// Source: OARSI Guidelines, American College of Rheumatology
  /// Rationale: 50% of adults 65+ have osteoarthritis; cartilage degradation begins at 40
  /// Low-impact exercise maintains joint health while allowing continued activity
  double _calculateLowImpactImportance(int age) {
    if (age < 30) return 0.2;
    if (age < 40) return 0.3;
    if (age < 50) return 0.5;
    if (age < 60) return 0.7;
    if (age < 70) return 0.85;
    return 0.95; // Near maximum for 70+ (joint protection critical)
  }
  
  /// Calculate stretching/flexibility importance based on age
  /// 
  /// Source: Exercise and Sport Sciences Reviews 2024, ACSM Position Stand
  /// Rationale: ROM declines 20-30% by age 70; flexibility loss accelerates after 40
  /// 60-second holds more effective for older adults vs 30-second for younger
  double _calculateStretchingImportance(int age) {
    if (age < 30) return 0.3;
    if (age < 40) return 0.4;
    if (age < 50) return 0.5;
    if (age < 60) return 0.65;
    if (age < 70) return 0.8;
    return 0.9; // High importance for 70+ (combat stiffness)
  }
  
  /// Calculate cardiovascular exercise importance based on age
  /// 
  /// Source: CDC Guidelines, American Heart Association
  /// Rationale: VO2max declines 10% per decade (reducible to 5% with exercise)
  /// 150 min/week moderate exercise reduces cardiovascular mortality by 31%
  double _calculateCardioImportance(int age) {
    if (age < 30) return 0.5;
    if (age < 40) return 0.6;
    if (age < 50) return 0.7;
    if (age < 60) return 0.75;
    if (age < 70) return 0.8;
    return 0.85; // Steady increase with age for heart health
  }
  
  /// Calculate bodyweight exercise importance based on age
  /// 
  /// Source: Journal of Aging and Physical Activity, ACE Fitness
  /// Rationale: Functional fitness critical for maintaining independence in ADLs
  /// Bodyweight training improves cognitive function and reduces dementia risk
  double _calculateBodyweightImportance(int age) {
    if (age < 30) return 0.5;
    if (age < 40) return 0.55;
    if (age < 50) return 0.6;
    if (age < 60) return 0.65;
    if (age < 70) return 0.7;
    return 0.75; // Gradual increase for functional strength
  }
  
  //MARK: PRIVATE HELPERS - TRAINING PARAMETERS
  
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