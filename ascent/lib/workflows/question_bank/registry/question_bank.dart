import '../questions/onboarding_question.dart';
// Demographics
import '../questions/demographics/user_name_question.dart';
import '../questions/demographics/age_question.dart';
import '../questions/demographics/gender_question.dart';
// Motivation
import '../questions/motivation/primary_motivation_question.dart';
import '../questions/motivation/progress_tracking_question.dart';
// Goals
import '../questions/goals/fitness_goals_question.dart';
// Fitness Assessment
import '../questions/fitness_assessment/q4_twelve_minute_run_question.dart';
import '../questions/fitness_assessment/q4a_fall_history_question.dart';
import '../questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../questions/fitness_assessment/q5_pushups_question.dart';
import '../questions/fitness_assessment/glp1_medications_question.dart';
import '../questions/fitness_assessment/session_commitment_question.dart';
// Lifestyle
import '../questions/lifestyle/current_diet_question.dart';
import '../questions/lifestyle/sleep_hours_question.dart';
// Practical Constraints
import '../questions/practical_constraints/q1_injuries_question.dart';
import '../questions/practical_constraints/q2_high_impact_question.dart';
import '../questions/practical_constraints/q10_equipment_question.dart';
import '../questions/practical_constraints/q11_training_location_question.dart';

/// Central registry for all onboarding questions.
/// 
/// This serves as the single source of truth for questions, replacing
/// the JSON configuration file. Questions are registered here and can
/// be accessed for both UI presentation and ML evaluation.
class QuestionBank {
  
  // Registry of all questions in the correct order (following JSON structure)
  static final List<OnboardingQuestion> _allQuestions = [
    // 1. Demographics
    UserNameQuestion.instance,           // user_name
    AgeQuestion.instance,                // age  
    GenderQuestion.instance,             // gender
    
    // 2. Motivation
    PrimaryMotivationQuestion.instance,  // primary_motivation
    ProgressTrackingQuestion.instance,   // progress_tracking
    
    // 3. Goals
    FitnessGoalsQuestion.instance,       // fitness_goals
    
    // 4. Fitness Assessment
    Q4TwelveMinuteRunQuestion.instance,  // Q4 (12-min run)
    Q4AFallHistoryQuestion.instance,     // Q4A (fall history - conditional)
    Q4BFallRiskFactorsQuestion.instance, // Q4B (fall risk factors - conditional)
    Q5PushupsQuestion.instance,          // pushups_count (Q5)
    
    // 5. Lifestyle
    CurrentDietQuestion.instance,        // current_diet
    Glp1MedicationsQuestion.instance,    // GLP-1 medications
    SleepHoursQuestion.instance,         // sleep_hours
    
    // 6. Schedule and Commitment
    SessionCommitmentQuestion.instance,  // session_commitment (replaces 4 questions)
    
    // 9. Physical Constraints
    Q1InjuriesQuestion.instance,         // Q1 (injuries)
    Q2HighImpactQuestion.instance,       // Q2 (high impact)
    Q10EquipmentQuestion.instance,       // Q10 (equipment)
    Q11TrainingLocationQuestion.instance, // Q11 (location)
  ];
  
  //MARK: INITIALIZATION
  
  /// Initialize and get all questions.
  static List<OnboardingQuestion> initialize() {
    return List.unmodifiable(_allQuestions);
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
  
  //MARK: SERIALIZATION
  
  /// Serialize all answers to JSON for storage.
  /// Returns a map with question IDs as keys and serialized answers as values.
  static Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    for (final question in _allQuestions) {
      final jsonData = question.toJson();
      result[jsonData['id']] = jsonData['answer'];
    }
    return result;
  }
  
  /// Deserialize answers from JSON storage.
  /// Updates each question's answer from the stored JSON data.
  static void fromJson(Map<String, dynamic> json) {
    for (final question in _allQuestions) {
      final answerData = json[question.id];
      if (answerData != null) {
        question.fromJson({
          'id': question.id,
          'answer': answerData,
        });
      }
    }
  }
  
  /// Get typed question instance by type.
  /// Useful for accessing specific questions with their typed interfaces.
  static T getQuestionByType<T extends OnboardingQuestion>() {
    return _allQuestions.whereType<T>().first;
  }
}