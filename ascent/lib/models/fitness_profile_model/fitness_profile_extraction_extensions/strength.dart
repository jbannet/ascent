import '../fitness_profile.dart';
import '../reference_data/acsm_pushup_norms.dart';
import '../reference_data/acsm_squat_norms.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q5_pushups_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6_bodyweight_squats_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../constants_and_enums/constants.dart';
import '../../../constants_and_enums/constants_features.dart';

/// Extension to calculate strength fitness metrics and training parameters.
///
/// This extension focuses on core strength metrics:
/// 1. STRENGTH FITNESS BASELINE: Current fitness level metrics
///    - Push-up performance percentile (ACSM norms)
///    - Equivalent strength age based on performance
///    - Muscle endurance capacity
///
/// 2. WORKOUT CONSTRUCTION PARAMETERS: Values needed to build strength workouts
///    - Recovery requirements between sessions
///    - Training volume tolerance
///    - Age-related strength decline factors
///
/// References:
/// - ACSM's Guidelines for Exercise Testing and Prescription, 11th Edition (2021)
/// - Schoenfeld et al. (2019) "Resistance Training Volume Enhances Muscle Hypertrophy" - Sports Medicine
/// - Grgic et al. (2018) "Effects of Rest Interval Duration in Resistance Training" - Sports Medicine
/// - Cruz-Jentoft et al. (2019) "Sarcopenia: revised European consensus" - Age and Ageing
///
/// Note: Strength importance is calculated in relative_objective_importance.dart
extension Strength on FitnessProfile {
  /// Calculate strength fitness metrics and training parameters
  void calculateStrength() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;

    if (age == null || gender == null) {
      throw Exception(StrengthConstants.missingAgeGenderError.replaceAll('\$age', '$age').replaceAll('\$gender', '$gender'));
    }

    // 1. Calculate baseline fitness metrics
    _calculateStrengthBaseline(age, gender);

