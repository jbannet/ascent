/// Defines validation rules for question answers.
/// 
/// This class specifies constraints that user input must meet before
/// the answer can be accepted and the user can proceed to the next question.
/// Different validation rules apply to different question types.
/// 
/// Used by:
/// - [OnboardingQuestion] to specify validation rules
/// - UI widgets to validate user input before allowing progression
/// - OnboardingProvider to check if an answer is valid
/// 
/// Example in JSON:
/// ```json
/// "validation": {
///   "required": true,
///   "min": 13,
///   "max": 100
/// }
/// ```
class QuestionValidation {
  /// Whether this question must be answered (cannot be skipped).
  /// If true, user must provide an answer before proceeding.
  /// Applies to all question types.
  final bool? required;
  
  /// Minimum character length for text input.
  /// Only applies to textInput type questions.
  /// Example: Name must be at least 2 characters.
  final int? minLength;
  
  /// Maximum character length for text input.
  /// Only applies to textInput type questions.
  /// Example: Bio cannot exceed 500 characters.
  final int? maxLength;
  
  /// Minimum value for numeric input or slider.
  /// Applies to numberInput and slider type questions.
  /// Example: Age must be at least 13.
  final num? min;
  
  /// Maximum value for numeric input or slider.
  /// Applies to numberInput and slider type questions.
  /// Example: Age cannot exceed 100.
  final num? max;
  
  /// Maximum number of options that can be selected.
  /// Only applies to multipleChoice type questions.
  /// Example: Select up to 3 fitness goals.
  final int? maxSelections;
  
  /// Minimum number of options that must be selected.
  /// Only applies to multipleChoice type questions.
  /// Example: Must select at least 1 fitness goal.
  final int? minSelections;

  QuestionValidation({
    this.required,
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
    this.maxSelections,
    this.minSelections,
  });

  /// Creates validation rules from a JSON map.
  /// 
  /// Used when loading questions from JSON configuration.
  factory QuestionValidation.fromJson(Map<String, dynamic> json) {
    return QuestionValidation(
      required: json['required'] as bool?,
      minLength: json['min_length'] as int?,
      maxLength: json['max_length'] as int?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      maxSelections: json['max_selections'] as int?,
      minSelections: json['min_selections'] as int?,
    );
  }

}