import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../constants_and_enums/constants_features.dart';

/// Extension to calculate osteoporosis risk using validated OSTA scoring.
///
/// This extension calculates bone health risk based on:
/// 1. Age (major risk factor)
/// 2. Weight (low weight increases risk)
/// 3. Estrogen use for women (protective factor)
///
/// Uses the Osteoporosis Self-Assessment Tool for Asians (OSTA) scoring:
/// - Age ≥75: 15 points, 65-74: 9 points, 55-64: 5 points
/// - Weight <60kg: 9 points, 60-69kg: 3 points
/// - No estrogen/HRT (women): 2 points
///
/// Risk threshold: ≥7 points indicates increased osteoporosis risk
///
/// References:
/// - Koh et al. (2001) "A simple tool to identify Asian women at increased risk of osteoporosis"
/// - National Osteoporosis Foundation guidelines
/// - WHO fracture risk assessment recommendations
extension Osteoporosis on FitnessProfile {

  /// Calculate osteoporosis risk using validated OSTA scoring
  void calculateOsteoporosisRisk() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;
    final weightKg = answers['weight_kg'] as double?;

    if (age == null || gender == null || weightKg == null) {
      throw Exception('Missing required answers for osteoporosis calculation: age=$age, gender=$gender, weight=$weightKg');
    }

    int riskScore = _calculateOsteoporosisScore(age, gender, weightKg);

    // Store as binary feature: 1.0 = at risk (score ≥ 7), 0.0 = no risk
    // This threshold aligns with clinical guidelines for bone density screening
    featuresMap[FeatureConstants.osteoporosisRisk] = riskScore >= 7 ? 1.0 : 0.0;
  }

  /// Calculate OSTA risk score based on age, gender, and weight
  int _calculateOsteoporosisScore(int age, String gender, double weightKg) {
    int riskScore = 0;

    // Age scoring (primary risk factor)
    if (age >= 75) {
      riskScore += 15;
    } else if (age >= 65) {
      riskScore += 9;
    } else if (age >= 55) {
      riskScore += 5;
    }
    // Under 55: 0 points

    // Weight scoring (low weight increases fracture risk)
    if (weightKg < 60) {
      riskScore += 9;
    } else if (weightKg <= 69) {
      riskScore += 3;
    }
    // ≥70kg: 0 points

    // Estrogen/HRT status for women (protective factor)
    if (gender.toLowerCase() == 'female') {
      // TODO: Add HRT/estrogen question to onboarding
      // For now, assume not on HRT (conservative approach)
      // This adds 2 points for most postmenopausal women
      final onHRT = false; // Default assumption
      if (!onHRT) {
        riskScore += 2;
      }
    }

    return riskScore;
  }
}