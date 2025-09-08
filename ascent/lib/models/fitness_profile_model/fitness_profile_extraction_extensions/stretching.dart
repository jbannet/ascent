import 'package:ascent/constants_features.dart';
import '../fitness_profile.dart';
import '../../../workflows/question_bank/questions/demographics/age_question.dart';

/// Extension to calculate stretching exercise feature importance.
/// 
/// Uses age to determine stretching/flexibility importance.
/// Based on Exercise and Sport Sciences Reviews 2024, ACSM Position Stand.
extension Stretching on FitnessProfile {
  
  /// Calculate stretching exercise importance based on age
  void calculateStretching() {
    final age = answers[AgeQuestion.questionId] as int?;
    
    if (age == null) {
      throw Exception('Missing required answer for stretching calculation: age=$age');
    }
    
    featuresMap[FeatureConstants.categoryStretching] = _calculateStretchingImportance(age);
  }
  
  /// Calculate stretching importance based on age
  double _calculateStretchingImportance(int age) {
    if (age < 30) return 0.3;
    if (age < 40) return 0.4;
    if (age < 50) return 0.5;
    if (age < 60) return 0.65;
    if (age < 70) return 0.8;
    return 0.9; // High importance for 70+ (combat stiffness)
  }
}