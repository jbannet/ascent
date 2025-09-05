import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../onboarding_question.dart';
import '../../models/feature_contribution.dart';

/// Q8: How many days per week can you realistically commit to training?
/// 
/// This question assesses training frequency commitment and schedule constraints.
/// It contributes to program structure, volume, and adherence features.
class Q8TrainingDaysQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'Q8';
  
  @override
  String get questionText => 'How many days per week can you realistically commit to training?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.singleChoice;
  
  @override
  String? get subtitle => 'Be realistic about your schedule and lifestyle';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(value: '1', label: '1 day per week'),
    QuestionOption(value: '2', label: '2 days per week'),
    QuestionOption(value: '3', label: '3 days per week'),
    QuestionOption(value: '4', label: '4 days per week'),
    QuestionOption(value: '5', label: '5 days per week'),
    QuestionOption(value: '6', label: '6+ days per week'),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, double> features, Map<String, double> demographics) {
    final daysPerWeek = int.parse(answer.toString());
    final frequencyScore = _calculateFrequencyScore(daysPerWeek);
    
    return [
      // Training frequency and commitment
      FeatureContribution('training_frequency', frequencyScore),
      FeatureContribution('weekly_training_days', daysPerWeek / 7.0), // Normalize to 0-1
      
      // Program structure implications
      FeatureContribution('full_body_program_suitable', daysPerWeek <= 3 ? 1.0 : 0.0),
      FeatureContribution('split_program_suitable', daysPerWeek >= 4 ? 1.0 : 0.0),
      FeatureContribution('high_frequency_capable', daysPerWeek >= 5 ? 1.0 : 0.0),
      
      // Volume and intensity distribution
      FeatureContribution('training_volume_capacity', _calculateVolumeCapacity(daysPerWeek)),
      FeatureContribution('intensity_distribution_factor', _calculateIntensityFactor(daysPerWeek)),
      
      // Recovery considerations
      FeatureContribution('recovery_time_available', _calculateRecoveryTime(daysPerWeek)),
      FeatureContribution('overtraining_risk', _calculateOvertrainingRisk(daysPerWeek)),
      
      // Adherence and sustainability
      FeatureContribution('schedule_adherence_likelihood', _calculateAdherenceLikelihood(daysPerWeek)),
      FeatureContribution('lifestyle_integration', _calculateLifestyleIntegration(daysPerWeek)),
      
      // Program design preferences
      FeatureContribution('prefers_efficient_workouts', daysPerWeek <= 3 ? 1.0 : 0.0),
      FeatureContribution('can_handle_daily_variation', daysPerWeek >= 5 ? 1.0 : 0.0),
      
      // Commitment level indicator
      FeatureContribution('training_commitment_level', frequencyScore),
      
      // Specialization capability
      FeatureContribution('specialization_training_ready', daysPerWeek >= 4 ? 1.0 : 0.0),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    final validOptions = ['1', '2', '3', '4', '5', '6'];
    return validOptions.contains(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => '3'; // 3 days is often recommended minimum
  
  //MARK: PRIVATE HELPERS
  
  /// Calculate frequency score based on training days
  double _calculateFrequencyScore(int days) {
    // Optimal training frequency is often considered 3-5 days
    if (days == 3 || days == 4) return 1.0;  // Optimal
    if (days == 2 || days == 5) return 0.9;  // Very good
    if (days == 1) return 0.5;               // Minimum effective dose
    if (days >= 6) return 0.7;               // High but potentially unsustainable
    return 0.5; // Default fallback
  }
  
  /// Calculate training volume capacity
  double _calculateVolumeCapacity(int days) {
    // More days = more volume capacity, but with diminishing returns
    return (days / 7.0).clamp(0.0, 1.0);
  }
  
  /// Calculate intensity distribution factor
  double _calculateIntensityFactor(int days) {
    if (days <= 2) return 1.0;  // Can train high intensity each session
    if (days <= 4) return 0.8;  // Need some intensity variation
    return 0.6; // Need careful intensity management
  }
  
  /// Calculate available recovery time
  double _calculateRecoveryTime(int days) {
    final restDays = 7 - days;
    return (restDays / 7.0).clamp(0.0, 1.0);
  }
  
  /// Calculate risk of overtraining
  double _calculateOvertrainingRisk(int days) {
    if (days <= 3) return 0.1;   // Low risk
    if (days <= 5) return 0.3;   // Moderate risk
    return 0.7; // Higher risk with 6+ days
  }
  
  /// Calculate likelihood of maintaining schedule
  double _calculateAdherenceLikelihood(int days) {
    // Research suggests 3-4 days has highest adherence
    if (days == 3) return 1.0;   // Highest adherence
    if (days == 2 || days == 4) return 0.9;  // High adherence
    if (days == 1 || days == 5) return 0.7;  // Moderate adherence
    return 0.5; // Lower adherence for extreme frequencies
  }
  
  /// Calculate how well training integrates with lifestyle
  double _calculateLifestyleIntegration(int days) {
    // Moderate frequency typically integrates better with busy lifestyles
    if (days >= 2 && days <= 4) return 1.0;  // Good integration
    if (days == 1 || days == 5) return 0.7;  // Moderate integration
    return 0.4; // Challenging integration
  }
}