import 'package:flutter/material.dart';
import '../../onboarding_workflow/models/questions/question.dart';
import '../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../onboarding_workflow/models/questions/question_option.dart';
import '../../onboarding_workflow/models/questions/question_condition.dart';
import '../views/base_question_view.dart';
import '../views/question_types/text_input_view.dart';
import '../views/question_types/number_input_view.dart';
import '../views/question_types/single_choice_view.dart';
import '../views/question_types/multiple_choice_view.dart';
import '../views/question_types/slider_view.dart';
import '../views/question_types/date_picker_view.dart';
import '../../onboarding_workflow/widgets/onboarding/question_input/body_map_widget.dart';
import '../../onboarding_workflow/widgets/onboarding/question_input/dual_column_selector_widget.dart';
import '../../onboarding_workflow/widgets/onboarding/question_input/height_selector_widget.dart';

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
  
  /// Store the raw answer for this question.
  /// 
  /// [answer] is the user's response (String, num, List of String, etc.)
  /// [answers] is the raw answers map where the answer will be stored
  /// 
  /// By default, simply stores the answer using the question's ID as the key.
  /// Override if special storage logic is needed.
  void storeAnswer(dynamic answer, Map<String, dynamic> answers) {
    answers[id] = answer;
  }
  
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
  /// [currentAnswers] contains all current answers indexed by question ID
  /// [onAnswerChanged] callback for when the user changes their answer  
  /// [accentColor] optional color override for theming
  Widget renderQuestionView({
    required Map<String, dynamic> currentAnswers,
    required Function(String, dynamic) onAnswerChanged,
    Color? accentColor,
  }) {
    return BaseQuestionView(
      questionId: id,
      questionText: questionText,
      subtitle: subtitle,
      reason: null, // Can be overridden by individual questions if needed
      accentColor: accentColor,
      answerWidget: _buildAnswerWidget(currentAnswers, onAnswerChanged),
    );
  }
  
  /// Build the appropriate answer widget based on question type.
  /// This encapsulates the type-specific rendering logic.
  Widget _buildAnswerWidget(
    Map<String, dynamic> currentAnswers, 
    Function(String, dynamic) onAnswerChanged,
  ) {
    final currentAnswer = currentAnswers[id];
    
    switch (questionType) {
      case EnumQuestionType.textInput:
        return TextInputView(
          questionId: id,
          currentAnswer: currentAnswer as String?,
          onAnswerChanged: (questionId, value) => onAnswerChanged(questionId, value),
          config: config,
        );
        
      case EnumQuestionType.numberInput:
        return NumberInputView(
          questionId: id,
          currentAnswer: currentAnswer as num?,
          onAnswerChanged: (questionId, value) => onAnswerChanged(questionId, value),
          config: config,
        );
        
      case EnumQuestionType.singleChoice:
        return SingleChoiceView(
          questionId: id,
          currentAnswer: currentAnswer as String?,
          onAnswerChanged: (questionId, value) => onAnswerChanged(questionId, value),
          options: options ?? [],
        );
        
      case EnumQuestionType.multipleChoice:
        return MultipleChoiceView(
          questionId: id,
          currentAnswer: currentAnswer as List<String>?,
          onAnswerChanged: (questionId, value) => onAnswerChanged(questionId, value),
          options: options ?? [],
          config: config,
        );
        
      case EnumQuestionType.slider:
        return SliderView(
          questionId: id,
          currentAnswer: currentAnswer as double?,
          onAnswerChanged: (questionId, value) => onAnswerChanged(questionId, value),
          config: config,
        );
        
      case EnumQuestionType.datePicker:
        return DatePickerView(
          questionId: id,
          currentAnswer: currentAnswer as DateTime?,
          onAnswerChanged: (questionId, value) => onAnswerChanged(questionId, value),
          config: config,
        );
        
      case EnumQuestionType.bodyMap:
        return BodyMapWidget(
          questionId: id,
          title: questionText,
          subtitle: subtitle,
          onAnswerChanged: (questionId, values) => onAnswerChanged(questionId, values),
          selectedValues: currentAnswer == null 
              ? null 
              : currentAnswer is List 
                  ? currentAnswer.cast<String>()
                  : currentAnswer is String 
                      ? [currentAnswer]
                      : null,
        );
        
      case EnumQuestionType.dualColumnSelector:
        return DualColumnSelectorWidget(
          config: config ?? {},
          onChanged: (value) => onAnswerChanged(id, value),
          initialValue: currentAnswer is Map<String, dynamic>
              ? currentAnswer
              : null,
        );
        
      case EnumQuestionType.heightSelector:
        return HeightSelectorWidget(
          config: config ?? {},
          onChanged: (value) => onAnswerChanged(id, value),
          initialValue: currentAnswer is Map<String, dynamic>
              ? currentAnswer
              : null,
        );
    }
  }
}