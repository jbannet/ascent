import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/practical_constraints/q1_injuries_question.dart';
import '../../../constants_and_enums/constants.dart';

/// Extension to assess injury status and exercise modifications.
///
/// Uses integer scoring system in a separate injuries vector:
/// - BodyPartConstants.noIssue (0): No issue with this body part
/// - BodyPartConstants.avoid (-MAX_INT): Injured - NEVER use this body part in exercises
/// - BodyPartConstants.strengthen (50): Pain area - strengthen surrounding muscles
extension Injuries on FitnessProfile {
  /// Calculate injury status for all body parts
  void calculateInjuries() {
    final injuries = Q1InjuriesQuestion.instance.injuries;
    final painAreas = Q1InjuriesQuestion.instance.painAreas;

    // Initialize all body parts to no issue in injuries vector
    _initializeInjuriesVector();

    // Set injured parts to avoid
    for (final injury in injuries) {
      _setInjuryScore(injury, isInjury: true);
    }

    // Set pain areas to strengthen
    for (final painArea in painAreas) {
      _setInjuryScore(painArea, isInjury: false);
    }
  }

  /// Initialize all body parts to no issue in injuries vector
  void _initializeInjuriesVector() {
    // Initialize injuries map if it doesn't exist
    if (injuriesMap == null) {
      injuriesMap = <String, int>{};
    }

    for (final part in BodyPartConstants.allBodyParts) {
      injuriesMap![part] = BodyPartConstants.noIssue;
    }
  }

  /// Set injury or pain score for body parts in injuries vector
  void _setInjuryScore(String bodyPart, {required bool isInjury}) {
    if (injuriesMap == null) {
      injuriesMap = <String, int>{};
    }

    if (isInjury) {
      // Injury = avoid this body part completely
      injuriesMap![bodyPart] = BodyPartConstants.avoid;
    } else {
      // Pain = strengthen surrounding muscles
      injuriesMap![bodyPart] = BodyPartConstants.strengthen;
    }
  }
}
