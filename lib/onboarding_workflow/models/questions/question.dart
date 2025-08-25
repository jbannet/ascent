import 'package:flutter/material.dart';
import 'enum_question_type.dart';
import 'question_option.dart';
import 'question_condition.dart';
import '../../widgets/onboarding/question_input/factory_question_inputs.dart';

/// Represents a single question in the onboarding flow.
/// 
/// This is the core model for the onboarding system. Each question has a unique ID,
/// a display text, an input type, and optional validation rules and display conditions.
/// Questions can be shown or hidden dynamically based on previous answers.
/// 
/// Key responsibilities:
/// - Store question configuration (text, type, options, validation)
/// - Determine if question should be visible based on conditions
/// - Serialize to/from JSON for storage and configuration
/// 
/// Used by:
/// - [OnboardingProvider] to display questions and navigate between them
/// - UI widgets to render the appropriate input control
/// - Answer validation to ensure valid user input
/// 
/// Example JSON:
/// ```json
/// {
///   "id": "weight_goal",
///   "question": "How much weight do you want to lose?",
///   "type": "number_input",
///   "validation": {
///     "required": true,
///     "min": 1,
///     "max": 100
///   },
///   "condition": {
///     "question_id": "goals",
///     "operator": "contains",
///     "value": "lose_weight"
///   }
/// }
/// ```
class Question {
  final String id; // Unique identifier used for answers and conditions
  final String question; // Question text displayed to user
  final String section; // Section for grouping questions
  final EnumQuestionType type; // Input control type (text, slider, etc.)
  final List<QuestionOption>? options; // Choices for single/multiple choice questions
  final QuestionCondition? condition; // Display condition based on previous answers
  final String? subtitle; // Additional context text under question
  final Map<String, dynamic>? answerConfigurationSettings; // Widget-specific configuration parameters

  Question({
    required this.id,
    required this.question,
    required this.section,
    required this.type,
    this.options,
    this.condition,
    this.subtitle,
    this.answerConfigurationSettings,
  });

  /// Creates a question from a JSON configuration.
  /// 
  /// Used when loading questions from assets/onboarding_questions.json
  /// or from Firebase remote configuration.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      question: json['question'] as String,
      section: json['section'] as String,
      type: QuestionTypeExtension.fromJson(json['type'] as String),
      options: json['options'] != null
          ? (json['options'] as List)
              .map((o) => QuestionOption.fromJson(o))
              .toList()
          : null,
      condition: json['condition'] != null
          ? QuestionCondition.fromJson(json['condition'])
          : null,
      subtitle: json['subtitle'] as String?,
      answerConfigurationSettings: json['config'] as Map<String, dynamic>?,
    );
  }


  /// Determines if this question should be displayed to the user.
  /// 
  /// This method checks the question's condition against previously collected answers
  /// to decide if the question should appear in the flow.
  /// 
  /// [answers] is a map of question IDs to their corresponding answers
  /// from earlier questions in the onboarding flow.
  /// 
  /// Returns true if:
  /// - The question has no condition (always shows)
  /// - The condition evaluates to true based on previous answers
  /// 
  /// Returns false if:
  /// - The condition evaluates to false (question should be hidden)
  /// 
  /// Example usage:
  /// ```dart
  /// // User previously answered goals question with ["lose_weight", "build_muscle"]
  /// Map<String, dynamic> answers = {
  ///   "goals": ["lose_weight", "build_muscle"],
  ///   "age": 25
  /// };
  /// 
  /// // Weight loss question only shows if user selected "lose_weight" goal
  /// if (weightLossQuestion.shouldShow(answers)) {
  ///   // Display the weight loss question
  /// }
  /// ```
  /// 
  /// This method is called by:
  /// - [OnboardingProvider] when navigating to next/previous questions
  /// - Progress calculation to count only visible questions
  bool shouldShow(Map<String, dynamic> answers) {
    // Questions without conditions always show
    if (condition == null) return true;
    
    // Get the answer for the question referenced in the condition
    final answer = answers[condition!.questionId];
    
    // Use the condition's evaluate method to check if it's met
    return condition!.evaluate(answer);
  }

  /// Builds the appropriate answer widget for this question.
  /// 
  /// This method encapsulates the question's responsibility for creating
  /// its own input widget based on its type and configuration.
  Widget buildAnswerWidget({
    required Map<String, dynamic> currentAnswers,
    required Function(String, dynamic) onAnswerChanged,
  }) {
    return FactoryQuestionInputs.createWidget(
      question: this,
      currentAnswers: currentAnswers,
      onAnswerChanged: onAnswerChanged,
    );
  }
}