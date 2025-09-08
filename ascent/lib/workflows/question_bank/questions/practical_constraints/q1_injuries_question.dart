import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../constants.dart';

/// Q1: Do you have any current injuries or physical limitations?
/// 
/// This question differentiates between:
/// - PAIN (tap once): Chronic or activity-related pain that needs strengthening of surrounding muscles
///   Examples: back pain from poor posture, knee pain during sports, shoulder discomfort
///   Treatment: Strengthen supporting muscles, improve mobility
/// 
/// - INJURY (tap twice): Acute injuries that prevent normal motion and must be avoided
///   Examples: torn rotator cuff, herniated disc, ACL tear, fractures
///   Treatment: Avoid the area completely, work around it
/// 
/// The UI should support tap-once for pain, tap-twice for injury.
/// This distinction is critical for proper exercise prescription.
class Q1InjuriesQuestion extends OnboardingQuestion {
  static const String questionId = 'Q1';
  static final Q1InjuriesQuestion instance = Q1InjuriesQuestion._();
  Q1InjuriesQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q1InjuriesQuestion.questionId;
  
  @override
  String get questionText => 'Do you have any pain or injuries?';
  
  @override
  String get section => 'practical_constraints';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.bodyMap;
  
  @override
  String? get subtitle => 'Tap body parts to indicate pain or injury';
  
  @override
  List<QuestionOption>? get options => null; // Body map doesn't use options
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': false, // Allow user to skip if no issues
  };
  
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is List) {
      return answer.isNotEmpty && answer.every((item) => item is String);
    }
    return answer is String && answer.isNotEmpty;
  }
  
  @override
  dynamic getDefaultAnswer() => [AnswerConstants.none]; // Default to no injuries
  
  //MARK: TYPED ACCESSORS
  
  /// Get all injuries (areas to avoid) as List<String> from answers
  /// Returns items prefixed with 'injury_' (double-tapped items)
  List<String> getInjuries(Map<String, dynamic> answers) {
    final items = answers[questionId];
    if (items == null) return [];
    
    final List<String> allItems = items is List ? items.cast<String>() : [items.toString()];
    
    // Filter for injuries (prefixed with 'injury_')
    return allItems
        .where((item) => item.startsWith('injury_'))
        .map((item) => item.replaceFirst('injury_', ''))
        .toList();
  }
  
  /// Get all pain areas (areas to strengthen) as List<String> from answers
  /// Returns items prefixed with 'pain_' (single-tapped items)
  List<String> getPainAreas(Map<String, dynamic> answers) {
    final items = answers[questionId];
    if (items == null) return [];
    
    final List<String> allItems = items is List ? items.cast<String>() : [items.toString()];
    
    // Filter for pain areas (prefixed with 'pain_')
    return allItems
        .where((item) => item.startsWith('pain_'))
        .map((item) => item.replaceFirst('pain_', ''))
        .toList();
  }
  
  /// Check if user has any injuries or pain
  bool hasAnyIssues(Map<String, dynamic> answers) {
    final items = answers[questionId];
    if (items == null) return false;
    
    final List<String> allItems = items is List ? items.cast<String>() : [items.toString()];
    return allItems.isNotEmpty && !allItems.contains(AnswerConstants.none);
  }
  
  /// Legacy method - returns all items for backwards compatibility
  /// New code should use getInjuries() or getPainAreas() instead
  @Deprecated('Use getInjuries() for areas to avoid, or getPainAreas() for areas to strengthen')
  List<String> getAllIssues(Map<String, dynamic> answers) {
    final items = answers[questionId];
    if (items == null) return [AnswerConstants.none];
    if (items is List) return items.cast<String>();
    return [items.toString()];
  }
}