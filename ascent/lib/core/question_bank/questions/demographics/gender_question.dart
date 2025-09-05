import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Gender demographic question for fitness assessment normalization.
/// 
/// Gender is used for fitness norm calculations, body composition estimates,
/// and gender-specific training considerations.
class GenderQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'gender';
  
  @override
  String get questionText => 'What is your gender?';
  
  @override
  String get section => 'personal_info';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'This helps us provide personalized fitness recommendations';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: 'male', label: 'Male'),
    QuestionOption(value: 'female', label: 'Female'),
    QuestionOption(value: 'non_binary', label: 'Non-binary'),
    QuestionOption(value: 'prefer_not_to_say', label: 'Prefer not to say'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  void evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final gender = answer.toString();
    
    // Store gender in demographics
    demographics['gender'] = gender == 'male' ? 1.0 : (gender == 'female' ? 2.0 : 3.0);
    
    // Gender identity for norm calculations
    features['is_male'] = gender == 'male' ? 1.0 : 0.0;
    features['is_female'] = gender == 'female' ? 1.0 : 0.0;
    features['is_non_binary'] = gender == 'non_binary' ? 1.0 : 0.0;
    
    // Physiological considerations (using typical biological differences)
    features['muscle_mass_baseline'] = _getMuscleBaseline(gender);
    features['bone_density_baseline'] = _getBoneDensityBaseline(gender);
    features['body_fat_baseline'] = _getBodyFatBaseline(gender);
    
    // Strength training considerations
    features['upper_body_strength_baseline'] = _getUpperBodyBaseline(gender);
    features['lower_body_strength_baseline'] = _getLowerBodyBaseline(gender);
    features['strength_progression_rate'] = _getProgressionRate(gender);
    
    // Cardiovascular considerations
    features['cardiovascular_efficiency'] = _getCardioEfficiency(gender);
    features['heart_rate_adjustment'] = _getHRAdjustment(gender);
    
    // Training response factors
    features['hypertrophy_response'] = _getHypertrophyResponse(gender);
    features['endurance_adaptation'] = _getEnduranceAdaptation(gender);
    
    // Recovery considerations
    features['recovery_rate_factor'] = _getRecoveryFactor(gender);
    
    // Special considerations
    features['iron_deficiency_risk'] = gender == 'female' ? 0.8 : 0.2;
    features['osteoporosis_risk'] = _getOsteoporosisRisk(gender);
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['male', 'female', 'non_binary', 'prefer_not_to_say'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => 'prefer_not_to_say'; // Respectful default
  
  //MARK: PRIVATE HELPERS
  
  /// Get baseline muscle mass factor
  double _getMuscleBaseline(String gender) {
    switch (gender) {
      case 'male':
        return 1.0; // Higher baseline muscle mass
      case 'female':
        return 0.7; // Lower baseline muscle mass
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.85; // Average between male and female
      default:
        return 0.85;
    }
  }
  
  /// Get baseline bone density factor
  double _getBoneDensityBaseline(String gender) {
    switch (gender) {
      case 'male':
        return 1.0; // Higher baseline bone density
      case 'female':
        return 0.8; // Lower baseline bone density
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.9; // Average
      default:
        return 0.9;
    }
  }
  
  /// Get baseline body fat percentage factor
  double _getBodyFatBaseline(String gender) {
    switch (gender) {
      case 'male':
        return 0.7; // Lower baseline body fat
      case 'female':
        return 1.0; // Higher baseline body fat (essential fat differences)
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.85; // Average
      default:
        return 0.85;
    }
  }
  
  /// Get upper body strength baseline
  double _getUpperBodyBaseline(String gender) {
    switch (gender) {
      case 'male':
        return 1.0; // Higher upper body strength baseline
      case 'female':
        return 0.6; // Lower upper body strength baseline
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.8; // Average
      default:
        return 0.8;
    }
  }
  
  /// Get lower body strength baseline
  double _getLowerBodyBaseline(String gender) {
    switch (gender) {
      case 'male':
        return 1.0; // Higher lower body strength
      case 'female':
        return 0.8; // Smaller difference in lower body strength
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.9; // Average
      default:
        return 0.9;
    }
  }
  
  /// Get strength progression rate factor
  double _getProgressionRate(String gender) {
    switch (gender) {
      case 'male':
        return 1.0; // Typically faster strength gains
      case 'female':
        return 0.8; // Still significant gains, but often slower
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.9; // Average
      default:
        return 0.9;
    }
  }
  
  /// Get cardiovascular efficiency factor
  double _getCardioEfficiency(String gender) {
    switch (gender) {
      case 'male':
        return 0.9; // Larger heart, higher VO2 max potential
      case 'female':
        return 1.0; // Often more efficient at fat oxidation
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.95; // Average
      default:
        return 0.95;
    }
  }
  
  /// Get heart rate adjustment factor
  double _getHRAdjustment(String gender) {
    switch (gender) {
      case 'male':
        return 1.0; // Standard heart rate zones
      case 'female':
        return 1.05; // Typically higher heart rates at same relative intensity
      case 'non_binary':
      case 'prefer_not_to_say':
        return 1.025; // Average
      default:
        return 1.025;
    }
  }
  
  /// Get hypertrophy response factor
  double _getHypertrophyResponse(String gender) {
    switch (gender) {
      case 'male':
        return 1.0; // Strong hypertrophy response
      case 'female':
        return 0.7; // Lower but still significant hypertrophy potential
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.85; // Average
      default:
        return 0.85;
    }
  }
  
  /// Get endurance adaptation factor
  double _getEnduranceAdaptation(String gender) {
    switch (gender) {
      case 'male':
        return 0.95; // Strong endurance adaptations
      case 'female':
        return 1.0; // Often excellent endurance adaptations
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.975; // Average
      default:
        return 0.975;
    }
  }
  
  /// Get recovery rate factor
  double _getRecoveryFactor(String gender) {
    switch (gender) {
      case 'male':
        return 0.9; // Generally good recovery
      case 'female':
        return 1.0; // Often faster recovery between sessions
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.95; // Average
      default:
        return 0.95;
    }
  }
  
  /// Get osteoporosis risk factor
  double _getOsteoporosisRisk(String gender) {
    switch (gender) {
      case 'male':
        return 0.3; // Lower risk
      case 'female':
        return 0.8; // Higher risk, especially post-menopause
      case 'non_binary':
      case 'prefer_not_to_say':
        return 0.55; // Average risk
      default:
        return 0.55;
    }
  }
}