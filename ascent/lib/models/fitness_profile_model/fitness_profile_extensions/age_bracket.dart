import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';

/// Extension to calculate all age bracket features.
/// 
/// Uses age to determine which age bracket the user falls into.
/// Based on ACSM standard 10-year brackets for fitness assessment.
/// Only one bracket will be 1.0, all others will be 0.0.
extension AgeBracket on FitnessProfile {
  
  /// Calculate all age bracket features using ACSM 10-year brackets
  void calculateAgeBracket() {
    final age = answers[AgeQuestion.questionId] as int?;
    
    if (age == null) {
      throw Exception('Missing required answer for age bracket calculation: age=$age');
    }
    
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