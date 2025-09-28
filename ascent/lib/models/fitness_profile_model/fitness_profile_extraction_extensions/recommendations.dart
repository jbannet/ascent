import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/goals/fitness_goals_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/glp1_medications_question.dart';
import '../../../constants_and_enums/constants.dart';
import '../../../constants_and_enums/constants_features.dart';

/// Extension to calculate personalized fitness recommendations.
///
/// Recommendations are calculated on-demand and prioritized based on:
/// 1. Safety and injury prevention (highest priority)
/// 2. Health risk mitigation
/// 3. Performance optimization
/// 4. Goal achievement
///
/// All recommendations are evidence-based and sourced from peer-reviewed research.
extension Recommendations on FitnessProfile {
  /// Calculate personalized recommendations based on user profile
  void calculateRecommendations() {
    final recommendations = <String>[];
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;

    if (age == null || gender == null) {
      // Fallback recommendations for incomplete profiles
      recommendations.add("Complete profile for personalized recs.");
      recommendationsList = recommendations;
      return;
    }

    // Add recommendations in priority order (highest priority first)
    // No need to sort since we're adding them in order

    // PRIORITY 1: Critical Safety
    if (featuresMap[FunctionalConstants.prioritizeFunctional] != null &&
        featuresMap[FunctionalConstants.prioritizeFunctional]! > RecommendationsConstants.functionalPriorityThreshold) {
      recommendations.add(
        "Age/mobility: need functional training. Daily movements: chair stands, carrying. Goals: independence, balance.",
      );
    }

    if (injuriesMap != null) {
      for (final entry in injuriesMap!.entries) {
        if (entry.value == BodyPartConstants.avoid) {
          recommendations.add(
            "${entry.key} injury: avoid area, strengthen surrounding muscles. Stop if pain.",
          );
          break; // Only one injury recommendation
        }
      }
    }

    // PRIORITY 2: High Risk
    if (featuresMap[FeatureConstants.osteoporosisRisk] == RecommendationsConstants.riskPresent) {
      recommendations.add(
        "Age/gender profile: focus bone health. Weight-bearing ex: walking, stairs, resistance training for bone density.",
      );
    }

    // PRIORITY 3: Medium Risk
    if (featuresMap[SedentaryLifestyleConstants.sedentaryJob] == RecommendationsConstants.riskPresent &&
        (featuresMap['current_exercise_days'] ?? 0) < RecommendationsConstants.exerciseDaysThreshold) {
      recommendations.add(
        "Sedentary job: 2min breaks/hour, desk stretches. Improves energy, counters sitting.",
      );
    }

    // PRIORITY 4: Cardio Deficiency
    final cardioPercentile = featuresMap[CardioConstants.cardioFitnessPercentile] ?? 0.0;
    if (cardioPercentile < RecommendationsConstants.lowCardioPercentileThreshold) {
      recommendations.add(
        "Cardio <20th percentile. Need 150min/wk moderate activity for heart health, energy.",
      );
    }

    // PRIORITY 5: GLP-1 Muscle Preservation
    final isOnGlp1 = Glp1MedicationsQuestion.instance.isOnGlp1;
    if (isOnGlp1) {
      recommendations.add(
        "GLP-1 meds: muscle loss risk. Resistance training 3x/wk + protein for muscle preservation.",
      );
    }

    // PRIORITY 6: Nutrition
    final dietQuality = featuresMap[NutritionConstants.dietQualityScore] ?? NutritionConstants.baseDietScore;
    if (dietQuality < RecommendationsConstants.dietQualityThreshold) {
      recommendations.add(
        "Nutrition needs improvement: reduce alcohol/sugar/processed grains, increase whole foods for recovery.",
      );
    }

    // PRIORITY 7: Strength Deficiency
    final strengthPercentile =
        featuresMap[StrengthConstants.strengthFitnessPercentile] ?? 0.0;
    if (strengthPercentile < RecommendationsConstants.lowStrengthPercentileThreshold) {
      recommendations.add(
        "Strength <25th percentile. Start bodyweight, progress to resistance 2-3x/wk for function, injury prevention.",
      );
    }

    // PRIORITY 8: Age-related muscle loss
    if (age >= RecommendationsConstants.ageThreshold && strengthPercentile < RecommendationsConstants.averageStrengthPercentileThreshold) {
      recommendations.add(
        "Age $age: muscle loss risk. Resistance 2-3x/wk with progressive overload for strength, aging.",
      );
    }

    // PRIORITY 11: Performance (for high achievers)
    if (cardioPercentile > RecommendationsConstants.highCardioPercentileThreshold) {
      final percentText = "top 25% for $age year-old ${gender}s";
      recommendations.add(
        "Cardio in $percentText - excellent! Maintain with polarized training: 80% easy, 20% hard.",
      );
    } else if (cardioPercentile > RecommendationsConstants.averageStrengthPercentileThreshold) {
      final percent = (cardioPercentile * RecommendationsConstants.percentageMultiplier).round();
      recommendations.add(
        "Cardio better than $percent% of peers. Add intervals 1-2x/wk for next level.",
      );
    }

    // Fallback recommendation if none apply
    if (recommendations.isEmpty) {
      recommendations.add(
        "Good shape! Stay consistent, add variety. Small daily actions build habits.",
      );
    }

    // Store the list (already in priority order, no sorting needed)
    recommendationsList = recommendations;
  }
}
