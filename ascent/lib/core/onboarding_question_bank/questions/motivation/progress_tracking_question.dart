import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../../base/onboarding_question.dart';
import '../../base/feature_contribution.dart';

/// Progress tracking preferences question for understanding how users like to monitor their fitness journey.
/// 
/// This question identifies preferred tracking methods to customize the app's
/// progress monitoring and feedback systems.
class ProgressTrackingQuestion extends OnboardingQuestion {
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => 'progress_tracking';
  
  @override
  String get questionText => 'How do you prefer to track progress?';
  
  @override
  String get section => 'motivation';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.multipleChoice;
  
  @override
  String? get subtitle => 'Choose up to 3 methods';
  
  @override
  List<QuestionOption> get options => [
    QuestionOption(
      value: 'photos_measurements',
      label: 'Photos and measurements',
      description: 'Visual tracking of body changes',
    ),
    QuestionOption(
      value: 'performance_metrics',
      label: 'Performance metrics',
      description: 'Reps, time, weight, distance',
    ),
    QuestionOption(
      value: 'daily_feeling',
      label: 'How I feel day-to-day',
      description: 'Energy levels and mood tracking',
    ),
    QuestionOption(
      value: 'habit_streaks',
      label: 'Habit streaks and consistency',
      description: 'Tracking workout frequency',
    ),
    QuestionOption(
      value: 'milestones',
      label: 'Milestones and accomplishments',
      description: 'Achievement badges and goals',
    ),
  ];
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'allowMultiple': true,
    'minSelections': 1,
    'maxSelections': 3,
  };
  
  //MARK: EVALUATION LOGIC
  
  @override
  List<FeatureContribution> evaluate(dynamic answer, Map<String, dynamic> context) {
    final selections = answer is List ? answer.cast<String>() : [answer.toString()];
    final trackingCount = selections.length;
    
    return [
      // Specific tracking preferences
      FeatureContribution('tracks_photos_measurements', selections.contains('photos_measurements') ? 1.0 : 0.0),
      FeatureContribution('tracks_performance_metrics', selections.contains('performance_metrics') ? 1.0 : 0.0),
      FeatureContribution('tracks_daily_feeling', selections.contains('daily_feeling') ? 1.0 : 0.0),
      FeatureContribution('tracks_habit_streaks', selections.contains('habit_streaks') ? 1.0 : 0.0),
      FeatureContribution('tracks_milestones', selections.contains('milestones') ? 1.0 : 0.0),
      
      // Tracking behavior patterns
      FeatureContribution('tracking_variety', trackingCount / 5.0), // Normalize to 0-1
      FeatureContribution('prefers_objective_tracking', _prefersObjective(selections) ? 1.0 : 0.0),
      FeatureContribution('prefers_subjective_tracking', _prefersSubjective(selections) ? 1.0 : 0.0),
      FeatureContribution('prefers_visual_tracking', _prefersVisual(selections) ? 1.0 : 0.0),
      
      // Engagement and motivation indicators
      FeatureContribution('high_tracking_engagement', trackingCount >= 3 ? 1.0 : 0.0),
      FeatureContribution('gamification_responsive', selections.contains('milestones') ? 1.0 : 0.0),
      FeatureContribution('consistency_focused', selections.contains('habit_streaks') ? 1.0 : 0.0),
      
      // App feature preferences
      FeatureContribution('needs_photo_features', selections.contains('photos_measurements') ? 1.0 : 0.0),
      FeatureContribution('needs_performance_dashboards', selections.contains('performance_metrics') ? 1.0 : 0.0),
      FeatureContribution('needs_mood_tracking', selections.contains('daily_feeling') ? 1.0 : 0.0),
      FeatureContribution('needs_streak_tracking', selections.contains('habit_streaks') ? 1.0 : 0.0),
      FeatureContribution('needs_achievement_system', selections.contains('milestones') ? 1.0 : 0.0),
      
      // Progress monitoring style
      FeatureContribution('detailed_tracker', _isDetailedTracker(selections) ? 1.0 : 0.0),
      FeatureContribution('simple_tracker', _isSimpleTracker(selections) ? 1.0 : 0.0),
      
      // Long-term adherence indicators
      FeatureContribution('tracking_sustainability', _getTrackingSustainability(selections)),
      FeatureContribution('motivation_maintenance', _getMotivationMaintenance(selections)),
    ];
  }
  
  //MARK: VALIDATION
  
  @override
  bool isValidAnswer(dynamic answer) {
    if (answer is List) {
      final selections = answer.cast<String>();
      return selections.length >= 1 && 
             selections.length <= 3 && 
             selections.every((item) => _isValidOption(item));
    }
    return _isValidOption(answer.toString());
  }
  
  @override
  dynamic getDefaultAnswer() => ['performance_metrics']; // Most common tracking method
  
  //MARK: PRIVATE HELPERS
  
  /// Check if selection is a valid option
  bool _isValidOption(String option) {
    final validOptions = [
      'photos_measurements', 'performance_metrics', 'daily_feeling',
      'habit_streaks', 'milestones'
    ];
    return validOptions.contains(option);
  }
  
  /// Check if user prefers objective tracking methods
  bool _prefersObjective(List<String> selections) {
    final objective = ['photos_measurements', 'performance_metrics', 'habit_streaks'];
    return selections.any((selection) => objective.contains(selection));
  }
  
  /// Check if user prefers subjective tracking methods
  bool _prefersSubjective(List<String> selections) {
    final subjective = ['daily_feeling', 'milestones'];
    return selections.any((selection) => subjective.contains(selection));
  }
  
  /// Check if user prefers visual tracking methods
  bool _prefersVisual(List<String> selections) {
    final visual = ['photos_measurements', 'milestones', 'habit_streaks'];
    return selections.any((selection) => visual.contains(selection));
  }
  
  /// Check if user is a detailed tracker
  bool _isDetailedTracker(List<String> selections) {
    return selections.length >= 2 && 
           selections.contains('performance_metrics') &&
           (selections.contains('photos_measurements') || selections.contains('daily_feeling'));
  }
  
  /// Check if user is a simple tracker
  bool _isSimpleTracker(List<String> selections) {
    return selections.length == 1 || 
           (selections.length == 2 && selections.contains('habit_streaks'));
  }
  
  /// Calculate tracking sustainability score
  double _getTrackingSustainability(List<String> selections) {
    double score = 0.0;
    
    // Sustainable tracking methods
    if (selections.contains('habit_streaks')) score += 0.4; // Very sustainable
    if (selections.contains('daily_feeling')) score += 0.3; // Easy to maintain
    if (selections.contains('performance_metrics')) score += 0.2; // Moderate sustainability
    if (selections.contains('milestones')) score += 0.2; // Depends on goal setting
    if (selections.contains('photos_measurements')) score += 0.1; // Can be challenging
    
    return score.clamp(0.0, 1.0);
  }
  
  /// Calculate motivation maintenance score
  double _getMotivationMaintenance(List<String> selections) {
    double score = 0.0;
    
    // Methods that help maintain motivation
    if (selections.contains('milestones')) score += 0.3; // Achievement-based motivation
    if (selections.contains('habit_streaks')) score += 0.3; // Consistency motivation
    if (selections.contains('daily_feeling')) score += 0.2; // Internal motivation
    if (selections.contains('performance_metrics')) score += 0.2; // Progress motivation
    if (selections.contains('photos_measurements')) score += 0.1; // Visual motivation
    
    return score.clamp(0.0, 1.0);
  }
}