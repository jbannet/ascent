import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';
import '../../../constants.dart';

/// Extension to calculate strength fitness metrics and training parameters.
/// 
/// This extension focuses on core strength metrics:
/// 1. Pushup performance assessment and percentiles
/// 2. Strength baseline measurements
/// 3. One-rep max estimations (if data available)
/// 4. Muscle endurance indicators
/// 
/// Based on ACSM Guidelines 2024, Journal of Cachexia, Sarcopenia and Muscle.
/// Note: Strength importance is calculated in relative_objective_importance.dart
extension Strength on FitnessProfile {
  
  /// Calculate strength fitness metrics and training parameters
  void calculateStrength() {
    final age = AgeQuestion.instance.getAge(answers);
    final gender = GenderQuestion.instance.getGender(answers);
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for strength calculation: age=$age, gender=$gender');
    }
    
    // Calculate strength-specific metrics
    _calculateStrengthBaseline(age, gender);
    _calculateStrengthParameters(age, gender);
  }
  
  /// Calculate baseline strength metrics from available assessments
  void _calculateStrengthBaseline(int age, String gender) {
    // TODO: Add pushup test analysis when Q5PushupsQuestion is available
    // For now, placeholder for strength baseline metrics
    
    // Age-based strength decline factors (sarcopenia research)
    if (age >= 30) {
      final strengthDeclineFactor = 1.0 - ((age - 30) * 0.008); // 0.8% per year after 30
      featuresMap['strength_age_factor'] = strengthDeclineFactor.clamp(0.5, 1.0);
    } else {
      featuresMap['strength_age_factor'] = 1.0;
    }
    
    // Gender-based strength norms
    if (gender == AnswerConstants.female) {
      featuresMap['strength_gender_factor'] = 0.65; // Women ~65% of male strength on average
    } else {
      featuresMap['strength_gender_factor'] = 1.0;
    }
  }
  
  /// Calculate strength training parameters
  void _calculateStrengthParameters(int age, String gender) {
    // Recovery time between strength sessions (increases with age)
    if (age < 30) {
      featuresMap['strength_recovery_hours'] = 48.0;
    } else if (age < 50) {
      featuresMap['strength_recovery_hours'] = 60.0;
    } else {
      featuresMap['strength_recovery_hours'] = 72.0;
    }
    
    // Volume tolerance (decreases with age)
    if (age < 40) {
      featuresMap['strength_volume_factor'] = 1.0;
    } else if (age < 60) {
      featuresMap['strength_volume_factor'] = 0.85;
    } else {
      featuresMap['strength_volume_factor'] = 0.7;
    }
  }
}