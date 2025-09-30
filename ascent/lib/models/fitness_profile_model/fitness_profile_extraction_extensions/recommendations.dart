import 'package:ascent/workflow_views/onboarding_workflow/question_bank/questions/motivation/primary_motivation_question.dart';

import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
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
      recommendations.add("Profile incomplete. Data insufficient for risk analysis. (Priority 1)");
      recommendationsList = recommendations;
      return;
    }

    // Add recommendations in priority order (highest priority first)
    // No need to sort since we're adding them in order

    // PRIORITY 1: Critical Safety
    if (featuresMap[FunctionalConstants.prioritizeFunctional] != null &&
        featuresMap[FunctionalConstants.prioritizeFunctional]! > RecommendationsConstants.functionalPriorityThreshold) {
      recommendations.add(
        "Given your age ($age) and mobility, functional exercises can help you maintain independence.",
      );
    }

    if (injuriesMap != null) {
      for (final entry in injuriesMap!.entries) {
        if (entry.value == BodyPartConstants.avoid) {
          recommendations.add(
            "You have injuries (${entry.key}) that we will need to plan around. Remember if it hurts, stop and consult a professional.",
          );
          break; // Only one injury recommendation
        }
      }
    }

    // PRIORITY 2: High Risk
    if (featuresMap[FeatureConstants.osteoporosisRisk] == RecommendationsConstants.riskPresent) {
      recommendations.add(
        "Considering your risk factors, weight training can help maintain bone health and reduce the risk of fractures in the future.",
      );
    }

    // PRIORITY 3: Medium Risk
    if (featuresMap[SedentaryLifestyleConstants.sedentaryJob] == RecommendationsConstants.riskPresent &&
        (featuresMap['current_exercise_days'] ?? 0) < RecommendationsConstants.exerciseDaysThreshold) {
      recommendations.add(
        "A sedentary job increases health risks. Regular exercise can help mitigate these risks and improve overall well-being.",
      );
    }

    // PRIORITY 4: Cardio Deficiency
    final cardioPercentile = featuresMap[CardioConstants.cardioFitnessPercentile] ?? 0.0;
    if (cardioPercentile < RecommendationsConstants.lowCardioPercentileThreshold) {
      recommendations.add(
        "Your cardiovascular fitness is low for your age, which presents us an opportunity to improve heart health and endurance.",
      );
    }

    // PRIORITY 5: GLP-1 Muscle Preservation
    final isOnGlp1 = Glp1MedicationsQuestion.instance.isOnGlp1;
    if (isOnGlp1) {
      recommendations.add(
        "Your GLP-1 medication puts you at risk for losing muscle mass during weight loss. Strength training can help preserve muscle and maintain metabolism. (Priority 5)",
      );
    }

     // PRIORITY 5: Training Parameters
    final exerciseDays = featuresMap['current_exercise_days'] ?? 0;
    final isSociallyMotivated = PrimaryMotivationQuestion.instance.primaryMotivation == AnswerConstants.socialConnection;
    if (exerciseDays <= 1) {
      if (isSociallyMotivated) {
        recommendations.add(
          "Starting a new exercise routine can be daunting.  Consider finding a friend to join you and boost accountability.",
        );
      } else {
        recommendations.add(
          "Starting a new exercise routine can be daunting. We'll start slow and gradually build up frequency and intensity.",
        );
      }      
    }

    

    // PRIORITY 6: Nutrition
    final dietQuality = featuresMap[NutritionConstants.dietQualityScore] ?? NutritionConstants.baseDietScore;
    if (dietQuality < RecommendationsConstants.dietQualityThreshold) {
      recommendations.add(
        "Poor nutrition can slow down your recovery and increase inflammation. We'll intersperse days to focus on nutrition and recovery.",
      );
    }

    // PRIORITY 7: Strength Deficiency
    final strengthPercentile =
        featuresMap[StrengthConstants.strengthFitnessPercentile] ?? 0.0;
    

    // PRIORITY 8: Age-related muscle loss
    if (age >= RecommendationsConstants.ageThreshold && strengthPercentile < RecommendationsConstants.averageStrengthPercentileThreshold) {
      recommendations.add(
        "At age $age, you're likely losing muscle mass each year. (Priority 4)",
      );
    }

    // PRIORITY 2: Elite Performance (Cardio)
    if (cardioPercentile > RecommendationsConstants.averageStrengthPercentileThreshold) {
      recommendations.add(
        "Excellent work! Your cardiovascular fitness is solid for your age.",
      );
    } 
    // PRIORITY 4: Elite Strength Performance
    if (strengthPercentile > RecommendationsConstants.averageStrengthPercentileThreshold) {
      recommendations.add(
        "Excellent work! Your strength fitness is solid for your age.",
      );
    }
   
    if (exerciseDays > 5) {
      recommendations.add(
        "You exercise more than 5 days a week for over a year, but may be hitting a plateau and need more variety. (Priority 5)",
      );
    }

    // Fallback recommendation if none apply
    if (recommendations.isEmpty) {
      recommendations.add(
        "Your fitness profile looks solid with no major red flags - you're maintaining good baseline health.",
      );
    }

    // Store the list (already in priority order, no sorting needed)
    recommendationsList = recommendations;
  }
}
