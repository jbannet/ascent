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
/// - Support direct mutable updates for performance
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
///   "completed": true,
///   "answers": {
///     "age": 28,
///     "goals": ["lose_weight", "build_muscle"],
///     "weight": 180,
///     "height": 72
///   }
/// }
/// ```
class OnboardingAnswers {
  /// Whether the user has completed all onboarding questions.
  /// Set to true when user reaches the end of the flow.
  bool completed;
  
  /// Map of question IDs to user answers.
  /// Keys are question IDs from OnboardingQuestion.id.
  /// Values can be any type depending on question type:
  /// - String for textInput
  /// - num for numberInput or slider
  /// - String for singleChoice (the selected option value)
  /// - `List<String>` for multipleChoice (selected option values)
  /// - DateTime for datePicker
  final Map<String, dynamic> answers;

  //MARK: Constructors
  OnboardingAnswers({
    required this.completed,
    required this.answers,
  });

  /// Creates an empty instance for starting a new onboarding session.
  /// Marks as not completed and initializes empty answers map.
  /// The answers map starts empty and will be populated as user progresses.
  /// Used by OnboardingProvider.initialize() to start onboarding.
  factory OnboardingAnswers.empty() {
    return OnboardingAnswers(
      completed: false,
      answers: {},
    );
  }
  //MARK: GETTERS
  bool get isInitialized => answers.isNotEmpty;
  int get length => answers.length;

  /// Creates an OnboardingAnswers instance from JSON data.
  /// Used when loading saved answers from Hive or Firebase.
  factory OnboardingAnswers.fromJson(Map<String, dynamic> json) {
    return OnboardingAnswers(
      completed: json['completed'] as bool,
      answers: Map<String, dynamic>.from(json['answers'] as Map),
    );
  }

  /// Converts answers to JSON for storage.
  /// Used when saving to Hive locally or Firebase remotely.
  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'answers': answers,
    };
  }

  /// Retrieves the answer for a specific question.
  /// Returns null if the question hasn't been answered yet.
  /// Used by condition evaluation to check previous answers.
  dynamic getAnswer(String questionId) => answers[questionId];

  /// Checks if a question has been answered.
  /// Returns true if the question has a non-null answer.
  /// Used by progress tracking and validation.
  bool isAnswered(String questionId) =>
      answers.containsKey(questionId) && answers[questionId] != null;

  /// Sets an answer for a question (mutable operation).
  /// Mutates the answers map directly for performance.
  /// Used when user provides an answer to update the internal state.
  void setAnswer(String questionId, dynamic value) =>
      answers[questionId] = value;

  /// Marks the onboarding as completed.
  /// Sets completed to true.
  /// Called when user reaches the end of all questions.
  /// Used by OnboardingProvider.completeOnboarding().
  void markCompleted() {
    completed = true;
  }

  /// Calculates what percentage of questions have been answered.
  /// [totalQuestions] should be the count of visible questions only.
  /// Returns a value between 0.0 and 100.0.
  /// Used by progress indicators in the UI.
  double getCompletionPercentage(int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    final answeredCount = answers.values.where((v) => v != null).length;
    return (answeredCount / totalQuestions) * 100;
  }

  /// Checks if all required questions have been answered.
  /// [requiredQuestionIds] is a list of question IDs that must be answered.
  /// Returns true only if all required questions have non-null answers.
  /// Used to validate if user can complete onboarding.
  bool hasAllRequiredAnswers(List<String> requiredQuestionIds) {
    return requiredQuestionIds.every((id) => isAnswered(id));
  }

}