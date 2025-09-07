import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';
import '../../../workflows/question_bank/questions/demographics/gender_question.dart';

/// Extension to calculate strength feature importance.
/// 
/// Uses age + gender to determine strength training importance.
/// Based on ACSM Guidelines 2024, Journal of Cachexia, Sarcopenia and Muscle.
/// Women start with lower baseline muscle mass and lose it faster post-menopause.
extension Strength on FitnessProfile {
  
  /// Calculate strength training importance based on multiple factors
  void calculateStrength() {
    final age = answers[AgeQuestion.questionId] as int?;
    final gender = answers[GenderQuestion.questionId] as String?;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for strength calculation: age=$age, gender=$gender');
    }
    
    featuresMap[FeatureConstants.categoryStrength] = _calculateStrengthImportance(age, gender);
  }
  
  /// Calculate strength training importance with gender adjustments
  double _calculateStrengthImportance(int age, String gender) {
    double baseImportance;
    
    if (age < 30) baseImportance = 0.6;
    else if (age < 40) baseImportance = 0.7;
    else if (age < 50) baseImportance = 0.8;
    else if (age < 60) baseImportance = 0.85;
    else if (age < 70) baseImportance = 0.9;
    else baseImportance = 1.0;
    
    // Gender adjustments
    if (gender == 'female') {
      // Higher importance for women due to lower baseline and menopause effects
      if (age >= 35) baseImportance += 0.1; // Post peak bone mass
      if (age >= 50) baseImportance += 0.1; // Menopause acceleration
    }
    
    return baseImportance.clamp(0.0, 1.0);
  }
}