import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q6a_chair_stand_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4a_fall_history_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../../../constants_and_enums/constants.dart';

/// Extension to assess balance capacity and fall risk factors.
///
/// Balance assessment is separate from functional assessment - it focuses
/// specifically on fall risk and balance-related exercise needs.
extension Balance on FitnessProfile {

  /// Calculate balance capacity and fall risk features
  void calculateBalance() {
    _calculateChairStandCapacity();
    _calculateFallHistory();
    _calculateFallRiskFactors();
  }

  /// Extract chair stand ability for balance assessment
  void _calculateChairStandCapacity() {
    final canStandFromChair = Q6AChairStandQuestion.instance.canStandFromChair(answers);

    if (canStandFromChair == true) {
      featuresMap['can_do_chair_stand'] = 1.0;
    } else {
      // Treat unknown as unable for safety-first programming
      featuresMap['can_do_chair_stand'] = 0.0;
    }
  }

  /// Extract fall history from past 12 months
  void _calculateFallHistory() {
    final hasFallen = Q4AFallHistoryQuestion.instance.fallHistoryAnswer == AnswerConstants.yes;

    featuresMap['fall_history'] = hasFallen ? 1.0 : 0.0;
  }

  /// Calculate fall risk factors and fear of falling
  void _calculateFallRiskFactors() {
    final fallRiskFactors = Q4BFallRiskFactorsQuestion.instance.riskFactors
        .where((factor) => factor != AnswerConstants.none)
        .toList();

    // Count total risk factors
    featuresMap['fall_risk_factor_count'] = fallRiskFactors.length.toDouble();

    // Check for specific fear of falling
    final fearOfFalling = fallRiskFactors.contains(AnswerConstants.fearFalling);
    featuresMap['fear_of_falling'] = fearOfFalling ? 1.0 : 0.0;

    // Simple seated exercise flag derived from chair stand ability
    final canStand = featuresMap['can_do_chair_stand'] ?? 0.0;
    featuresMap['needs_seated_exercises'] = canStand == 0.0 ? 1.0 : 0.0;
  }
}
