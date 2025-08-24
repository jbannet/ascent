/// Defines the different input types available for onboarding questions.
/// 
/// This enum is used by [OnboardingQuestion] to determine which UI widget
/// should be displayed for user input. Each type corresponds to a specific
/// input widget in the onboarding UI.
/// 
/// Used by:
/// - [OnboardingQuestion] to specify the input type
/// - UI widgets to render the appropriate input control
/// - JSON parser when loading questions from configuration
enum QuestionType {
  /// Free text input field (e.g., name, email)
  textInput,
  
  /// Numeric input field with number keyboard (e.g., age, weight)
  numberInput,
  
  /// Radio button selection - user can only choose one option (e.g., gender)
  singleChoice,
  
  /// Checkbox selection - user can choose multiple options (e.g., fitness goals)
  multipleChoice,
  
  /// Sliding scale for range selection (e.g., 1-10 scale, 0-100%)
  slider,
  
  /// Calendar date picker (e.g., target date, birthday)
  datePicker
}

extension QuestionTypeExtension on QuestionType {
  /// Converts the enum to a JSON-compatible string format.
  /// 
  /// Used when saving questions to JSON files or sending to Firebase.
  /// Converts Dart naming convention (camelCase) to JSON convention (snake_case).
  String toJson() {
    switch (this) {
      case QuestionType.textInput:
        return 'text_input';
      case QuestionType.numberInput:
        return 'number_input';
      case QuestionType.singleChoice:
        return 'single_choice';
      case QuestionType.multipleChoice:
        return 'multiple_choice';
      case QuestionType.slider:
        return 'slider';
      case QuestionType.datePicker:
        return 'date_picker';
    }
  }

  /// Parses a JSON string value into the corresponding QuestionType enum.
  /// 
  /// Used when loading questions from JSON configuration files.
  /// Throws [ArgumentError] if the string doesn't match any known type.
  static QuestionType fromJson(String value) {
    switch (value) {
      case 'text_input':
        return QuestionType.textInput;
      case 'number_input':
        return QuestionType.numberInput;
      case 'single_choice':
        return QuestionType.singleChoice;
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'slider':
        return QuestionType.slider;
      case 'date_picker':
        return QuestionType.datePicker;
      default:
        throw ArgumentError('Unknown question type: $value');
    }
  }
}