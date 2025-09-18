import '../fitness_profile.dart';
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
    final fullSessionsPerWeek = SessionCommitmentQuestion.instance.getFullSessionDays(answers);
    featuresMap['full_sessions_per_week'] = fullSessionsPerWeek.toDouble();

    // Get the number of micro sessions (7-15 minutes) per week
    final microSessionsPerWeek = SessionCommitmentQuestion.instance.getMicroSessionDays(answers);
    featuresMap['micro_sessions_per_week'] = microSessionsPerWeek.toDouble();

    // Calculate total training days (accounts for potential overlap)
    final totalTrainingDays = SessionCommitmentQuestion.instance.getTotalTrainingDays(answers);
    featuresMap['total_training_days'] = totalTrainingDays.toDouble();

    // Calculate total weekly training time in minutes
    final weeklyTrainingMinutes = SessionCommitmentQuestion.instance.getWeeklyTrainingMinutes(answers);
    featuresMap['weekly_training_minutes'] = weeklyTrainingMinutes.toDouble();
  }
}