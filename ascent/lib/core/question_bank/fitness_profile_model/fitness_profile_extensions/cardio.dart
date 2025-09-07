import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';

/// Extension to calculate cardio exercise feature importance.
/// 
/// Uses age + gender to determine cardiovascular exercise importance.
/// Based on CDC Guidelines, American Heart Association.
/// Women lose cardioprotective effects of estrogen post-menopause.
extension Cardio on FitnessProfile {
  
  /// Calculate cardiovascular exercise importance based on multiple factors
  void calculateCardio() {
    final age = answers['age'] as int?;
    final gender = answers['gender'] as String?;
    
    if (age == null || gender == null) {
      throw Exception('Missing required answers for cardio calculation: age=$age, gender=$gender');
    }
    
    featuresMap[FeatureConstants.categoryCardio] = _calculateCardioImportance(age, gender);
  }
  
  /// Calculate cardiovascular exercise importance with gender adjustments
  double _calculateCardioImportance(int age, String gender) {
    double baseImportance;
    
    if (age < 30) baseImportance = 0.5;
    else if (age < 40) baseImportance = 0.6;
    else if (age < 50) baseImportance = 0.7;
    else if (age < 60) baseImportance = 0.75;
    else if (age < 70) baseImportance = 0.8;
    else baseImportance = 0.85;
    
    // Gender adjustments
    if (gender == 'female' && age >= 50) {
      // Higher importance post-menopause
      baseImportance += 0.1;
    }
    
    return baseImportance.clamp(0.0, 1.0);
  }
}