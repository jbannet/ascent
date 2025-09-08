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
enum EnumQuestionType {
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
  datePicker,
  
  /// Body map selector for pain/injury locations
  /// Single tap marks as pain (to strengthen), double tap marks as injury (to avoid)
  bodyMap,
  
  /// Dual column selector for session commitment
  /// Two columns of buttons (0-7) for selecting days per week
  /// Left column for full sessions, right for micro sessions
  dualColumnSelector
}

extension QuestionTypeExtension on EnumQuestionType {

  /// Parses a JSON string value into the corresponding QuestionType enum.
  /// 
  /// Used when loading questions from JSON configuration files.
  /// Throws [ArgumentError] if the string doesn't match any known type.
  static EnumQuestionType fromJson(String value) {
    switch (value) {
      case 'text_input':
        return EnumQuestionType.textInput;
      case 'number_input':
        return EnumQuestionType.numberInput;
      case 'single_choice':
        return EnumQuestionType.singleChoice;
      case 'multiple_choice':
        return EnumQuestionType.multipleChoice;
      case 'slider':
        return EnumQuestionType.slider;
      case 'date_picker':
        return EnumQuestionType.datePicker;
      case 'body_map':
        return EnumQuestionType.bodyMap;
      case 'dual_column_selector':
        return EnumQuestionType.dualColumnSelector;
      default:
        throw ArgumentError('Unknown question type: $value');
    }
  }
}