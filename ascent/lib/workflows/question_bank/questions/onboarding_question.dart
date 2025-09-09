import 'package:flutter/material.dart';
import '../../onboarding_workflow/models/questions/question.dart';
import '../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../onboarding_workflow/models/questions/question_option.dart';
import '../../onboarding_workflow/models/questions/question_condition.dart';
import '../views/base_question_view.dart';

/// Base class for all onboarding questions.
/// 
/// Each question serves as a single source of truth for:
/// 1. UI presentation data (question text, options, validation)
/// 2. Answer storage logic (how to store the raw answer)
/// 
/// Business logic for feature calculation is handled separately
/// by the FitnessFeatureCalculator.
abstract class OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  /// Unique identifier for this question
  String get id;
  
  /// The question text displayed to the user
  String get questionText;
  
  /// Section this question belongs to (for grouping)
  String get section;
  
  /// Type of input control to display
  EnumQuestionType get questionType;
  
  /// Optional subtitle/instruction text
  String? get subtitle => null;
  
  /// Optional subtitle widget (overrides subtitle if provided)
  Widget? get subtitleWidget => null;
  
  /// Options for single/multiple choice questions
  List<QuestionOption>? get options => null;
  
  /// Configuration for input widgets (validation, ranges, etc.)
  Map<String, dynamic>? get config => null;
  
  /// Condition that determines if this question should be shown
  QuestionCondition? get condition => null;
  
  //MARK: CONVERSION
  
  /// Convert this question to the existing Question model for UI display
  Question toPresentation() {
    return Question(
      id: id,
      question: questionText,
      section: section,
      type: questionType,
      options: options,
      condition: condition,
      subtitle: subtitle,
      answerConfigurationSettings: config,
    );
  }
  
  //MARK: ANSWER STORAGE
  
  /// The answer to this question stored directly on the question instance.
  /// Each subclass should provide typed getters/setters for this field.
  dynamic _answer;
  
  /// Get the current answer for this question.
  /// Subclasses should override with typed getters.
  dynamic get answer => _answer;
  
  /// Set the answer for this question.
  /// Subclasses should override with typed setters.
  set answer(dynamic value) => _answer = value;

  //MARK: SERIALIZATION
  
  /// Serialize this question's answer to JSON for storage.
  /// Returns a map with question ID and serialized answer.
  Map<String, dynamic> toJson() => {
    'id': id,
    'answer': answerToJson(_answer),
  };
  
  /// Deserialize answer from JSON storage.
  /// Updates the question's answer from the JSON data.
  void fromJson(Map<String, dynamic> json) {
    _answer = answerFromJson(json['answer']);
  }
  
  /// Convert answer value to JSON-compatible format.
  /// Override for types that need special serialization (DateTime -> ISO String).
  dynamic answerToJson(dynamic value) => value;
  
  /// Convert JSON value back to typed answer.
  /// Override for types that need deserialization (ISO String -> DateTime).
  dynamic answerFromJson(dynamic json) => json;
  
  //MARK: VALIDATION
  
  /// Validate that an answer is acceptable for this question.
  /// Override for custom validation beyond basic type checking.
  bool isValidAnswer(dynamic answer) => false;
  
  /// Get a default value if the user hasn't answered this question.
  /// Override to provide sensible defaults for optional questions.
  dynamic getDefaultAnswer() => null;
  

  ///
  bool shouldShow(Map<String, dynamic> answers) => true; // Default to always show, override if needed

  //MARK: RENDERING
  
  /// Render the complete question view including question text, subtitle, and answer widget.
  /// 
  /// This method allows questions to be fully self-contained by handling their own rendering.
  /// The container simply calls this method instead of having complex switch statements.
  /// 
  /// [onAnswerChanged] callback for when the user changes their answer  
  /// [accentColor] optional color override for theming
  Widget renderQuestionView({
    required Function() onAnswerChanged,
    Color? accentColor,
  }) {
    return BaseQuestionView(
      questionId: id,
      questionText: questionText,
      subtitle: subtitle,
      subtitleWidget: subtitleWidget,
      reason: null, // Can be overridden by individual questions if needed
      accentColor: accentColor,
      noPadding: questionType == EnumQuestionType.bodyMap,
      isRequired: config?['isRequired'] ?? false,
      answerWidget: buildAnswerWidget(onAnswerChanged),
    );
  }
  
  /// Build the appropriate answer widget based on question type.
  /// 
  /// Each question subclass must implement this method to provide its specific widget.
  /// The question provides its own answer value and handles change notifications.
  @protected
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  );
}