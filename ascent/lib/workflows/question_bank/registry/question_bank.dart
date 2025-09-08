import '../questions/onboarding_question.dart';
// Demographics
import '../questions/demographics/user_name_question.dart';
import '../questions/demographics/age_question.dart';
import '../questions/demographics/gender_question.dart';
import '../questions/demographics/height_question.dart';
// Motivation
import '../questions/motivation/primary_motivation_question.dart';
import '../questions/motivation/progress_tracking_question.dart';
// Goals
import '../questions/goals/fitness_goals_question.dart';
import '../questions/goals/weight_loss_target_question.dart';
import '../questions/goals/target_completion_date_question.dart';
// Fitness Assessment
import '../questions/fitness_assessment/current_fitness_level_question.dart';
import '../questions/fitness_assessment/q3_stairs_question.dart';
import '../questions/fitness_assessment/q4_twelve_minute_run_question.dart';
import '../questions/fitness_assessment/q4a_fall_history_question.dart';
import '../questions/fitness_assessment/q4b_fall_risk_factors_question.dart';
import '../questions/fitness_assessment/q5_pushups_question.dart';
import '../questions/fitness_assessment/current_activities_question.dart';
import '../questions/fitness_assessment/q6_structured_program_question.dart';
import '../questions/fitness_assessment/q7_free_weights_question.dart';
import '../questions/fitness_assessment/workout_frequency_question.dart';
import '../questions/fitness_assessment/q8_training_days_question.dart';
import '../questions/fitness_assessment/workout_duration_question.dart';
import '../questions/fitness_assessment/q9_session_time_question.dart';
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
    HeightQuestion.instance,             // height
    
    // 2. Motivation
    PrimaryMotivationQuestion.instance,  // primary_motivation
    ProgressTrackingQuestion.instance,   // progress_tracking
    
    // 3. Goals
    FitnessGoalsQuestion.instance,       // fitness_goals
    WeightLossTargetQuestion.instance,   // weight_loss_target (conditional)
    
    // 4. Fitness Assessment
    CurrentFitnessLevelQuestion.instance, // current_fitness_level
    Q3StairsQuestion.instance,           // Q3 (stairs)
    Q4TwelveMinuteRunQuestion.instance,  // Q4 (12-min run)
    Q4AFallHistoryQuestion.instance,     // Q4A (fall history - conditional)
    Q4BFallRiskFactorsQuestion.instance, // Q4B (fall risk factors - conditional)
    Q5PushupsQuestion.instance,          // pushups_count (Q5)
    
    // 5. Lifestyle
    CurrentDietQuestion.instance,        // current_diet
    SleepHoursQuestion.instance,         // sleep_hours
    
    // 6. Current Activities
    CurrentActivitiesQuestion.instance,  // current_activities
    
    // 7. Training Experience
    Q6StructuredProgramQuestion.instance, // Q6 (structured program)
    Q7FreeWeightsQuestion.instance,      // Q7 (free weights)
    
    // 8. Schedule and Constraints
    WorkoutFrequencyQuestion.instance,   // workout_frequency (similar to Q8)
    Q8TrainingDaysQuestion.instance,     // Q8 (training days) - keep both for now
    WorkoutDurationQuestion.instance,    // workout_duration (similar to Q9)
    Q9SessionTimeQuestion.instance,      // Q9 (session time) - keep both for now
    
    // 9. Physical Constraints
    Q1InjuriesQuestion.instance,         // Q1 (injuries)
    Q2HighImpactQuestion.instance,       // Q2 (high impact)
    Q10EquipmentQuestion.instance,       // Q10 (equipment)
    Q11TrainingLocationQuestion.instance, // Q11 (location)
    
    // 10. Goals Timeline
    TargetCompletionDateQuestion.instance, // target_completion_date
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
}