    // 2. Calculate workout parameters
    _calculateStrengthWorkoutParameters(age, gender);
  }

  /// Calculate baseline strength metrics from push-up and squat assessments
  void _calculateStrengthBaseline(int age, String gender) {
    double? upperBodyPercentile;
    double? lowerBodyPercentile;

    // UPPER BODY: Use push-up test if available
    final pushupsQuestion = Q5PushupsQuestion.instance;
    final pushupCount = pushupsQuestion.pushupsCount?.toInt();
    if (pushupCount != null && pushupCount >= 0) {
      upperBodyPercentile = ACSMPushupNorms.getPercentile(
        pushupCount,
        age,
        gender,
      );
      featuresMap[StrengthConstants.upperBodyStrengthPercentile] = upperBodyPercentile;

      // Store raw push-up performance
      featuresMap[StrengthConstants.pushupCount] = pushupCount.toDouble();
    }

    // LOWER BODY: Use squat test if available
    final squatQuestion = Q6BodyweightSquatsQuestion.instance;
    final squatCount = squatQuestion.squatsCount?.toInt();
    if (squatCount != null && squatCount >= 0) {
      // Store raw squat performance
      featuresMap[StrengthConstants.squatCount] = squatCount.toDouble();

      if (squatCount == 0) {
        // Cannot do squats - check chair stand ability for functional assessment
        final canStandFromChair =
            Q6AChairStandQuestion.instance.canStandFromChairValue;

        if (canStandFromChair == true) {
          // Can do chair stand but not squats - basic functional strength
          lowerBodyPercentile = StrengthConstants.veryLowButFunctionalPercentile;
          featuresMap[StrengthConstants.lowerBodyStrengthPercentile] = lowerBodyPercentile;
          featuresMap[StrengthConstants.functionalStrengthLevel] = StrengthConstants.basicFunctionalLevel;
          featuresMap[StrengthConstants.needsBasicStrength] = StrengthConstants.flagTrue;
          featuresMap[StrengthConstants.needsFunctionalTraining] = StrengthConstants.flagTrue;
          featuresMap[StrengthConstants.needsSeatedExercises] = StrengthConstants.flagFalse;
          featuresMap[StrengthConstants.canDoChairStand] = StrengthConstants.flagTrue;
        } else if (canStandFromChair == false) {
          // Cannot do chair stand - no functional strength
          lowerBodyPercentile = StrengthConstants.flagFalse;
          featuresMap[StrengthConstants.lowerBodyStrengthPercentile] = lowerBodyPercentile;
          featuresMap[StrengthConstants.functionalStrengthLevel] = StrengthConstants.noFunctionalLevel;
          featuresMap[StrengthConstants.needsBasicStrength] = StrengthConstants.flagTrue;
          featuresMap[StrengthConstants.needsFunctionalTraining] = StrengthConstants.flagTrue;
          featuresMap[StrengthConstants.needsSeatedExercises] = StrengthConstants.flagTrue;
          featuresMap[StrengthConstants.canDoChairStand] = StrengthConstants.flagFalse;

          // Add fall risk modifier
          featuresMap[StrengthConstants.fallRiskModifier] = StrengthConstants.fallRiskModifierValue;
        } else {
          // Chair stand question not answered (shouldn't happen with condition)
          // Use conservative estimates
          lowerBodyPercentile = StrengthConstants.conservativeEstimatePercentile;
          featuresMap[StrengthConstants.lowerBodyStrengthPercentile] = lowerBodyPercentile;
          featuresMap[StrengthConstants.needsFunctionalTraining] = StrengthConstants.flagTrue;
        }
      } else {
        // Can do squats - use normal percentile calculation
        lowerBodyPercentile = ACSMSquatNorms.getPercentile(
          squatCount,
          age,
          gender,
        );
        featuresMap[StrengthConstants.lowerBodyStrengthPercentile] = lowerBodyPercentile;

        // Check if needs functional training
        featuresMap[StrengthConstants.needsFunctionalTraining] =
            ACSMSquatNorms.needsFunctionalTraining(squatCount, age) ? StrengthConstants.flagTrue : StrengthConstants.flagFalse;

        // They can do squats, so they don't need seated exercises
        featuresMap[StrengthConstants.needsSeatedExercises] = StrengthConstants.flagFalse;
        featuresMap[StrengthConstants.canDoChairStand] =
            StrengthConstants.flagTrue; // If can squat, can definitely do chair stand

        // Set functional strength level based on squat count
        if (squatCount >= StrengthConstants.fullFunctionalSquats) {
          featuresMap[StrengthConstants.functionalStrengthLevel] = StrengthConstants.fullFunctionalLevel;
        } else if (squatCount >= StrengthConstants.goodFunctionalSquats) {
          featuresMap[StrengthConstants.functionalStrengthLevel] = StrengthConstants.goodFunctionalLevel;
        } else if (squatCount >= StrengthConstants.moderateFunctionalSquats) {
          featuresMap[StrengthConstants.functionalStrengthLevel] = StrengthConstants.moderateFunctionalLevel;
        } else {
          featuresMap[StrengthConstants.functionalStrengthLevel] = StrengthConstants.basicFunctionalLevel;
        }
      }
    }

    // OVERALL STRENGTH: Combine upper and lower body if both available
    if (upperBodyPercentile != null && lowerBodyPercentile != null) {
      // Weighted average: lower body slightly more important for functional fitness
      featuresMap[StrengthConstants.strengthFitnessPercentile] =
          (upperBodyPercentile * StrengthConstants.upperBodyWeight + lowerBodyPercentile * StrengthConstants.lowerBodyWeight);
    } else if (upperBodyPercentile != null) {
      // Only upper body data available
      featuresMap[StrengthConstants.strengthFitnessPercentile] = upperBodyPercentile;
    } else if (lowerBodyPercentile != null) {
      // Only lower body data available
      featuresMap[StrengthConstants.strengthFitnessPercentile] = lowerBodyPercentile;
    }
  }

  /// Calculate strength training parameters based on scientific evidence
  void _calculateStrengthWorkoutParameters(int age, String gender) {
    // Recovery time between strength sessions
    // Based on: Schoenfeld et al. (2016) "Effects of Resistance Training Frequency" - Sports Medicine
    // - Younger individuals: 48 hours for muscle protein synthesis
    // - Middle-aged: 48-72 hours due to slower recovery
    // - Older adults: 72-96 hours for complete recovery
    if (age < StrengthConstants.youngAdultAgeThreshold) {
      featuresMap[StrengthConstants.strengthRecoveryHours] = StrengthConstants.youngAdultRecoveryHours;
    } else if (age < StrengthConstants.olderAdultThreshold) {
      featuresMap[StrengthConstants.strengthRecoveryHours] = StrengthConstants.middleAgedRecoveryHours;
    } else {
      featuresMap[StrengthConstants.strengthRecoveryHours] = StrengthConstants.olderAdultRecoveryHours;
    }

    // Calculate all training parameters
    _calculateTrainingParameters(age);
  }

  /// Calculate all strength training parameters
  void _calculateTrainingParameters(int age) {
    final strengthPercentile =
        featuresMap[StrengthConstants.strengthFitnessPercentile] as double? ?? StrengthConstants.defaultStrengthPercentile;

    // Optimal rep ranges based on age
    if (age >= StrengthConstants.middleAgedThreshold || strengthPercentile < StrengthConstants.belowAveragePercentile) {
      featuresMap[StrengthConstants.strengthOptimalRepRangeMin] = StrengthConstants.beginnerRepRangeMin;
      featuresMap[StrengthConstants.strengthOptimalRepRangeMax] = StrengthConstants.beginnerRepRangeMax;
    } else {
      featuresMap[StrengthConstants.strengthOptimalRepRangeMin] = StrengthConstants.intermediateRepRangeMin;
      featuresMap[StrengthConstants.strengthOptimalRepRangeMax] = StrengthConstants.intermediateRepRangeMax;
    }

    // Time between sets (seconds)
    if (age >= StrengthConstants.olderAdultThreshold) {
      featuresMap[StrengthConstants.strengthTimeBetweenSets] =
          StrengthConstants.olderAdultRestTime; // 30-60 sec range, use middle
    } else if (strengthPercentile > StrengthConstants.aboveAveragePercentile) {
      featuresMap[StrengthConstants.strengthTimeBetweenSets] =
          StrengthConstants.strengthPowerRestTime; // 2.5 min for strength/power
    } else {
      featuresMap[StrengthConstants.strengthTimeBetweenSets] =
          StrengthConstants.hypertrophyRestTime; // 1.5 min for hypertrophy
    }

    // Percent of 1RM
    if (age >= StrengthConstants.middleAgedThreshold && strengthPercentile < StrengthConstants.averagePercentile) {
      featuresMap[StrengthConstants.strengthPercentOf1RM] = StrengthConstants.olderNovice1RMPercent; // 40-50% for older novice
    } else if (strengthPercentile < StrengthConstants.belowAveragePercentile) {
      featuresMap[StrengthConstants.strengthPercentOf1RM] = StrengthConstants.veryWeak1RMPercent; // Very weak, focus on form
    } else if (strengthPercentile > StrengthConstants.aboveAveragePercentile) {
      featuresMap[StrengthConstants.strengthPercentOf1RM] = StrengthConstants.experiencedLifter1RMPercent; // Experienced lifters
    } else {
      featuresMap[StrengthConstants.strengthPercentOf1RM] =
          StrengthConstants.noviceIntermediate1RMPercent; // 50-60% novice to intermediate
    }

    // Optimal sets range
    if (strengthPercentile < StrengthConstants.veryLowPercentile) {
      featuresMap[StrengthConstants.strengthOptimalSetsRangeMin] =
          StrengthConstants.beginnerSetsMin; // 1-3 sets, learning form
      featuresMap[StrengthConstants.strengthOptimalSetsRangeMax] = StrengthConstants.beginnerSetsMax;
    } else if (strengthPercentile > StrengthConstants.aboveAveragePercentile) {
      featuresMap[StrengthConstants.strengthOptimalSetsRangeMin] =
          StrengthConstants.advancedSetsMin; // 3-5 sets for advanced
      featuresMap[StrengthConstants.strengthOptimalSetsRangeMax] = StrengthConstants.advancedSetsMax;
    } else {
      featuresMap[StrengthConstants.strengthOptimalSetsRangeMin] = StrengthConstants.normalSetsMin; // 2-4 sets normal
      featuresMap[StrengthConstants.strengthOptimalSetsRangeMax] = StrengthConstants.normalSetsMax;
    }
  }
}
