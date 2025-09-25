import '../fitness_profile.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/lifestyle/sedentary_job_question.dart';

/// Extension to evaluate sedentary lifestyle risk modifiers.
///
/// Sedentary behavior is a major mortality driver independent of exercise.
/// This extractor surfaces whether the user reports a sedentary job so the
/// recommendation layer can flag movement breaks or posture guidance.
extension SedentaryLifestyle on FitnessProfile {

  /// Calculate sedentary lifestyle features from onboarding answers.
  void calculateSedentaryLifestyle() {
    final hasSedentaryJob = SedentaryJobQuestion.instance.hasSedentaryJob(answers);
    featuresMap['sedentary_job'] = hasSedentaryJob ? 1.0 : 0.0;
  }
}
