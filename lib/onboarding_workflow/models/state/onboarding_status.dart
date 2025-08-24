/// Represents the current status of a user's onboarding journey.
/// 
/// This enum tracks whether the user has started, is currently in,
/// or has completed the onboarding process. It's used throughout the app
/// to determine which screens to show and whether to prompt for onboarding.
/// 
/// States:
/// - [notStarted]: User has never begun onboarding (new user)
/// - [inProgress]: User started but hasn't finished onboarding
/// - [completed]: User successfully finished all onboarding questions
/// 
/// Used by:
/// - [OnboardingState] to track current session status
/// - [AppState] to determine if onboarding should be shown on app launch
/// - Navigation logic to route users to appropriate screens
/// - Analytics to track onboarding funnel metrics
enum OnboardingStatus {
  /// User has not yet started the onboarding process.
  /// This is the initial state for new users.
  notStarted,
  
  /// User has started onboarding but hasn't completed it.
  /// They may have answered some questions but not all.
  inProgress,
  
  /// User has successfully completed all onboarding questions.
  /// Their answers have been saved and they can access the main app.
  completed
}

/// Extension methods for OnboardingStatus enum.
/// 
/// Provides convenient getters for checking status and JSON serialization
/// for storing the status in databases or sending to APIs.
extension OnboardingStatusExtension on OnboardingStatus {
  /// Returns true if onboarding is currently active (in progress).
  /// 
  /// Used by UI to show onboarding screens and hide main app features.
  bool get isActive => this == OnboardingStatus.inProgress;
  
  /// Returns true if onboarding has been completed.
  /// 
  /// Used to determine if user can access main app functionality.
  bool get isCompleted => this == OnboardingStatus.completed;
  
  /// Returns true if onboarding hasn't been started yet.
  /// 
  /// Used to show welcome screens or onboarding prompts.
  bool get isNotStarted => this == OnboardingStatus.notStarted;
  
  /// Converts the enum to a JSON-compatible string.
  /// 
  /// Used when saving status to Hive or Firebase.
  /// Converts Dart naming (camelCase) to JSON convention (snake_case).
  String toJson() {
    switch (this) {
      case OnboardingStatus.notStarted:
        return 'not_started';
      case OnboardingStatus.inProgress:
        return 'in_progress';
      case OnboardingStatus.completed:
        return 'completed';
    }
  }
  
  /// Parses a JSON string value into the corresponding OnboardingStatus.
  /// 
  /// Used when loading status from storage or API responses.
  /// Throws [ArgumentError] if the string doesn't match any known status.
  /// 
  /// Example:
  /// ```dart
  /// OnboardingStatus status = OnboardingStatusExtension.fromJson('in_progress');
  /// // Returns OnboardingStatus.inProgress
  /// ```
  static OnboardingStatus fromJson(String value) {
    switch (value) {
      case 'not_started':
        return OnboardingStatus.notStarted;
      case 'in_progress':
        return OnboardingStatus.inProgress;
      case 'completed':
        return OnboardingStatus.completed;
      default:
        throw ArgumentError('Unknown onboarding status: $value');
    }
  }
}