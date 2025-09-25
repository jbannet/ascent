import 'dart:math';

import '../fitness_profile.dart';
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

    double alcoholPerWeek = 0.0;
    if (!AlcoholQuestion.instance.isPrivateAnswer(answers)) {
      alcoholPerWeek = (AlcoholQuestion.instance.alcoholCount ?? 0.0).toDouble();
    }

    featuresMap['sugary_treats_per_day'] = treatsPerDay;
    featuresMap['sodas_per_day'] = sodasPerDay;
    featuresMap['grains_per_day'] = grainsPerDay;
    featuresMap['alcohol_per_week'] = alcoholPerWeek;

    // Diet quality score starts at 100 and deducts based on intake patterns.
    double dietScore = 100.0;
    dietScore -= alcoholPerWeek * 4.0;
    dietScore -= treatsPerDay * 2.0;
    dietScore -= sodasPerDay * 2.0;
    dietScore -= grainsPerDay * 1.0;

    featuresMap['diet_quality_score'] = max(0.0, dietScore);
  }
}
