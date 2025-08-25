import 'enum_question_type.dart';
import 'question_option.dart';
import 'question_validation.dart';
import 'question_condition.dart';

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
/// - [QuestionSection] to group related questions
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
  /// Unique identifier for this question.
  /// Used to store and retrieve answers, and reference in conditions.
  /// Example: "age", "fitness_goals", "workout_location"
  final String id;
  
  /// The question text displayed to the user.
  /// Should be clear and concise.
  /// Example: "What are your fitness goals?"
  final String question;
  
  /// Section this question belongs to.
  /// Used for grouping and organizing questions.
  /// Example: "personal_info", "fitness_goals", "preferences"
  final String section;
  
  /// The type of input control to display.
  /// Determines which UI widget is rendered (text field, radio buttons, etc.).
  final EnumQuestionType type;
  
  /// Available choices for single/multiple choice questions.
  /// Only required when type is singleChoice or multipleChoice.
  /// Null for other question types.
  final List<QuestionOption>? options;
  
  /// Validation rules that the answer must satisfy.
  /// Defines requirements like min/max values, required fields, etc.
  /// Null means no validation (answer is always valid).
  final QuestionValidation? validation;
  
  /// Conditional display logic based on previous answers.
  /// If set, this question only shows when the condition evaluates to true.
  /// Null means question always shows (no conditions).
  final QuestionCondition? condition;

  Question({
    required this.id,
    required this.question,
    required this.section,
    required this.type,
    this.options,
    this.validation,
    this.condition,
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
      validation: json['validation'] != null
          ? QuestionValidation.fromJson(json['validation'])
          : null,
      condition: json['condition'] != null
          ? QuestionCondition.fromJson(json['condition'])
          : null,
    );
  }

  /// Converts this question to a JSON-compatible map.
  /// 
  /// Used for debugging, logging, or saving question configurations.
  /// Only includes non-null optional fields to keep JSON clean.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'id': id,
      'question': question,
      'section': section,
      'type': type.toJson(),
    };
    if (options != null) {
      result['options'] = options!.map((o) => o.toJson()).toList();
    }
    if (validation != null) {
      result['validation'] = validation!.toJson();
    }
    if (condition != null) {
      result['condition'] = condition!.toJson();
    }
    return result;
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
  /// - [QuestionSection.getVisibleQuestions()] to filter question lists
  /// - Progress calculation to count only visible questions
  bool shouldShow(Map<String, dynamic> answers) {
    // Questions without conditions always show
    if (condition == null) return true;
    
    // Get the answer for the question referenced in the condition
    final answer = answers[condition!.questionId];
    
    // Use the condition's evaluate method to check if it's met
    return condition!.evaluate(answer);
  }
}