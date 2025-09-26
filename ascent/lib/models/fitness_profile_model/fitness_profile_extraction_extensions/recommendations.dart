import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/goals/fitness_goals_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/glp1_medications_question.dart';
import '../../../constants_and_enums/constants.dart';

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
      recommendations.add("Complete your profile for personalized recommendations.");
      recommendationsList = recommendations;
      return;
    }

    // Add recommendations in priority order (highest priority first)
    // No need to sort since we're adding them in order

    // PRIORITY 1: Critical Safety
    if (featuresMap['prioritize_functional'] != null && featuresMap['prioritize_functional']! > 0.3) {
      recommendations.add(
        "Focus on functional movements that mimic daily activities for safety."
      );
    }

    if (featuresMap['injury_accommodations'] != null && featuresMap['injury_accommodations']! > 0) {
      recommendations.add(
        "Modify exercises to protect injured areas. If something hurts, stop."
      );
    }

    // PRIORITY 2: High Risk
    if (featuresMap['osteoporosis_risk'] == 1.0) {
      recommendations.add(
        "Weight-bearing and resistance exercises essential for bone density."
      );
    }

    // PRIORITY 3: Medium Risk
    if (featuresMap['sedentary_job'] == 1.0 && (featuresMap['current_exercise_days'] ?? 0) < 3) {
      recommendations.add(
        "Counter prolonged sitting with movement breaks every hour."
      );
    }

    // PRIORITY 4: Cardio Deficiency
    final cardioPercentile = featuresMap['cardio_fitness_percentile'] ?? 0.0;
    if (cardioPercentile < 0.2) {
      recommendations.add(
        "Prioritize moderate cardio 150 min/week to reduce cardiovascular risks."
      );
    }

    // PRIORITY 5: GLP-1 Muscle Preservation
    final isOnGlp1 = Glp1MedicationsQuestion.instance.isOnGlp1Medications(answers);
    if (isOnGlp1) {
      recommendations.add(
        "GLP-1 medications can cause muscle loss. Prioritize resistance training 3x weekly."
      );
    }

    // PRIORITY 6: Nutrition
    final dietQuality = featuresMap['diet_quality_score'] ?? 100.0;
    if (dietQuality < 70) {
      recommendations.add(
        "Improve diet quality for better recovery. Reduce alcohol, sugars, and grains."
      );
    }

    // PRIORITY 7: Strength Deficiency
    final strengthPercentile = featuresMap['strength_fitness_percentile'] ?? 0.0;
    if (strengthPercentile < 0.25) {
      recommendations.add(
        "Build foundational strength with 2-3 sessions weekly."
      );
    }

    // PRIORITY 8: Age-related muscle loss
    if (age >= 50 && strengthPercentile < 0.5) {
      recommendations.add(
        "Combat age-related muscle loss with resistance training 2-3x weekly."
      );
    }

    // PRIORITY 11: Performance (for high achievers)
    if (cardioPercentile > 0.75) {
      final percentText = "top 25% for $age year-old ${gender}s";
      recommendations.add(
        "Your cardio fitness is in the $percentText! Maintain with polarized training: 80% easy, 20% hard."
      );
    } else if (cardioPercentile > 0.5) {
      final percent = (cardioPercentile * 100).round();
      recommendations.add(
        "Your cardio fitness is better than $percent% of peers! Add intervals for next level."
      );
    }

    // Fallback recommendation if none apply
    if (recommendations.isEmpty) {
      recommendations.add(
        "Stay consistent with your current routine. Small daily actions compound into major results."
      );
    }

    // Store the list (already in priority order, no sorting needed)
    recommendationsList = recommendations;
  }
}