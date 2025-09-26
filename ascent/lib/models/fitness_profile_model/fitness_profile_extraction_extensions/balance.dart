import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../../../constants_and_enums/constants.dart';
import '../../../constants_and_enums/constants_features.dart';

/// Extension to assess balance capacity and fall risk factors.
///
/// This extension extracts ONLY the 5 authorized balance features:
/// 1. can_do_chair_stand - Boolean flag for chair stand ability
/// 2. fall_history - Boolean flag for fall history in past 12 months
/// 3. fall_risk_factor_count - Count of total risk factors
/// 4. fear_of_falling - Boolean flag for fear of falling
/// 5. needs_seated_exercises - Boolean flag derived from chair stand ability
///
/// All other calculations are for internal use and NOT stored in featuresMap.
/// Source of truth: __design_fitness_profile.txt
extension Balance on FitnessProfile {
  /// Calculate balance and fall risk features
  void calculateBalance() {
    _calculateChairStandCapacity();
    _calculateFallHistory();
    _calculateFallRiskFactors();
  }

  /// Extract chair stand ability for balance assessment
  void _calculateChairStandCapacity() {
    final canStandFromChair =
        Q6AChairStandQuestion.instance.canStandFromChairValue;

    if (canStandFromChair == true) {
      featuresMap[BalanceConstants.canDoChairStand] = BalanceConstants.flagTrue;
    } else {
      // Treat unknown as unable for safety-first programming
      featuresMap[BalanceConstants.canDoChairStand] = BalanceConstants.flagFalse;
    }
  }


  /// Extract fall history from past 12 months
  void _calculateFallHistory() {
    final hasFallen =
        Q4AFallHistoryQuestion.instance.fallHistoryAnswer ==
        AnswerConstants.yes;

    featuresMap[BalanceConstants.fallHistory] = hasFallen ? BalanceConstants.flagTrue : BalanceConstants.flagFalse;
  }

  /// Calculate fall risk factors and fear of falling
  void _calculateFallRiskFactors() {
    final fallRiskFactors =
        Q4BFallRiskFactorsQuestion.instance.riskFactors
            .where((factor) => factor != AnswerConstants.none)
            .toList();

    // Count total risk factors
    featuresMap[BalanceConstants.fallRiskFactorCount] = fallRiskFactors.length.toDouble();

    // Check for specific fear of falling
    final fearOfFalling = fallRiskFactors.contains(AnswerConstants.fearFalling);
    featuresMap[BalanceConstants.fearOfFalling] = fearOfFalling ? BalanceConstants.flagTrue : BalanceConstants.flagFalse;

    // Simple seated exercise flag derived from chair stand ability
    final canStand =
        Q6AChairStandQuestion.instance.canStandFromChairValue ??
        (featuresMap[BalanceConstants.canDoChairStand] == BalanceConstants.flagTrue);
    featuresMap[BalanceConstants.needsSeatedExercises] = canStand == false ? BalanceConstants.flagTrue : BalanceConstants.flagFalse;
  }
}
