import '../fitness_profile.dart';
import '../../../constants_and_enums/constants_features.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/lifestyle/sedentary_job_question.dart';

/// Extension to evaluate sedentary lifestyle risk modifiers.
///
/// Sedentary behavior is a major mortality driver independent of exercise.
/// This extractor surfaces whether the user reports a sedentary job so the
/// recommendation layer can flag movement breaks or posture guidance.
extension SedentaryLifestyle on FitnessProfile {
  /// Calculate sedentary lifestyle features from onboarding answers.
  void calculateSedentaryLifestyle() {
    final hasSedentaryJob = SedentaryJobQuestion.instance.hasSedentaryJobFlag;
    featuresMap[SedentaryLifestyleConstants.sedentaryJob] = hasSedentaryJob ? SedentaryLifestyleConstants.hasSedentaryJob : SedentaryLifestyleConstants.noSedentaryJob;
  }
}
