import 'onboarding_status.dart';

/// Tracks the current state of an onboarding session.
/// 
/// This model maintains the user's current position in the onboarding flow,
/// including which question they're on, their progress, and the overall status.
/// It's designed to be immutable, using copyWith pattern for updates.
/// 
/// Key responsibilities:
/// - Track current question and section indices
/// - Calculate and store progress percentage
/// - Manage onboarding status transitions
/// - Support navigation (next/previous question)
/// 
/// State transitions:
/// 1. Starts with initial() - status: notStarted, progress: 0%
/// 2. First question sets status to inProgress
/// 3. Navigation updates indices and recalculates progress
/// 4. Completion sets status to completed, progress: 100%
/// 
/// Used by:
/// - [OnboardingProvider] to manage navigation state
/// - UI to display current question and progress
/// - Navigation logic to determine valid actions
/// - Analytics to track user progress through onboarding
class OnboardingState {
  /// ID of the currently displayed question.
  /// Null when onboarding hasn't started yet.
  /// Used for quick lookup and analytics tracking.
  final String? currentQuestionId;
  
  /// Index of the current section (0-based).
  /// Used for section-level navigation and progress display.
  final int currentSectionIndex;
  
  /// Index of the current question within the section (0-based).
  /// Combined with currentSectionIndex to locate exact position.
  final int currentQuestionIndex;
  
  /// Current status of the onboarding process.
  /// Transitions: notStarted -> inProgress -> completed
  final OnboardingStatus status;
  
  /// Percentage of onboarding completed (0.0 to 100.0).
  /// Based on answered questions vs. total visible questions.
  /// Updates dynamically as conditions hide/show questions.
  final double progressPercentage;

  OnboardingState({
    this.currentQuestionId,
    required this.currentSectionIndex,
    required this.currentQuestionIndex,
    required this.status,
    required this.progressPercentage,
  });

  /// Creates a copy with updated fields.
  /// 
  /// Follows immutable state pattern for predictable updates.
  /// Used by all state transition methods.
  OnboardingState copyWith({
    String? currentQuestionId,
    int? currentSectionIndex,
    int? currentQuestionIndex,
    OnboardingStatus? status,
    double? progressPercentage,
  }) {
    return OnboardingState(
      currentQuestionId: currentQuestionId ?? this.currentQuestionId,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  /// Creates the initial state for a new onboarding session.
  /// 
  /// Sets all indices to 0, status to notStarted, and progress to 0%.
  /// This is the starting point before any questions are shown.
  /// 
  /// Used by OnboardingProvider.initialize() to reset state.
  factory OnboardingState.initial() {
    return OnboardingState(
      currentQuestionId: null,
      currentSectionIndex: 0,
      currentQuestionIndex: 0,
      status: OnboardingStatus.notStarted,
      progressPercentage: 0.0,
    );
  }

  /// Updates the progress percentage based on answered questions.
  /// 
  /// [totalQuestions] is the count of all visible questions.
  /// [answeredQuestions] is the count of questions with answers.
  /// 
  /// Returns a new state with updated progress percentage.
  /// 
  /// Used by OnboardingProvider._updateProgress() after each answer.
  OnboardingState withProgress(int totalQuestions, int answeredQuestions) {
    final percentage = totalQuestions > 0
        ? (answeredQuestions / totalQuestions) * 100
        : 0.0;
    return copyWith(progressPercentage: percentage);
  }

  /// Transitions state to the next question.
  /// 
  /// Updates current question ID and indices, and sets status to inProgress
  /// if it was notStarted. This method is called when user proceeds forward.
  /// 
  /// Parameters:
  /// - [questionId]: ID of the next question to display
  /// - [sectionIndex]: Section index of the next question
  /// - [questionIndex]: Question index within the section
  /// 
  /// Used by OnboardingProvider.nextQuestion() for forward navigation.
  OnboardingState nextQuestion({
    required String questionId,
    required int sectionIndex,
    required int questionIndex,
  }) {
    return copyWith(
      currentQuestionId: questionId,
      currentSectionIndex: sectionIndex,
      currentQuestionIndex: questionIndex,
      status: OnboardingStatus.inProgress,
    );
  }

  /// Transitions state to the previous question.
  /// 
  /// Updates current question ID and indices for backward navigation.
  /// Maintains the current status (doesn't change from inProgress).
  /// 
  /// Parameters:
  /// - [questionId]: ID of the previous question to display
  /// - [sectionIndex]: Section index of the previous question
  /// - [questionIndex]: Question index within the section
  /// 
  /// Used by OnboardingProvider.previousQuestion() for backward navigation.
  OnboardingState previousQuestion({
    required String questionId,
    required int sectionIndex,
    required int questionIndex,
  }) {
    return copyWith(
      currentQuestionId: questionId,
      currentSectionIndex: sectionIndex,
      currentQuestionIndex: questionIndex,
    );
  }

  /// Marks the onboarding as completed.
  /// 
  /// Sets status to completed and progress to 100%.
  /// Called when user answers the last question.
  /// 
  /// Used by OnboardingProvider.completeOnboarding().
  OnboardingState complete() {
    return copyWith(
      status: OnboardingStatus.completed,
      progressPercentage: 100.0,
    );
  }

  /// Resets the state to initial values.
  /// 
  /// Returns a fresh initial state, clearing all progress.
  /// Used when user wants to restart onboarding.
  /// 
  /// Used by OnboardingProvider.reset().
  OnboardingState reset() {
    return OnboardingState.initial();
  }
}