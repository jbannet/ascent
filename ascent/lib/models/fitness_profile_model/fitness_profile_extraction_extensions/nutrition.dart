import 'dart:math';

import '../fitness_profile.dart';
import '../../../constants_and_enums/constants_features.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/nutrition/sugary_treats_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/nutrition/sodas_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/nutrition/grains_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/nutrition/alcohol_question.dart';

/// Extension to capture basic nutrition habits for recovery and health scoring.
///
/// Stores raw consumption metrics plus a simple diet quality score that can be
/// used to bias coaching recommendations without shaming users.
extension NutritionMetrics on FitnessProfile {
  /// Calculate nutrition-related features from the onboarding survey.
  void calculateNutrition() {
    final treatsPerDay = SugaryTreatsQuestion.instance.sugaryTreatsCount ?? 0.0;
    final sodasPerDay = SodasQuestion.instance.sodasCount ?? 0.0;
    final grainsPerDay = GrainsQuestion.instance.grainsCount ?? 0.0;

    final alcoholQuestion = AlcoholQuestion.instance;
    final alcoholPerWeek =
        alcoholQuestion.isPrivate ? 0.0 : (alcoholQuestion.alcoholCount ?? 0.0);

    featuresMap[NutritionConstants.sugaryTreatsPerDay] = treatsPerDay;
    featuresMap[NutritionConstants.sodasPerDay] = sodasPerDay;
    featuresMap[NutritionConstants.grainsPerDay] = grainsPerDay;
    featuresMap[NutritionConstants.alcoholPerWeek] = alcoholPerWeek;

    // Diet quality score starts at 100 and deducts based on intake patterns.
    double dietScore = NutritionConstants.baseDietScore;
    dietScore -= alcoholPerWeek * NutritionConstants.alcoholScoreDeduction;
    dietScore -= treatsPerDay * NutritionConstants.treatsScoreDeduction;
    dietScore -= sodasPerDay * NutritionConstants.sodasScoreDeduction;
    dietScore -= grainsPerDay * NutritionConstants.grainsScoreDeduction;

    featuresMap[NutritionConstants.dietQualityScore] = max(NutritionConstants.minimumDietScore, dietScore);
  }
}
