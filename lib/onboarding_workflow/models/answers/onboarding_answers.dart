/// Stores all user answers from the onboarding process.
/// 
/// This is the primary data model that captures user responses during onboarding.
/// It maintains the raw answers exactly as entered, along with metadata about
/// the onboarding session like when it started and completed.
/// 
/// Key responsibilities:
/// - Store user answers mapped to question IDs
/// - Track onboarding session metadata (start/completion times)
/// - Provide helper methods to query and update answers
/// - Support immutable updates using copyWith pattern
/// - Calculate completion progress
/// 
/// Data flow:
/// 1. Created empty when onboarding starts
/// 2. Updated with each answer as user progresses
/// 3. Marked complete when user finishes
/// 4. Saved to Hive locally and Firebase remotely
/// 5. Used to generate derived metrics and conclusions
/// 
/// Used by:
/// - [OnboardingProvider] to store and retrieve answers during the flow
/// - Storage services to persist data locally (Hive) and remotely (Firebase)
/// - Metrics calculation to derive insights from raw answers
/// - Progress tracking to show completion percentage
/// 
/// Example JSON:
/// ```json
/// {
///   "onboarding_version": "1.0.0",
///   "completed": true,
///   "started_at": "2024-01-15T10:30:00Z",
///   "completed_at": "2024-01-15T10:45:00Z",
///   "answers": {
///     "age": 28,
///     "goals": ["lose_weight", "build_muscle"],
///     "weight": 180,
///     "height": 72
///   }
/// }
/// ```
class OnboardingAnswers {
  /// Version of the question configuration used.
  /// Important for handling migrations when questions change.
  /// Matches QuestionConfiguration.version.
  final String onboardingVersion;
  
  /// Whether the user has completed all onboarding questions.
  /// Set to true when user reaches the end of the flow.
  final bool completed;
  
  /// When the user started the onboarding process.
  /// Set when OnboardingAnswers.empty() is called.
  final DateTime startedAt;
  
  /// When the user completed onboarding.
  /// Null if onboarding is still in progress.
  /// Set when markCompleted() is called.
  final DateTime? completedAt;
  
  /// Map of question IDs to user answers.
  /// Keys are question IDs from OnboardingQuestion.id.
  /// Values can be any type depending on question type:
  /// - String for textInput
  /// - num for numberInput or slider
  /// - String for singleChoice (the selected option value)
  /// - `List<String>` for multipleChoice (selected option values)
  /// - DateTime for datePicker
  final Map<String, dynamic> answers;

  OnboardingAnswers({
    required this.onboardingVersion,
    required this.completed,
    required this.startedAt,
    this.completedAt,
    required this.answers,
  });

  /// Creates an OnboardingAnswers instance from JSON data.
  /// 
  /// Used when loading saved answers from Hive or Firebase.
  factory OnboardingAnswers.fromJson(Map<String, dynamic> json) {
    return OnboardingAnswers(
      onboardingVersion: json['onboarding_version'] as String,
      completed: json['completed'] as bool,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      answers: Map<String, dynamic>.from(json['answers'] as Map),
    );
  }

  /// Converts answers to JSON for storage.
  /// 
  /// Used when saving to Hive locally or Firebase remotely.
  Map<String, dynamic> toJson() {
    return {
      'onboarding_version': onboardingVersion,
      'completed': completed,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'answers': answers,
    };
  }

  /// Retrieves the answer for a specific question.
  /// 
  /// Returns null if the question hasn't been answered yet.
  /// Used by condition evaluation to check previous answers.
  dynamic getAnswer(String questionId) => answers[questionId];

  /// Checks if a question has been answered.
  /// 
  /// Returns true if the question has a non-null answer.
  /// Used by progress tracking and validation.
  bool isAnswered(String questionId) =>
      answers.containsKey(questionId) && answers[questionId] != null;

  /// Sets an answer for a question (mutable operation).
  /// 
  /// Note: This mutates the answers map directly.
  /// Consider using withAnswer() for immutable updates.
  void setAnswer(String questionId, dynamic value) =>
      answers[questionId] = value;

  /// Creates a copy of this instance with updated fields.
  /// 
  /// Follows the immutable update pattern for state management.
  /// Used internally by other update methods.
  OnboardingAnswers copyWith({
    String? onboardingVersion,
    bool? completed,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? answers,
  }) {
    return OnboardingAnswers(
      onboardingVersion: onboardingVersion ?? this.onboardingVersion,
      completed: completed ?? this.completed,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      answers: answers ?? Map<String, dynamic>.from(this.answers),
    );
  }

  /// Creates a new instance with an updated or removed answer.
  /// 
  /// This is the primary method for updating answers immutably.
  /// If value is null, the answer is removed (for skip functionality).
  /// 
  /// Example:
  /// ```dart
  /// answers = answers.withAnswer('age', 28);
  /// answers = answers.withAnswer('goals', ['lose_weight']);
  /// ```
  /// 
  /// Used by OnboardingProvider.saveAnswer() to update state.
  OnboardingAnswers withAnswer(String questionId, dynamic value) {
    final updatedAnswers = Map<String, dynamic>.from(answers);
    if (value != null) {
      updatedAnswers[questionId] = value;
    } else {
      updatedAnswers.remove(questionId);
    }
    return copyWith(answers: updatedAnswers);
  }

  /// Marks the onboarding as completed.
  /// 
  /// Sets completed to true and records the completion time.
  /// Called when user reaches the end of all questions.
  /// 
  /// Used by OnboardingProvider.completeOnboarding().
  OnboardingAnswers markCompleted() {
    return copyWith(
      completed: true,
      completedAt: DateTime.now(),
    );
  }

  /// Calculates what percentage of questions have been answered.
  /// 
  /// [totalQuestions] should be the count of visible questions only.
  /// Returns a value between 0.0 and 100.0.
  /// 
  /// Used by progress indicators in the UI.
  double getCompletionPercentage(int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    final answeredCount = answers.values.where((v) => v != null).length;
    return (answeredCount / totalQuestions) * 100;
  }

  /// Checks if all required questions have been answered.
  /// 
  /// [requiredQuestionIds] is a list of question IDs that must be answered.
  /// Returns true only if all required questions have non-null answers.
  /// 
  /// Used to validate if user can complete onboarding.
  bool hasAllRequiredAnswers(List<String> requiredQuestionIds) {
    return requiredQuestionIds.every((id) => isAnswered(id));
  }

  /// Creates an empty instance for starting a new onboarding session.
  /// 
  /// Sets the version, marks as not completed, and initializes timestamps.
  /// The answers map starts empty and will be populated as user progresses.
  /// 
  /// Used by OnboardingProvider.initialize() to start onboarding.
  factory OnboardingAnswers.empty(String version) {
    return OnboardingAnswers(
      onboardingVersion: version,
      completed: false,
      startedAt: DateTime.now(),
      completedAt: null,
      answers: {},
    );
  }
}