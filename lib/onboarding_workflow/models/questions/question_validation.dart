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

  QuestionValidation({
    this.required,
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
    this.maxSelections,
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
    );
  }

  /// Converts validation rules to a JSON-compatible map.
  /// 
  /// Only includes non-null values to keep JSON clean.
  /// Used when saving questions or sending to Firebase.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    if (required != null) result['required'] = required;
    if (minLength != null) result['min_length'] = minLength;
    if (maxLength != null) result['max_length'] = maxLength;
    if (min != null) result['min'] = min;
    if (max != null) result['max'] = max;
    if (maxSelections != null) result['max_selections'] = maxSelections;
    return result;
  }
}