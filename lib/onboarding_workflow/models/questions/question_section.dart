import 'onboarding_question.dart';

/// Groups related questions into a logical section within the onboarding flow.
/// 
/// Sections organize questions thematically, making the onboarding process
/// feel more structured and less overwhelming. Each section has a clear purpose
/// explained to the user, helping them understand why we're asking these questions.
/// 
/// Key responsibilities:
/// - Group related questions together (e.g., all fitness goal questions)
/// - Provide context to users about why we need this information
/// - Filter questions based on visibility conditions
/// - Support section-level progress tracking
/// 
/// Used by:
/// - [QuestionConfiguration] to organize the entire onboarding flow
/// - [OnboardingProvider] to navigate between sections
/// - UI to display section headers and progress indicators
/// - Progress calculation to show section completion
/// 
/// Example sections:
/// - Basic Info: Age, gender, location
/// - Fitness Goals: Weight loss, muscle gain, endurance
/// - Health History: Medical conditions, injuries
/// - Preferences: Workout time, equipment, schedule
/// 
/// Example JSON:
/// ```json
/// {
///   "section_id": "fitness_goals",
///   "title": "Your Fitness Goals",
///   "reason": "We'll create a personalized workout plan based on your goals",
///   "questions": [
///     { "id": "goals", "question": "What are your fitness goals?", ... },
///     { "id": "weight_goal", "question": "How much weight?", ... }
///   ]
/// }
/// ```
class QuestionSection {
  /// Unique identifier for this section.
  /// Used for tracking progress and analytics.
  /// Example: "basic_info", "fitness_goals", "health_history"
  final String sectionId;
  
  /// User-friendly title displayed at the top of the section.
  /// Should be clear and descriptive.
  /// Example: "Let's Get to Know You", "Your Fitness Journey"
  final String title;
  
  /// Explanation of why we're asking these questions.
  /// Helps build trust by being transparent about data usage.
  /// Example: "This helps us calculate your daily calorie needs"
  final String reason;
  
  /// Ordered list of questions in this section.
  /// Questions are displayed in the order they appear in this list,
  /// but may be skipped based on their conditions.
  final List<OnboardingQuestion> questions;

  QuestionSection({
    required this.sectionId,
    required this.title,
    required this.reason,
    required this.questions,
  });

  /// Creates a section from JSON configuration.
  /// 
  /// Used when loading the onboarding flow from assets or Firebase.
  /// Recursively creates all OnboardingQuestion objects within the section.
  factory QuestionSection.fromJson(Map<String, dynamic> json) {
    return QuestionSection(
      sectionId: json['section_id'] as String,
      title: json['title'] as String,
      reason: json['reason'] as String,
      questions: (json['questions'] as List)
          .map((q) => OnboardingQuestion.fromJson(q))
          .toList(),
    );
  }

  /// Converts this section to a JSON-compatible map.
  /// 
  /// Used for debugging, logging, or saving configurations.
  /// Includes all questions with their full configurations.
  Map<String, dynamic> toJson() {
    return {
      'section_id': sectionId,
      'title': title,
      'reason': reason,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  /// Returns only the questions that should be visible based on user answers.
  /// 
  /// This method filters out questions whose conditions aren't met,
  /// providing a dynamic list of questions that adapts to user responses.
  /// 
  /// [answers] is a map of question IDs to their corresponding answers
  /// from all previous questions in the onboarding flow.
  /// 
  /// Returns a filtered list containing only questions where shouldShow() returns true.
  /// 
  /// Example usage:
  /// ```dart
  /// Map<String, dynamic> userAnswers = {
  ///   "goals": ["lose_weight"],
  ///   "has_equipment": false
  /// };
  /// 
  /// // Returns only questions relevant to weight loss without equipment
  /// List<OnboardingQuestion> visibleQuestions = 
  ///     section.getVisibleQuestions(userAnswers);
  /// ```
  /// 
  /// Used by:
  /// - [OnboardingProvider] to determine which questions to display
  /// - Progress tracking to count only visible questions
  /// - Skip logic to find the next available question
  List<OnboardingQuestion> getVisibleQuestions(Map<String, dynamic> answers) {
    return questions.where((q) => q.shouldShow(answers)).toList();
  }
}