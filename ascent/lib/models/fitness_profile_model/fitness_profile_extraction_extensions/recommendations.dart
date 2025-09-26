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
        "Based on your age and mobility assessment, you'll benefit from functional training. Focus on movements that mimic daily activities like standing from chairs and carrying groceries. This helps maintain independence and supports better balance."
      );
    }

    if (injuriesMap != null) {
      for (final entry in injuriesMap!.entries) {
        if (entry.value == BodyPartConstants.avoid) {
          recommendations.add(
            "You indicated an injury to your ${entry.key}. Modify all exercises to avoid this area and focus on strengthening surrounding muscles. Pain is your body's warning signal - always stop if something hurts."
          );
          break; // Only one injury recommendation
        }
      }
    }

    // PRIORITY 2: High Risk
    if (featuresMap['osteoporosis_risk'] == 1.0) {
      recommendations.add(
        "Your age and gender profile suggests focusing on bone health. Include weight-bearing exercises like walking, climbing stairs, and resistance training. These activities help support bone density and overall strength."
      );
    }

    // PRIORITY 3: Medium Risk
    if (featuresMap['sedentary_job'] == 1.0 && (featuresMap['current_exercise_days'] ?? 0) < 3) {
      recommendations.add(
        "Your sedentary job means you spend long periods sitting. Take 2-minute movement breaks every hour and do desk stretches. This can help improve energy levels and counteract prolonged sitting."
      );
    }

    // PRIORITY 4: Cardio Deficiency
    final cardioPercentile = featuresMap['cardio_fitness_percentile'] ?? 0.0;
    if (cardioPercentile < 0.2) {
      recommendations.add(
        "Your cardio fitness is below the 20th percentile for your age group. Build your cardiovascular base with 150 minutes of moderate activity weekly. This supports heart health and improves daily energy."
      );
    }

    // PRIORITY 5: GLP-1 Muscle Preservation
    final isOnGlp1 = Glp1MedicationsQuestion.instance.isOnGlp1Medications(answers);
    if (isOnGlp1) {
      recommendations.add(
        "You're taking GLP-1 medications, which can affect muscle mass during weight loss. Prioritize resistance training 3x weekly with adequate protein intake. This helps preserve lean muscle mass and supports metabolic health."
      );
    }

    // PRIORITY 6: Nutrition
    final dietQuality = featuresMap['diet_quality_score'] ?? 100.0;
    if (dietQuality < 70) {
      recommendations.add(
        "Your nutrition assessment indicates room for improvement. Focus on reducing alcohol, sugary treats, and processed grains while increasing whole foods. Better nutrition supports recovery and can enhance training results."
      );
    }

    // PRIORITY 7: Strength Deficiency
    final strengthPercentile = featuresMap['strength_fitness_percentile'] ?? 0.0;
    if (strengthPercentile < 0.25) {
      recommendations.add(
        "Your strength is below the 25th percentile for your age group. Start with bodyweight exercises and progress to resistance training 2-3x weekly. Building strength can improve daily function and help prevent injuries."
      );
    }

    // PRIORITY 8: Age-related muscle loss
    if (age >= 50 && strengthPercentile < 0.5) {
      recommendations.add(
        "At age $age, maintaining muscle mass becomes increasingly important. Focus on resistance training 2-3x weekly with progressive overload. This helps maintain strength and supports healthy aging."
      );
    }

    // PRIORITY 11: Performance (for high achievers)
    if (cardioPercentile > 0.75) {
      final percentText = "top 25% for $age year-old ${gender}s";
      recommendations.add(
        "Your cardio fitness is in the $percentText - excellent work! Maintain this elite level with polarized training: 80% easy, 20% hard. This approach helps sustain performance while preventing burnout."
      );
    } else if (cardioPercentile > 0.5) {
      final percent = (cardioPercentile * 100).round();
      recommendations.add(
        "Your cardio fitness is better than $percent% of peers - great foundation! Add interval training 1-2x weekly to reach the next level. Focus on progressive challenges to continue improving."
      );
    }

    // Fallback recommendation if none apply
    if (recommendations.isEmpty) {
      recommendations.add(
        "Based on your profile, you're in good shape! Stay consistent with your current routine and focus on variety to keep progressing. Small daily actions build lasting habits and results."
      );
    }

    // Store the list (already in priority order, no sorting needed)
    recommendationsList = recommendations;
  }
}