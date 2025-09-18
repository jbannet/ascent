import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';

/// Extension to calculate all age bracket features.
/// 
/// Uses age to determine which age bracket the user falls into.
/// Based on ACSM standard 10-year brackets for fitness assessment.
/// Only one bracket will be 1.0, all others will be 0.0.
extension AgeBracket on FitnessProfile {
  
  /// Calculate all age bracket features and age-related training parameters
  void calculateAgeBracket() {
    final dateOfBirth = AgeQuestion.instance.dateOfBirth;
    
    if (dateOfBirth == null) {
      throw Exception('Missing required answer for age bracket calculation: dateOfBirth=$dateOfBirth');
    }
    
    // Calculate age from date of birth
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year - (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day) ? 1 : 0);
    
    // Store birth year for persistence and reference age
    answers[ProfileConstants.birthYear] = dateOfBirth.year.toDouble();
    answers[AgeQuestion.questionId] = age;
    
    // Set all age brackets using ACSM standard (only one will be 1.0, others 0.0)
    featuresMap[FeatureConstants.ageBracketUnder20] = age < 20 ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket20To29] = (age >= 20 && age <= 29) ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket30To39] = (age >= 30 && age <= 39) ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket40To49] = (age >= 40 && age <= 49) ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket50To59] = (age >= 50 && age <= 59) ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket60To69] = (age >= 60 && age <= 69) ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket70Plus] = age >= 70 ? 1.0 : 0.0;
  }
}