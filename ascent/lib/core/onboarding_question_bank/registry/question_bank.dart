import '../../onboarding_workflow/models/questions/question.dart';
import '../../onboarding_workflow/models/questions/question_list.dart';
import '../base/onboarding_question.dart';
import '../questions/practical_constraints/q1_injuries_question.dart';
import '../questions/practical_constraints/q2_high_impact_question.dart';
import '../questions/fitness_assessment/q3_stairs_question.dart';
import '../questions/fitness_assessment/q4_twelve_minute_run_question.dart';
import '../questions/fitness_assessment/q5_pushups_question.dart';
import '../questions/fitness_assessment/q6_structured_program_question.dart';
import '../questions/fitness_assessment/q7_free_weights_question.dart';
import '../questions/fitness_assessment/q8_training_days_question.dart';
import '../questions/fitness_assessment/q9_session_time_question.dart';
import '../questions/practical_constraints/q10_equipment_question.dart';
import '../questions/practical_constraints/q11_training_location_question.dart';
import '../questions/personal_info/age_question.dart';
import '../questions/personal_info/gender_question.dart';
import '../questions/personal_info/height_question.dart';

/// Central registry for all onboarding questions.
/// 
/// This serves as the single source of truth for questions, replacing
/// the JSON configuration file. Questions are registered here and can
/// be accessed for both UI presentation and ML evaluation.
class QuestionBank {
  
  // Registry of all questions
  static final List<OnboardingQuestion> _allQuestions = [
    // Personal Information (Demographics)
    AgeQuestion(),
    GenderQuestion(),
    HeightQuestion(),
    
    // Practical Constraints
    Q1InjuriesQuestion(),
    Q2HighImpactQuestion(),
    Q10EquipmentQuestion(),
    Q11TrainingLocationQuestion(),
    
    // Fitness Assessment Questions
    Q3StairsQuestion(),
    Q4TwelveMinuteRunQuestion(),
    Q5PushupsQuestion(),
    Q6StructuredProgramQuestion(),
    Q7FreeWeightsQuestion(),
    Q8TrainingDaysQuestion(),
    Q9SessionTimeQuestion(),
  ];
  
  //MARK: FOR UI PRESENTATION
  
  /// Get all questions formatted for the onboarding UI.
  /// This replaces loading from initial_questions.json.
  static QuestionList getQuestionList() {
    final questions = _allQuestions.map((q) => q.toPresentation()).toList();
    
    return QuestionList(
      version: '2.0', // Updated to indicate this is the new question bank system
      questions: questions,
    );
  }
  
  /// Get questions for a specific section (for sectioned display).
  static List<Question> getQuestionsForSection(String section) {
    return _allQuestions
        .where((q) => q.section == section)
        .map((q) => q.toPresentation())
        .toList();
  }
  
  //MARK: FOR EVALUATION
  
  /// Get a specific question by ID for evaluation purposes.
  static OnboardingQuestion? getQuestion(String id) {
    try {
      return _allQuestions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null; // Question not found
    }
  }
  
  /// Get all questions for batch evaluation.
  static List<OnboardingQuestion> getAllQuestions() {
    return List.unmodifiable(_allQuestions);
  }
  
  //MARK: UTILITIES
  
  /// Get all unique feature names that questions can contribute to.
  /// Useful for defining the ML feature vector dimensions.
  static Set<String> getAllFeatureNames() {
    final features = <String>{};
    final dummyContext = {'age': 35, 'gender': 'male'};
    
    for (final question in _allQuestions) {
      // Use default answer to see what features this question affects
      final defaultAnswer = question.getDefaultAnswer();
      if (defaultAnswer != null) {
        final contributions = question.evaluate(defaultAnswer, dummyContext);
        features.addAll(contributions.map((c) => c.featureName));
      }
    }
    
    return features;
  }
  
  /// Validate that all questions have unique IDs.
  /// Call this in debug builds to ensure no ID conflicts.
  static bool validateUniqueIds() {
    final ids = _allQuestions.map((q) => q.id).toSet();
    return ids.length == _allQuestions.length;
  }
  
  /// Get statistics about the question bank.
  static Map<String, dynamic> getStatistics() {
    final sectionCounts = <String, int>{};
    for (final question in _allQuestions) {
      sectionCounts[question.section] = (sectionCounts[question.section] ?? 0) + 1;
    }
    
    return {
      'total_questions': _allQuestions.length,
      'sections': sectionCounts,
      'feature_count': getAllFeatureNames().length,
      'has_unique_ids': validateUniqueIds(),
    };
  }
}