import '../fitness_profile.dart';
import 'package:ascent/constants_and_enums/constants_features.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/goals/fitness_goals_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/practical_constraints/q1_injuries_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/glp1_medications_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/weight_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/height_question.dart';
import '../../../constants_and_enums/constants.dart';

/// Extension to calculate relative importance across all exercise modalities.
///
/// This replaces individual importance calculations in each extension with a
/// unified system that ensures relative weighting based on user goals, needs,
/// and constraints. All importance scores sum to 1.0 across modalities.
///
/// Evidence-based scoring prioritizes:
/// 1. Goal alignment (primary driver)
/// 2. Individual needs/deficits
/// 3. Medical/safety considerations
/// 4. Age-related risk factors
extension RelativeImportance on FitnessProfile {
  /// Calculate relative importance for all exercise modalities
  void calculateRelativeImportance() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;

    if (age == null || gender == null) {
      throw Exception(
        'Missing required answers for importance calculation: age=$age, gender=$gender',
      );
    }

    // Calculate raw scores for each modality
    final Map<String, double> rawScores = {
      'cardio': _calculateCardioRawScore(age, gender),
      'strength': _calculateStrengthRawScore(age, gender),
      'balance': _calculateBalanceRawScore(age, gender),
      'functional': _calculateFunctionalRawScore(age, gender),
      'stretching': _calculateStretchingRawScore(age, gender),
    };

