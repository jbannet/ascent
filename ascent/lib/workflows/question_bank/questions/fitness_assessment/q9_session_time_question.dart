import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../../../models/fitness_profile_model/feature_contribution.dart';

/// Q9: How much time can you dedicate to each workout session?
/// 
/// This question assesses time constraints and workout structure preferences.
/// It contributes to program design, exercise selection, and efficiency features.
class Q9SessionTimeQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q9';
  
  @override
  String get questionText => 'How much time can you dedicate to each workout session?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Include warm-up, workout, and cool-down time';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: '15', label: '15 minutes or less'),
    QuestionOption(value: '30', label: '30 minutes'),
    QuestionOption(value: '45', label: '45 minutes'),
    QuestionOption(value: '60', label: '1 hour'),
    QuestionOption(value: '90', label: '1.5 hours'),
    QuestionOption(value: '120', label: '2+ hours'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final sessionMinutes = int.parse(answer.toString());
    final timeScore = _calculateTimeScore(sessionMinutes);
    final efficiency = _calculateEfficiencyNeed(sessionMinutes);
    
    return [
      // Time availability and constraints
      FeatureContribution('session_time_available', timeScore),
      FeatureContribution('workout_duration_minutes', sessionMinutes / 120.0), // Normalize to 0-1
      
      // Program structure implications
      FeatureContribution('requires_efficient_workouts', efficiency),
      FeatureContribution('compound_movement_priority', sessionMinutes <= 45 ? 1.0 : 0.0),
      FeatureContribution('can_handle_longer_sessions', sessionMinutes >= 60 ? 1.0 : 0.0),
      
      // Exercise selection preferences
      FeatureContribution('prefers_circuit_training', sessionMinutes <= 30 ? 1.0 : 0.0),
      FeatureContribution('supersets_suitable', sessionMinutes <= 45 ? 1.0 : 0.0),
      FeatureContribution('isolation_exercises_feasible', sessionMinutes >= 60 ? 1.0 : 0.0),
      
      // Training volume capacity
      FeatureContribution('volume_per_session_capacity', _calculateVolumeCapacity(sessionMinutes)),
      FeatureContribution('exercise_variety_per_session', _calculateVarietyCapacity(sessionMinutes)),
      
      // Intensity and rest considerations
      FeatureContribution('rest_time_flexibility', _calculateRestFlexibility(sessionMinutes)),
      FeatureContribution('high_intensity_suitable', sessionMinutes <= 30 ? 1.0 : 0.0),
      
      // Program design preferences
      FeatureContribution('full_body_session_suitable', sessionMinutes >= 45 ? 1.0 : 0.0),
      FeatureContribution('focused_body_part_suitable', sessionMinutes <= 45 ? 1.0 : 0.0),
      
      // Adherence and sustainability
      FeatureContribution('time_adherence_likelihood', _calculateAdherenceLikelihood(sessionMinutes)),
      FeatureContribution('schedule_sustainability', _calculateSustainability(sessionMinutes)),
      
      // Specialization and depth
      FeatureContribution('skill_development_time', sessionMinutes >= 60 ? 1.0 : 0.0),
      FeatureContribution('technique_focus_feasible', sessionMinutes >= 45 ? 1.0 : 0.0),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['15', '30', '45', '60', '90', '120'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => '45'; // 45 minutes is a good balance
  
  //MARK: PRIVATE HELPERS
  
  /// Calculate time adequacy score
  double _calculateTimeScore(int minutes) {
    // 45-60 minutes is often considered optimal for most people
    if (minutes >= 45 && minutes <= 60) return 1.0;  // Optimal
    if (minutes == 30 || minutes == 90) return 0.8;  // Good
    if (minutes == 15 || minutes >= 120) return 0.6; // Challenging but workable
    return 0.5; // Default fallback
  }
  
  /// Calculate need for workout efficiency
  double _calculateEfficiencyNeed(int minutes) {
    if (minutes <= 15) return 1.0;   // Extreme efficiency needed
    if (minutes <= 30) return 0.8;   // High efficiency needed
    if (minutes <= 45) return 0.6;   // Moderate efficiency needed
    if (minutes <= 60) return 0.4;   // Some efficiency helpful
    return 0.2; // Low efficiency pressure
  }
  
  /// Calculate volume capacity per session
  double _calculateVolumeCapacity(int minutes) {
    // More time = more volume capacity
    if (minutes <= 15) return 0.2;
    if (minutes <= 30) return 0.4;
    if (minutes <= 45) return 0.7;
    if (minutes <= 60) return 1.0;
    if (minutes <= 90) return 1.0; // Plateau at 60 minutes for most people
    return 0.9; // Diminishing returns beyond 90 minutes
  }
  
  /// Calculate exercise variety capacity
  double _calculateVarietyCapacity(int minutes) {
    // Longer sessions can accommodate more exercises
    return (minutes / 90.0).clamp(0.1, 1.0);
  }
  
  /// Calculate rest time flexibility
  double _calculateRestFlexibility(int minutes) {
    if (minutes <= 15) return 0.1;   // Very limited rest
    if (minutes <= 30) return 0.4;   // Short rest periods
    if (minutes <= 45) return 0.7;   // Moderate rest flexibility
    if (minutes <= 60) return 0.9;   // Good rest flexibility
    return 1.0; // Full rest flexibility
  }
  
  /// Calculate likelihood of maintaining time commitment
  double _calculateAdherenceLikelihood(int minutes) {
    // Research suggests 30-60 minutes has highest adherence
    if (minutes >= 30 && minutes <= 60) return 1.0;  // Highest adherence
    if (minutes == 15 || minutes == 90) return 0.8;  // Good adherence
    return 0.6; // Lower adherence for extreme durations
  }
  
  /// Calculate sustainability of time commitment
  double _calculateSustainability(int minutes) {
    // Moderate time commitments are most sustainable
    if (minutes >= 30 && minutes <= 60) return 1.0;  // Highly sustainable
    if (minutes == 15 || minutes == 90) return 0.7;  // Moderately sustainable
    return 0.5; // Challenging sustainability
  }
}