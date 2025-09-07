import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';

/// Extension to calculate bodyweight exercise feature importance.
/// 
/// Uses age to determine bodyweight exercise importance.
/// Based on Journal of Aging and Physical Activity, ACE Fitness.
extension Bodyweight on FitnessProfile {
  
  /// Calculate bodyweight exercise importance based on age
  void calculateBodyweight() {
    final age = answers['age'] as int?;
    
    if (age == null) {
      throw Exception('Missing required answer for bodyweight calculation: age=$age');
    }
    
    featuresMap[FeatureConstants.categoryBodyweight] = _calculateBodyweightImportance(age);
  }
  
  /// Calculate bodyweight exercise importance based on age
  double _calculateBodyweightImportance(int age) {
    if (age < 30) return 0.5;
    if (age < 40) return 0.55;
    if (age < 50) return 0.6;
    if (age < 60) return 0.65;
    if (age < 70) return 0.7;
    return 0.75; // Gradual increase for functional strength
  }
}