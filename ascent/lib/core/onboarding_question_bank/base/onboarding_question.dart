import '../../onboarding_workflow/models/questions/question.dart';
import '../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../onboarding_workflow/models/questions/question_option.dart';
import '../../onboarding_workflow/models/questions/question_condition.dart';
import 'feature_contribution.dart';

/// Base class for all onboarding questions.
/// 
/// Each question serves as a single source of truth containing both:
/// 1. UI presentation data (question text, options, validation)
/// 2. Evaluation logic (how answers contribute to ML features)
/// 
/// This ensures the question UI and its impact on fitness assessment
/// are always in sync and defined in one place.
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
  
  //MARK: EVALUATION LOGIC
  
  /// Evaluate how this question's answer contributes to ML features.
  /// 
  /// [answer] is the user's response (String, num, List of String, etc.)
  /// [context] contains other data needed for evaluation (age, gender, other answers)
  /// 
  /// Returns a list of feature contributions from this answer.
  List<FeatureContribution> evaluate(
    dynamic answer,
    Map<String, dynamic> context,
  );
  
  //MARK: VALIDATION
  
  /// Validate that an answer is acceptable for this question.
  /// Override for custom validation beyond basic type checking.
  bool isValidAnswer(dynamic answer) => true;
  
  /// Get a default value if the user hasn't answered this question.
  /// Override to provide sensible defaults for optional questions.
  dynamic getDefaultAnswer() => null;
}