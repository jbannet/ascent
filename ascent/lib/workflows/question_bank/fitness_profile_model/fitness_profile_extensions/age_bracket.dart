import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';

/// Extension to calculate all age bracket features.
/// 
/// Uses age to determine which age bracket the user falls into.
/// Only one bracket will be 1.0, all others will be 0.0.
extension AgeBracket on FitnessProfile {
  
  /// Calculate all age bracket features
  void calculateAgeBracket() {
    final age = answers['age'] as int?;
    
    if (age == null) {
      throw Exception('Missing required answer for age bracket calculation: age=$age');
    }
    
    // Set all age brackets (only one will be 1.0, others 0.0)
    featuresMap[FeatureConstants.ageBracketUnder18] = age < 18 ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket18To34] = (age >= 18 && age <= 34) ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket35To54] = (age >= 35 && age <= 54) ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket55To64] = (age >= 55 && age <= 64) ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket65To79] = (age >= 65 && age <= 79) ? 1.0 : 0.0;
    featuresMap[FeatureConstants.ageBracket80Plus] = age >= 80 ? 1.0 : 0.0;
  }
}