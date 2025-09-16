import 'package:flutter/material.dart';
import '../../models/questions/question.dart';
import '../../models/questions/enum_question_type.dart';
import '../../models/questions/question_option.dart';
import '../../models/questions/question_condition.dart';
import '../../views/question_views/base_question_view.dart';

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
  
  /// Get the current answer as a string representation for serialization.
  /// Each subclass must implement this method to return their typed value as a string.
  String? get answer;
  
  /// Check if this question has been answered.
  /// Returns true if the answer is not null, indicating the question has valid data.
  bool get hasAnswer => answer != null;

  //MARK: SERIALIZATION
  
  /// Serialize this question's answer to JSON for storage.
  /// Returns a map with question ID and serialized answer.
  Map<String, dynamic> toJson() => {
    'id': id,
    'answer': answer,
  };
  
  /// Deserialize answer from JSON storage.
  /// Updates the question's answer from the JSON data.
  void fromJson(Map<String, dynamic> json) {
    fromJsonValue(json['answer']);
  }
  
  /// Convert JSON value to the question's typed field.
  /// Each subclass must implement this method to handle deserialization defensively.
  /// Should handle multiple input types (String, DateTime, List, etc.) without throwing.
  void fromJsonValue(dynamic json);
  
  //MARK: VALIDATION
  
  /// Validation is now handled in the typed setters.
  /// Each question validates input before storing it.
  /// If a value is stored (answer != null), it is valid.
  

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