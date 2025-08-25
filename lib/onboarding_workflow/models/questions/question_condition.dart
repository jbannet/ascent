/// Defines conditional logic for when a question should be shown or hidden.
/// 
/// This class creates dependencies between questions. A question with a condition
/// will only be displayed if the condition evaluates to true based on a previous
/// answer. This enables dynamic, branching question flows.
/// 
/// Example scenarios:
/// - Show "How much weight?" only if user selected "Lose weight" as a goal
/// - Show medical clearance question only if user has health conditions
/// - Show equipment question only if user selected "Home" as workout location
/// 
/// Used by:
/// - [OnboardingQuestion] to store display conditions
/// - [OnboardingProvider] to determine which questions to show
/// - Question flow navigation to skip hidden questions
/// 
/// Example in JSON:
/// ```json
/// "condition": {
///   "question_id": "goals",
///   "operator": "contains",
///   "value": "lose_weight"
/// }
/// ```
class QuestionCondition {
  /// The ID of the question whose answer we're checking.
  /// This must be a question that appears earlier in the flow.
  /// Example: "goals", "has_medical_conditions", "workout_location"
  final String questionId;
  
  /// The comparison operator to use.
  /// Supported operators:
  /// - "equals": Answer must exactly match the value
  /// - "contains": Answer (list or string) must contain the value  
  /// - "isNotEmpty": Answer must exist and not be empty
  final String operator;
  
  /// The value to compare against (optional for some operators).
  /// - Required for "equals" and "contains" operators
  /// - Not used for "isNotEmpty" operator
  /// Can be a string, number, or any JSON-compatible type.
  final dynamic value;

  QuestionCondition({
    required this.questionId,
    required this.operator,
    this.value,
  });

  /// Creates a condition from a JSON map.
  /// 
  /// Used when loading questions from JSON configuration.
  factory QuestionCondition.fromJson(Map<String, dynamic> json) {
    return QuestionCondition(
      questionId: json['question_id'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }


  /// Evaluates whether this condition is met given an answer.
  /// 
  /// [answer] is the stored answer for the question specified by [questionId].
  /// 
  /// Returns true if:
  /// - operator is "equals" and answer matches value exactly
  /// - operator is "contains" and answer (list/string) contains value
  /// - operator is "isNotEmpty" and answer exists and isn't empty
  /// - operator is unknown (defaults to true for safety)
  /// 
  /// This method is called by OnboardingQuestion.shouldShow() to determine
  /// if a question should be visible based on previous answers.
  bool evaluate(dynamic answer) {
    switch (operator) {
      case 'equals':
        return answer == value;
      case 'contains':
        if (answer is List) {
          return answer.contains(value);
        }
        if (answer is String) {
          return answer.contains(value);
        }
        return false;
      case 'isNotEmpty':
        if (answer == null) return false;
        if (answer is String) return answer.isNotEmpty;
        if (answer is List) return answer.isNotEmpty;
        return true;
      default:
        return true;
    }
  }
}