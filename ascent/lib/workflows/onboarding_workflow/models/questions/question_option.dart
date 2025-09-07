/// Represents a single option in a single-choice or multiple-choice question.
/// 
/// Each option has a [value] that gets stored in the answer database and a 
/// [label] that is displayed to the user in the UI.
/// 
/// Example:
/// ```dart
/// QuestionOption(
///   value: 'lose_weight',      // Stored in database
///   label: 'Lose weight',      // Shown to user
///   description: 'Focus on reducing body weight through diet and exercise'
/// )
/// ```
/// 
/// Used by:
/// - [OnboardingQuestion] when type is singleChoice or multipleChoice
/// - UI widgets to display selectable options (radio buttons, checkboxes)
/// - Answer storage to save the selected value(s)
class QuestionOption {
  /// The internal value stored when this option is selected.
  /// This is what gets saved in the answers database.
  /// Should be a stable identifier that won't change (e.g., 'lose_weight').
  final String value;
  
  /// The user-friendly text displayed in the UI.
  /// This can be changed without affecting stored answers (e.g., 'Lose weight').
  final String label;

  /// Optional detailed description or explanation of this option.
  /// Displayed as secondary text under the label to provide additional context.
  final String? description;

  QuestionOption({
    required this.value,
    required this.label,
    this.description,
  });

  /// Creates a QuestionOption from a JSON map.
  /// 
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "value": "lose_weight",
  ///   "label": "Lose weight",
  ///   "description": "Focus on reducing body weight through diet and exercise"
  /// }
  /// ```
  /// 
  /// Used when loading questions from JSON configuration files.
  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      value: json['value'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
    );
  }

}