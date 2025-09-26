import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/lifestyle/sleep_hours_question.dart';
import '../../../constants_and_enums/constants_features.dart';

/// Extension to capture sleep habits and recovery-related modifiers.
///
/// Sleep quantity is a foundational recovery pillar that influences training
/// readiness, recovery capacity, and injury risk. This extractor stores the
/// reported sleep hours so downstream recommendations can reference it.
extension SleepMetrics on FitnessProfile {
  /// Calculate sleep-related features from the onboarding survey.
  void calculateSleep() {
    final sleepHours = SleepHoursQuestion.instance.sleepHours;
    if (sleepHours != null) {
      featuresMap[SleepConstants.sleepHours] = sleepHours;
    }
  }
}
