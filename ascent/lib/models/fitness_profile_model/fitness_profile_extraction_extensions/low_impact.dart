import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/age_question.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/demographics/gender_question.dart';

/// Extension to calculate joint health and low impact exercise metrics.
///
/// ❌ NOTE: This extractor is NOT in the source of truth design document.
/// ❌ No features should be extracted until this is added to __design_fitness_profile.txt
///
/// Source of truth: __design_fitness_profile.txt
extension LowImpact on FitnessProfile {

  /// Calculate joint health and low impact exercise metrics
  /// Currently disabled - no authorized features to extract
  void calculateLowImpact() {
    final age = AgeQuestion.instance.calculatedAge;
    final gender = GenderQuestion.instance.genderAnswer;

    if (age == null || gender == null) {
      throw Exception('Missing required answers for low impact calculation: age=$age, gender=$gender');
    }

    // NO FEATURES EXTRACTED - not in design document
    // All calculations removed until this extractor is authorized
  }
}