    // Normalize scores to sum to 1.0
    _normalizeImportanceScores(rawScores);
  }

  /// Calculate cardio raw importance score based on multiple evidence-based factors
  double _calculateCardioRawScore(int age, String gender) {
    double score = ObjectiveImportanceConstants.cardioBaseImportance; // Base importance for everyone

    // PRIMARY DRIVER: Goal alignment (strongest predictor of exercise adherence)
    final goalsRaw = FitnessGoalsQuestion.instance.fitnessGoals;
    final goals = goalsRaw.isEmpty ? [AnswerConstants.betterHealth] : goalsRaw;
    if (goals.contains(AnswerConstants.loseWeight)) score += ObjectiveImportanceConstants.loseWeightCardioBonus;
    if (goals.contains(AnswerConstants.improveEndurance)) score += ObjectiveImportanceConstants.improveEnduranceCardioBonus;
    if (goals.contains(AnswerConstants.betterHealth)) score += ObjectiveImportanceConstants.betterHealthCardioBonus;
    if (goals.contains(AnswerConstants.liveLonger)) score += ObjectiveImportanceConstants.liveLongerCardioBonus;

    // Current fitness gap (bigger gap = higher cardio need)
    final cardioPercentile = featuresMap[ObjectiveImportanceConstants.cardioFitnessPercentileKey];
    if (cardioPercentile != null && cardioPercentile < ObjectiveImportanceConstants.cardioFitnessGapThreshold) {
      score += (ObjectiveImportanceConstants.cardioFitnessGapThreshold - cardioPercentile) * ObjectiveImportanceConstants.cardioFitnessGapMultiplier; // Scale based on fitness gap
    }

    // Age-based cardiovascular disease risk (gradual, not exponential)
    if (age >= ObjectiveImportanceConstants.cardiovascularRiskAgeThreshold) {
      score += (age - ObjectiveImportanceConstants.cardiovascularRiskAgeThreshold) * ObjectiveImportanceConstants.cardioAgeRiskFactorPerYear; // +0.008 per year after 40 (modest)
    }

    // Current activity deficit
    // Activities removed - using performance metrics instead
    final List<String> activities = [];
    final hasCardio = activities.any(
      (a) => [
        AnswerConstants.runningJogging,
        AnswerConstants.cycling,
        AnswerConstants.swimming,
      ].contains(a),
    );
    if (!hasCardio) score += ObjectiveImportanceConstants.noCardioActivityBonus;

    // Gender-specific risk factors
    if (gender == AnswerConstants.female && age >= ObjectiveImportanceConstants.femaleMenopauseCardioAge) {
      score += ObjectiveImportanceConstants.femaleMenopauseCardioBonus; // Post-menopause cardiovascular risk
    }

    // GLP-1 medications - decrease cardio priority to favor strength training
    final isOnGlp1 = Glp1MedicationsQuestion.instance.isOnGlp1;
    if (isOnGlp1) score -= ObjectiveImportanceConstants.glp1CardioReduction;

    return score;
  }

  /// Calculate strength raw importance score
  double _calculateStrengthRawScore(int age, String gender) {
    double score =
        ObjectiveImportanceConstants.strengthBaseImportance; // Base importance (higher than cardio due to sarcopenia)

    // Goal alignment
    final goalsRaw = FitnessGoalsQuestion.instance.fitnessGoals;
    final goals = goalsRaw.isEmpty ? [AnswerConstants.betterHealth] : goalsRaw;
    if (goals.contains(AnswerConstants.buildMuscle)) score += ObjectiveImportanceConstants.buildMuscleStrengthBonus;
    if (goals.contains(AnswerConstants.betterHealth)) score += ObjectiveImportanceConstants.betterHealthStrengthBonus;
    if (goals.contains(AnswerConstants.liveLonger)) score += ObjectiveImportanceConstants.liveLongerStrengthBonus;

    // Sarcopenia risk (muscle loss with age)
    if (age >= ObjectiveImportanceConstants.sarcopeniaRiskAgeThreshold) {
      score += (age - ObjectiveImportanceConstants.sarcopeniaRiskAgeThreshold) * ObjectiveImportanceConstants.strengthAgeRiskFactorPerYear; // +0.01 per year after 30
    }

    // Gender-specific factors
    if (gender == AnswerConstants.female) {
      if (age >= ObjectiveImportanceConstants.femaleBoneMassDeclineAge) score += ObjectiveImportanceConstants.femaleBoneMassStrengthBonus; // Peak bone mass decline
      if (age >= ObjectiveImportanceConstants.femaleMenopauseStrengthAge) score += ObjectiveImportanceConstants.femaleMenopauseStrengthBonus; // Menopause acceleration
    }

    // Current strength activity deficit
    // Activities removed - using performance metrics instead
    final List<String> activities = [];
    final hasStrength = activities.contains(AnswerConstants.weightTraining);
    if (!hasStrength) score += ObjectiveImportanceConstants.noStrengthActivityBonus;

    // Experience level (beginners need more guidance)
    // Fitness level removed - using performance metrics instead
    final String? fitnessLevel = null;
    if (fitnessLevel == AnswerConstants.beginner) score += ObjectiveImportanceConstants.beginnerStrengthBonus;

    // GLP-1 medications - SIGNIFICANT increase due to muscle mass preservation needs
    final isOnGlp1 = Glp1MedicationsQuestion.instance.isOnGlp1;
    if (isOnGlp1) score += ObjectiveImportanceConstants.glp1StrengthBonus;

    // Low weight over 35 - muscle building priority
    if (age >= ObjectiveImportanceConstants.lowBmiStrengthAgeThreshold) {
      final weight = WeightQuestion.instance.weightPounds;
      final height = HeightQuestion.instance.heightInches;
      if (weight != null && height != null) {
        final bmi = (weight / (height * height)) * ObjectiveImportanceConstants.bmiConversionFactor; // BMI calculation
        if (bmi < ObjectiveImportanceConstants.lowBmiThreshold)
          score += ObjectiveImportanceConstants.lowBmiStrengthBonus; // Low BMI indicates need for muscle building
      }
    }

    return score;
  }

  /// Calculate balance raw importance score
  double _calculateBalanceRawScore(int age, String gender) {
    double score = ObjectiveImportanceConstants.balanceBaseImportance; // Low base importance for young adults

    // Fall history is absolute priority
    final hasFallen =
        Q4AFallHistoryQuestion.instance.fallHistoryAnswer ==
        AnswerConstants.yes;
    if (hasFallen) {
      return ObjectiveImportanceConstants.fallHistoryMaxPriority; // Maximum priority regardless of other factors
    }

    // Age-based fall risk (CDC/WHO evidence-based thresholds)
    if (age >= ObjectiveImportanceConstants.balanceCriticalRiskAge) {
      score += ObjectiveImportanceConstants.balanceCriticalRiskBonus; // Critical transition to high-risk
    } else if (age >= ObjectiveImportanceConstants.balanceModerateRiskAge) {
      score += ObjectiveImportanceConstants.balanceModerateRiskBonus;
    } else if (age >= ObjectiveImportanceConstants.balanceLowRiskAge) {
      score += ObjectiveImportanceConstants.balanceLowRiskBonus;
    }

    // Fall risk factors
    final fallRiskFactors = Q4BFallRiskFactorsQuestion.instance.riskFactors;
    if (fallRiskFactors.contains(AnswerConstants.balanceProblems)) score += ObjectiveImportanceConstants.balanceProblemsBonus;
    if (fallRiskFactors.contains(AnswerConstants.fearFalling)) score += ObjectiveImportanceConstants.fearFallingBonus;
    if (fallRiskFactors.contains(AnswerConstants.mobilityAids)) score += ObjectiveImportanceConstants.mobilityAidsBonus;

    // Gender adjustment (women have higher fall risk)
    if (gender == AnswerConstants.female && age >= ObjectiveImportanceConstants.femaleFallRiskAge) {
      score += ObjectiveImportanceConstants.femaleFallRiskBalanceBonus; // Menopause-related bone density changes
    }

    // Sedentary behavior increases fall risk
    // Fitness level removed - using performance metrics instead
    final String? fitnessLevel = null;
    if (fitnessLevel == AnswerConstants.beginner && age >= ObjectiveImportanceConstants.beginnerBalanceAgeThreshold) {
      score += ObjectiveImportanceConstants.beginnerBalanceBonus;
    }

    return score;
  }

  /// Calculate stretching/flexibility raw importance score
  double _calculateStretchingRawScore(int age, String gender) {
    double score = ObjectiveImportanceConstants.stretchingBaseImportance; // Moderate base importance

    // Goal alignment
    final goalsRaw = FitnessGoalsQuestion.instance.fitnessGoals;
    final goals = goalsRaw.isEmpty ? [AnswerConstants.betterHealth] : goalsRaw;
    if (goals.contains(AnswerConstants.increaseFlexibility)) score += ObjectiveImportanceConstants.increaseFlexibilityStretchingBonus;
    if (goals.contains(AnswerConstants.betterHealth)) score += ObjectiveImportanceConstants.betterHealthStretchingBonus;

    // Age-based flexibility decline
    if (age >= ObjectiveImportanceConstants.flexibilityDeclineAgeThreshold) {
      score += (age - ObjectiveImportanceConstants.flexibilityDeclineAgeThreshold) * ObjectiveImportanceConstants.flexibilityAgeRiskFactorPerYear; // +0.005 per year after 30 (gradual)
    }

    // Injury history indicates need for flexibility
    final injuries = Q1InjuriesQuestion.instance.injuries;
    final painAreas = Q1InjuriesQuestion.instance.painAreas;
    if (injuries.isNotEmpty || painAreas.isNotEmpty) {
      score += ObjectiveImportanceConstants.injuryHistoryFlexibilityBonus; // Injury recovery/prevention
    }

    // Current activity level
    // Activities removed - using performance metrics instead
    final List<String> activities = [];
    final hasFlexibility = activities.contains(AnswerConstants.yoga);
    if (!hasFlexibility) score += ObjectiveImportanceConstants.noFlexibilityActivityBonus;

    // Sedentary lifestyle increases stiffness
    // Fitness level removed - using performance metrics instead
    final String? fitnessLevel = null;
    if (fitnessLevel == AnswerConstants.beginner) score += ObjectiveImportanceConstants.beginnerFlexibilityBonus;

    return score;
  }

  /// Calculate functional fitness raw importance score
  double _calculateFunctionalRawScore(int age, String gender) {
    double score = ObjectiveImportanceConstants.functionalBaseImportanceUnder50; // Start at zero

    // Under 50: Only get functional if they have actual deficits
    if (age < ObjectiveImportanceConstants.functionalTrainingYoungThreshold) {
      // Fall history increases functional need
      final hasFallen =
          Q4AFallHistoryQuestion.instance.fallHistoryAnswer ==
          AnswerConstants.yes;
      if (hasFallen) {
        score += ObjectiveImportanceConstants.fallHistoryYoungFunctionalBonus; // Moderate functional need for young people with falls
      }

      // Chair stand difficulty is critical functional marker
      final canStandFromChair =
          Q6AChairStandQuestion.instance.canStandFromChairValue;
      if (canStandFromChair == false) {
        score += ObjectiveImportanceConstants.chairStandDeficitYoungFunctionalBonus; // High priority for basic function restoration
      }

      return score.clamp(ObjectiveImportanceConstants.functionalScoreClampMin, ObjectiveImportanceConstants.functionalScoreClampMax);
    }

    // 50+: Base functional importance starts
    score = ObjectiveImportanceConstants.functionalBaseImportance50Plus; // Small base for 50+

    // AGE PROGRESSION (functional fitness becomes critical with age)
    if (age >= ObjectiveImportanceConstants.functionalTrainingAge80Plus) {
      score += ObjectiveImportanceConstants.functionalAge80PlusBonus; // Highest priority for 80+
    } else if (age >= ObjectiveImportanceConstants.functionalTrainingAge70Plus) {
      score += ObjectiveImportanceConstants.functionalAge70PlusBonus; // Very high priority for 70s
    } else if (age >= ObjectiveImportanceConstants.functionalTrainingAge65Plus) {
      score += ObjectiveImportanceConstants.functionalAge65PlusBonus; // High priority at retirement age
    } else if (age >= ObjectiveImportanceConstants.functionalTrainingAge60Plus) {
      score += ObjectiveImportanceConstants.functionalAge60PlusBonus; // Increasing importance
    } else if (age >= ObjectiveImportanceConstants.functionalTrainingAge55Plus) {
      score += ObjectiveImportanceConstants.functionalAge55PlusBonus; // Starting to matter more
    }

    // DEFICIT MARKERS (regardless of age)
    // Fall history massively increases functional importance
    final hasFallen =
        Q4AFallHistoryQuestion.instance.fallHistoryAnswer ==
        AnswerConstants.yes;
    if (hasFallen) {
      score += ObjectiveImportanceConstants.fallHistoryFunctionalBonus; // Falls indicate serious functional deficits
    }

    // Chair stand inability is critical functional marker
    final canStandFromChair =
        Q6AChairStandQuestion.instance.canStandFromChairValue;
    if (canStandFromChair == false) {
      score += ObjectiveImportanceConstants.chairStandDeficitFunctionalBonus; // Maximum priority for basic function restoration
    }

    // OTHER RISK FACTORS for 50+
    // Gender adjustment (women have higher ADL disability rates)
    if (gender == AnswerConstants.female && age >= ObjectiveImportanceConstants.femaleFunctionalRiskAge) {
      score += ObjectiveImportanceConstants.femaleFunctionalRiskBonus;
    }

    // Health goals for older adults
    final goalsRaw = FitnessGoalsQuestion.instance.fitnessGoals;
    final goals = goalsRaw.isEmpty ? [AnswerConstants.betterHealth] : goalsRaw;
    if (goals.contains(AnswerConstants.betterHealth) && age >= ObjectiveImportanceConstants.functionalHealthGoalsAgeThreshold) {
      score += ObjectiveImportanceConstants.betterHealthFunctionalBonus; // Health-focused older adults need functional training
    }

    return score.clamp(ObjectiveImportanceConstants.functionalScoreClampMin, ObjectiveImportanceConstants.functionalScoreClampMax);
  }

  /// Normalize raw scores so they sum to 1.0 (true relative importance)
  void _normalizeImportanceScores(Map<String, double> rawScores) {
    final double total = rawScores.values.reduce((a, b) => a + b);

    if (total <= 0) {
      // Fallback to equal weighting if no scores
      rawScores.forEach((key, _) => rawScores[key] = ObjectiveImportanceConstants.equalWeightingFallback);
      return;
    }

    // Normalize and store in featuresMap using proper constants
    featuresMap[FeatureConstants.categoryCardio] = rawScores['cardio']! / total;
    featuresMap[FeatureConstants.categoryStrength] =
        rawScores['strength']! / total;
    featuresMap[FeatureConstants.categoryBalance] =
        rawScores['balance']! / total;
    featuresMap[FeatureConstants.categoryStretching] =
        rawScores['stretching']! / total;
    featuresMap[FeatureConstants.categoryFunctional] =
        rawScores['functional']! / total;
  }
}
