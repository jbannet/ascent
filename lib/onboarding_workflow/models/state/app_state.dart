/// Global application state that persists across app sessions.
/// 
/// This model tracks high-level app state including whether the user has
/// completed onboarding and authentication status. It's stored in Hive
/// for persistence and loaded on app startup.
/// 
/// Key responsibilities:
/// - Track if user has completed onboarding
/// - Store the version of onboarding completed
/// - Maintain user authentication state
/// - Determine app navigation flow on startup
/// 
/// Lifecycle:
/// 1. Created as initial() for new app installations
/// 2. Loaded from Hive on app startup if exists
/// 3. Updated when onboarding completes or user authenticates
/// 4. Persisted to Hive after each update
/// 
/// Used by:
/// - App initialization to determine starting screen
/// - Navigation to check if onboarding is required
/// - Authentication flow to track user status
/// - Settings screen to show onboarding version
/// 
/// Example JSON in Hive:
/// ```json
/// {
///   "onboarding_completed": true,
///   "onboarding_version": "1.0.0",
///   "user_id": "user123"
/// }
/// ```
class AppState {
  /// Whether the user has completed onboarding.
  /// If false, app should navigate to onboarding flow on startup.
  final bool onboardingCompleted;
  
  /// Version of the onboarding questions the user completed.
  /// Null if onboarding hasn't been completed.
  /// Used to detect if re-onboarding is needed after major updates.
  final String? onboardingVersion;
  
  /// Authenticated user's ID from Firebase Auth.
  /// Null if user is not authenticated.
  /// Used to determine access to user-specific features.
  final String? userId;

  AppState({
    required this.onboardingCompleted,
    this.onboardingVersion,
    this.userId,
  });

  /// Creates AppState from JSON data.
  /// 
  /// Used when loading persisted state from Hive on app startup.
  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      onboardingCompleted: json['onboarding_completed'] as bool,
      onboardingVersion: json['onboarding_version'] as String?,
      userId: json['user_id'] as String?,
    );
  }

  /// Converts AppState to JSON for persistence.
  /// 
  /// Used when saving state to Hive after updates.
  Map<String, dynamic> toJson() {
    return {
      'onboarding_completed': onboardingCompleted,
      'onboarding_version': onboardingVersion,
      'user_id': userId,
    };
  }

  /// Creates a copy with updated fields.
  /// 
  /// Follows immutable pattern for state management.
  /// Used by all state update methods.
  AppState copyWith({
    bool? onboardingCompleted,
    String? onboardingVersion,
    String? userId,
  }) {
    return AppState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingVersion: onboardingVersion ?? this.onboardingVersion,
      userId: userId ?? this.userId,
    );
  }

  /// Creates the initial state for a fresh app installation.
  /// 
  /// Sets onboarding as not completed and no authenticated user.
  /// This state triggers the onboarding flow on first launch.
  /// 
  /// Used when:
  /// - App is launched for the first time
  /// - No persisted state exists in Hive
  /// - User data is cleared/reset
  factory AppState.initial() {
    return AppState(
      onboardingCompleted: false,
      onboardingVersion: null,
      userId: null,
    );
  }

  /// Marks onboarding as completed with the given version.
  /// 
  /// [version] is the QuestionConfiguration version that was completed.
  /// This allows tracking which version of questions the user answered.
  /// 
  /// Called after user successfully completes all onboarding questions.
  /// The updated state should be persisted to Hive immediately.
  /// 
  /// Used by OnboardingProvider after successful completion.
  AppState completeOnboarding(String version) {
    return copyWith(
      onboardingCompleted: true,
      onboardingVersion: version,
    );
  }

  /// Updates the state with an authenticated user ID.
  /// 
  /// [id] is the user's unique identifier from Firebase Auth.
  /// 
  /// Called after successful authentication (sign in/sign up).
  /// The updated state should be persisted to Hive.
  /// 
  /// Used by authentication service after Firebase Auth success.
  AppState withUserId(String id) {
    return copyWith(userId: id);
  }

  /// Returns true if the user needs to complete onboarding.
  /// 
  /// Used by app initialization to determine if onboarding
  /// flow should be shown instead of the main app.
  /// 
  /// Example usage:
  /// ```dart
  /// if (appState.needsOnboarding) {
  ///   Navigator.pushReplacement(context, OnboardingScreen());
  /// }
  /// ```
  bool get needsOnboarding => !onboardingCompleted;

  /// Returns true if a user is currently authenticated.
  /// 
  /// Checks for a non-null and non-empty user ID.
  /// Used to determine access to user-specific features
  /// and whether to show login/signup screens.
  /// 
  /// Example usage:
  /// ```dart
  /// if (!appState.isAuthenticated) {
  ///   Navigator.push(context, LoginScreen());
  /// }
  /// ```
  bool get isAuthenticated => userId != null && userId!.isNotEmpty;
}