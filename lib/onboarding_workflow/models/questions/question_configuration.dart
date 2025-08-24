import 'question_section.dart';

/// Top-level configuration for the entire onboarding question flow.
/// 
/// This is the root model that contains all sections and questions for onboarding.
/// It provides versioning support to handle updates and migrations when the
/// question structure changes over time.
/// 
/// Key responsibilities:
/// - Store the complete onboarding flow structure
/// - Track configuration version for compatibility
/// - Calculate total and visible question counts for progress
/// - Load and save question configurations
/// 
/// Used by:
/// - [OnboardingProvider] as the main configuration source
/// - JSON parser to load questions from assets or Firebase
/// - Progress tracking to show overall completion percentage
/// - Analytics to track which version users completed
/// 
/// The configuration is typically loaded from:
/// 1. Local JSON file (assets/onboarding_questions.json) as default
/// 2. Firebase Remote Config for A/B testing and updates
/// 3. Cached version in Hive for offline support
/// 
/// Example JSON structure:
/// ```json
/// {
///   "version": "1.0.0",
///   "sections": [
///     {
///       "section_id": "basic_info",
///       "title": "Let's Get Started",
///       "reason": "Basic information to personalize your experience",
///       "questions": [...]
///     },
///     {
///       "section_id": "fitness_goals",
///       "title": "Your Fitness Goals",
///       "reason": "We'll create a plan based on your goals",
///       "questions": [...]
///     }
///   ]
/// }
/// ```
class QuestionConfiguration {
  /// Version identifier for this configuration.
  /// Used to handle migrations when question structure changes.
  /// Format: "major.minor.patch" (e.g., "1.0.0")
  /// Stored with user answers to know which version they completed.
  final String version;
  
  /// Ordered list of sections in the onboarding flow.
  /// Sections are displayed in the order they appear in this list.
  /// Each section contains a group of related questions.
  final List<QuestionSection> sections;

  QuestionConfiguration({
    required this.version,
    required this.sections,
  });

  /// Creates a configuration from JSON data.
  /// 
  /// This is the main entry point for loading the onboarding flow.
  /// Typically called when:
  /// - App starts and loads from assets
  /// - Firebase Remote Config updates
  /// - Loading cached configuration from Hive
  /// 
  /// Recursively creates all sections and questions.
  factory QuestionConfiguration.fromJson(Map<String, dynamic> json) {
    return QuestionConfiguration(
      version: json['version'] as String,
      sections: (json['sections'] as List)
          .map((s) => QuestionSection.fromJson(s))
          .toList(),
    );
  }

  /// Converts the entire configuration to JSON.
  /// 
  /// Used for:
  /// - Caching configuration in Hive
  /// - Debugging and logging
  /// - Sending configuration to analytics
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }

  /// Calculates the total number of questions across all sections.
  /// 
  /// This counts ALL questions, including those that might be hidden
  /// based on conditions. Used as the maximum possible question count.
  /// 
  /// Returns the sum of questions in all sections.
  /// 
  /// Example usage:
  /// ```dart
  /// int totalQuestions = config.getTotalQuestionCount();
  /// print('Onboarding has $totalQuestions questions total');
  /// ```
  /// 
  /// Used by:
  /// - Analytics to track total question pool size
  /// - Debug logging to verify configuration loaded correctly
  int getTotalQuestionCount() {
    return sections.fold(0, (sum, section) => sum + section.questions.length);
  }

  /// Calculates how many questions are visible based on current answers.
  /// 
  /// This method accounts for conditional questions that may be hidden
  /// based on user responses, providing an accurate count for progress tracking.
  /// 
  /// [answers] is a map of question IDs to their corresponding answers.
  /// 
  /// Returns the sum of visible questions across all sections.
  /// 
  /// Example usage:
  /// ```dart
  /// Map<String, dynamic> userAnswers = {"goals": ["lose_weight"]};
  /// int visibleCount = config.getVisibleQuestionCount(userAnswers);
  /// // Returns fewer questions if some are hidden by conditions
  /// ```
  /// 
  /// Used by:
  /// - Progress bar to show accurate completion percentage
  /// - OnboardingProvider to determine when onboarding is complete
  /// - Analytics to track how many questions users actually see
  int getVisibleQuestionCount(Map<String, dynamic> answers) {
    return sections.fold(
      0,
      (sum, section) => sum + section.getVisibleQuestions(answers).length,
    );
  }
}