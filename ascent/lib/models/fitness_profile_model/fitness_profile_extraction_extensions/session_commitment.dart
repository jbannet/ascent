import '../fitness_profile.dart';
import 'package:ascent/constants_and_enums/constants_features.dart';
import '../../../workflow_views/onboarding_workflow/question_bank/questions/fitness_assessment/session_commitment_question.dart';

/// Extension to extract session commitment metrics from user preferences.
///
/// This extension captures user's commitment to different session types:
/// 1. FULL SESSIONS: 30-60 minute traditional workouts per week
/// 2. MICRO SESSIONS: 7-15 minute fitness snacks per week
/// 3. DERIVED METRICS: Total training days and weekly minutes
///
/// These metrics are essential for workout planning and program design.
extension SessionCommitment on FitnessProfile {
  /// Extract session commitment data from user answers
  void calculateSessionCommitment() {
    // Get the number of full sessions (30-60 minutes) per week
    final commitmentQuestion = SessionCommitmentQuestion.instance;

    final fullSessionsPerWeek = commitmentQuestion.fullSessionsPerWeek;
    featuresMap[FeatureConstants.fullSessionsPerWeek] =
        fullSessionsPerWeek.toDouble();

    // Get the number of micro sessions (7-15 minutes) per week
    final microSessionsPerWeek = commitmentQuestion.microSessionsPerWeek;
    featuresMap[FeatureConstants.microSessionsPerWeek] =
        microSessionsPerWeek.toDouble();

    // Calculate total training days (accounts for potential overlap)
    final totalTrainingDays = commitmentQuestion.totalTrainingDaysPerWeek;
    featuresMap[FeatureConstants.totalTrainingDays] =
        totalTrainingDays.toDouble();

    // Calculate total weekly training time in minutes
    final weeklyTrainingMinutes = commitmentQuestion.weeklyTrainingMinutes;
    featuresMap[FeatureConstants.weeklyTrainingMinutes] =
        weeklyTrainingMinutes.toDouble();
  }
}
