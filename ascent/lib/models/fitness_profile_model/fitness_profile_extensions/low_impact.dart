import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';

/// Extension to calculate low impact exercise feature importance.
/// 
/// Uses age + gender to determine low impact exercise importance.
/// Based on OARSI Guidelines, American College of Rheumatology.
/// Women have higher rates of osteoarthritis and joint laxity.
extension LowImpact on FitnessProfile {
  
  /// Calculate low impact exercise importance based on multiple factors
  void calculateLowImpact() {
    final age = answers['age'] as int?;
    final gender = answers['gender'] as String?;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for low impact calculation: age=$age, gender=$gender');
    }
    
    featuresMap[FeatureConstants.categoryLowImpact] = _calculateLowImpactImportance(age, gender);
  }
  
  /// Calculate low impact exercise importance with gender adjustments
  double _calculateLowImpactImportance(int age, String gender) {
    double baseImportance;
    
    if (age < 30) baseImportance = 0.2;
    else if (age < 40) baseImportance = 0.3;
    else if (age < 50) baseImportance = 0.5;
    else if (age < 60) baseImportance = 0.7;
    else if (age < 70) baseImportance = 0.85;
    else baseImportance = 0.95;
    
    // Gender adjustments
    if (gender == 'female') {
      // Earlier importance due to higher osteoarthritis rates
      if (age >= 35) baseImportance += 0.05;
      if (age >= 50) baseImportance += 0.05;
    }
    
    return baseImportance.clamp(0.0, 1.0);
  }
}