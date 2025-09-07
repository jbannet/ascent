import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';

/// Extension to calculate balance feature importance.
/// 
/// Uses age + gender to determine balance training importance.
/// Based on CDC STEADI Program, WHO Fall Prevention Guidelines.
/// Women have higher fall risk, especially post-menopause.
extension Balance on FitnessProfile {
  
  /// Calculate balance training importance based on multiple factors
  void calculateBalance() {
    final age = answers['age'] as int?;
    final gender = answers['gender'] as String?;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for balance calculation: age=$age, gender=$gender');
    }
    
    featuresMap[FeatureConstants.categoryBalance] = _calculateBalanceImportance(age, gender);
  }
  
  /// Calculate balance training importance with gender adjustments
  double _calculateBalanceImportance(int age, String gender) {
    double baseImportance;
    
    if (age < 40) baseImportance = 0.2;
    else if (age < 55) baseImportance = 0.4;
    else if (age < 65) baseImportance = 0.6;
    else if (age < 75) baseImportance = 0.8;
    else baseImportance = 1.0;
    
    // Gender adjustments
    if (gender == 'female') {
      // Earlier importance due to higher fall risk
      if (age >= 45) baseImportance += 0.1;
      if (age >= 65) baseImportance += 0.1; // Post-menopause bone density loss
    }
    
    return baseImportance.clamp(0.0, 1.0);
  }
}