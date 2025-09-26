import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4_run_vo2_question.dart';
import '../../../constants_and_enums/constants_features.dart';

/// Extension to assess functional movement capacity and daily activity capabilities.
///
/// This is PRIORITY 1 (Critical Safety) assessment that determines functional
/// training needs vs fitness training focus.
///
/// The key calculation is prioritize_functional which determines what percentage
/// of the training plan should focus on functional movements vs performance fitness.
extension Functional on FitnessProfile {
  /// Calculate functional movement priorities
  void calculateFunctional() {
    final age = AgeQuestion.instance.calculatedAge;

    if (age == null) {
      throw Exception(
        'Missing required answers for functional calculation: age=$age',
      );
    }

    _calculatePrioritizeFunctional(age);
  }

  /// Calculate the prioritize_functional score
  /// This determines how much to weight functional vs fitness training
  void _calculatePrioritizeFunctional(int age) {
    double functionalScore = 0.0;

    // Age component: 70+ automatically gets functional focus
    if (age >= FunctionalConstants.elderlyAgeThreshold) {
      functionalScore += FunctionalConstants.elderlyFunctionalScore;
    }

    // Chair stand component: Can't stand without arms = needs functional work
    final canStandFromChair =
        Q6AChairStandQuestion.instance.canStandFromChairValue;
    if (canStandFromChair == false) {
      functionalScore += FunctionalConstants.chairStandDeficitScore;
    }

    // Walking pace component: < 2 mph indicates functional limitation
    final runData = Q4TwelveMinuteRunQuestion.instance.runPerformanceData;
    if (runData != null && runData.timeMinutes > 0) {
      final paceMph = (runData.distanceMiles / runData.timeMinutes) * FunctionalConstants.minutesPerHour;
      if (paceMph < FunctionalConstants.slowWalkingPaceThreshold) {
        functionalScore += FunctionalConstants.slowWalkingPaceScore;
      }
    }

    featuresMap[FunctionalConstants.prioritizeFunctional] = functionalScore;
  }
}
