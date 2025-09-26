import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/lifestyle/stretching_days_question.dart';
import '../../../constants_and_enums/constants_features.dart';

/// Extension to calculate flexibility and stretching metrics.
///
/// This extension extracts ONLY the 1 authorized flexibility feature:
/// 1. days_stretching_per_week - Current stretching frequency
///
/// All other calculations are for internal use and NOT stored in featuresMap.
/// Source of truth: __design_fitness_profile.txt
extension Flexibility on FitnessProfile {
  /// Calculate flexibility and stretching metrics
  void calculateStretching() {
    final age = AgeQuestion.instance.calculatedAge;

    if (age == null) {
      throw Exception(
        'Missing required answer for stretching calculation: age=$age',
      );
    }

    // AUTHORIZED FEATURE 1: Current stretching frequency
    final currentStretchingDays =
        StretchingDaysQuestion.instance.stretchingDays ?? 0;
    featuresMap[FlexibilityConstants.daysStretchingPerWeek] = currentStretchingDays.toDouble();
  }
}