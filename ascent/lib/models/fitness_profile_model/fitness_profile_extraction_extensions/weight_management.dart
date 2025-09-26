import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/weight_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/height_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/goals/fitness_goals_question.dart';
import '../../../constants_and_enums/constants.dart';
import '../../../constants_and_enums/constants_features.dart';

/// Extension to calculate weight management metrics.
///
/// This extension focuses on extracting ONLY the 5 authorized weight management features:
/// 1. weight_pounds - Raw weight measurement
/// 2. height_inches - Raw height measurement
/// 3. bmi - Body Mass Index calculation
/// 4. weight_objective - Primary goal (lose/gain/maintain)
/// 5. needs_weight_loss - Boolean flag for BMI > 25
///
/// All other calculations are for internal use and NOT stored in featuresMap.
/// Source of truth: __design_fitness_profile.txt
extension WeightManagement on FitnessProfile {
  /// Calculate weight management metrics
  void calculateWeightManagement() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;
    final weightQuestion = WeightQuestion.instance;
    final heightQuestion = HeightQuestion.instance;
    final goalsQuestion = FitnessGoalsQuestion.instance;

    final weight = weightQuestion.weightPounds;
    final height = heightQuestion.heightInches;
    final goalsRaw = goalsQuestion.fitnessGoals;
    final goals = goalsRaw.isEmpty ? [AnswerConstants.betterHealth] : goalsRaw;

    // Only proceed if we have both weight and height data
    if (weight == null || height == null) {
      return; // No weight data available
    }

    if (age == null || gender == null) {
      throw Exception(
        'Missing required answers for weight management calculation: age=$age, gender=$gender',
      );
    }

    // AUTHORIZED FEATURE 1: Store raw weight
    featuresMap[WeightManagementConstants.weightPounds] = weight;

    // AUTHORIZED FEATURE 2: Store raw height
    featuresMap[WeightManagementConstants.heightInches] = height;

    // AUTHORIZED FEATURE 3: Calculate and store BMI
    final bmi = _calculateBMI(weight, height);
    featuresMap[WeightManagementConstants.bmi] = bmi;

    // AUTHORIZED FEATURE 4: Determine weight objective based on goals
    final weightObjective = _determineWeightObjective(goals, bmi);
    featuresMap[WeightManagementConstants.weightObjective] = weightObjective;

    // AUTHORIZED FEATURE 5: Set needs weight loss flag (BMI > 25)
    final needsWeightLoss = bmi > WeightManagementConstants.overweightCutoff;
    featuresMap[WeightManagementConstants.needsWeightLoss] = needsWeightLoss ? WeightManagementConstants.flagTrue : WeightManagementConstants.flagFalse;
  }

  /// Calculate BMI from weight and height
  double _calculateBMI(double weightPounds, double heightInches) {
    // Convert to metric for BMI calculation
    final weightKg = weightPounds * WeightManagementConstants.poundsToKgConversion;
    final heightM = heightInches * WeightManagementConstants.inchesToMeterConversion;

    // Calculate BMI
    return weightKg / (heightM * heightM);
  }

  /// Determine primary weight objective based on goals and BMI
  double _determineWeightObjective(List<String> goals, double bmi) {
    final hasWeightLossGoal = goals.contains(AnswerConstants.loseWeight);
    final hasMuscleGainGoal = goals.contains(AnswerConstants.buildMuscle);

    // Priority: Explicit goals override BMI-based recommendations
    if (hasWeightLossGoal) {
      return WeightManagementConstants.weightLossObjective;
    } else if (hasMuscleGainGoal) {
      return WeightManagementConstants.weightGainObjective;
    } else {
      // Default to maintenance
      return WeightManagementConstants.weightMaintenanceObjective;
    }
  }
}