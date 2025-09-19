import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../models/questions/question_option.dart';
import '../../../views/question_views/question_types/multiple_choice_view.dart';
import '../onboarding_question.dart';
import '../../../../../constants_and_enums/constants.dart';

/// Progress tracking preferences question for understanding how users like to monitor their fitness journey.
/// 
/// This question identifies preferred tracking methods to customize the app's
/// progress monitoring and feedback systems.
class ProgressTrackingQuestion extends OnboardingQuestion {
  static const String questionId = 'progress_tracking';
  static final ProgressTrackingQuestion instance = ProgressTrackingQuestion._();
  ProgressTrackingQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => ProgressTrackingQuestion.questionId;
  
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
      value: AnswerConstants.photosMeasurements,
      label: 'Photos and measurements',
      description: 'Visual tracking of body changes',
    ),
    QuestionOption(
      value: AnswerConstants.performanceMetrics,
      label: 'Performance metrics',
      description: 'Reps, time, weight, distance',
    ),
    QuestionOption(
      value: AnswerConstants.dailyFeeling,
      label: 'How I feel day-to-day',
      description: 'Energy levels and mood tracking',
    ),
    QuestionOption(
      value: AnswerConstants.habitStreaks,
      label: 'Habit streaks and consistency',
      description: 'Tracking workout frequency',
    ),
    QuestionOption(
      value: AnswerConstants.milestones,
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
  
  //MARK: VALIDATION
  
  bool isValidAnswer(dynamic answer) {
    if (answer is List) {
      final selections = answer.cast<String>();
      return selections.isNotEmpty && 
             selections.length <= 3 && 
             selections.every((item) => _isValidOption(item));
    }
    return _isValidOption(answer.toString());
  }
  
  dynamic getDefaultAnswer() => [AnswerConstants.performanceMetrics]; // Most common tracking method
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is List) {
      _progressTrackingPreferences = json.map((e) => e.toString()).toList();
    } else if (json is String) {
      _progressTrackingPreferences = json.split(',');
    } else {
      _progressTrackingPreferences = null;
    }
  }
  
  //MARK: PRIVATE HELPERS
  
  /// Check if selection is a valid option
  bool _isValidOption(String option) {
    final validOptions = [AnswerConstants.photosMeasurements, AnswerConstants.performanceMetrics, AnswerConstants.dailyFeeling, AnswerConstants.habitStreaks, AnswerConstants.milestones];
    return validOptions.contains(option);
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get progress tracking preferences as `List<String>` from answers
  List<String> getProgressTrackingPreferences(Map<String, dynamic> answers) {
    final tracking = answers[questionId];
    if (tracking == null) return [AnswerConstants.performanceMetrics];
    if (tracking is List) return tracking.cast<String>();
    return [tracking.toString()];
  }

  //MARK: ANSWER STORAGE
  
  List<String>? _progressTrackingPreferences;
  
  @override
  String? get answer => 
    (_progressTrackingPreferences == null || _progressTrackingPreferences!.isEmpty) ? null : _progressTrackingPreferences!.join(',');
  
  /// Set the progress tracking preferences with a typed `List<String>`
  void setProgressTrackingPreferences(List<String>? value) => _progressTrackingPreferences = value;
  
  /// Get the progress tracking preferences as a typed `List<String>`
  List<String> get progressTrackingPreferences => _progressTrackingPreferences ?? [];

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return MultipleChoiceView(
      questionId: id,
      answers: {id: _progressTrackingPreferences ?? []},
      onAnswerChanged: (questionId, value) {
        if (value is List<String>) {
          setProgressTrackingPreferences(value.isEmpty ? null : value);
        } else if (value is List) {
          var stringList = value.map((e) => e.toString()).toList();
          setProgressTrackingPreferences(stringList.isEmpty ? null : stringList);
        }
        onAnswerChanged();
      },
      options: options,
      config: config,
    );
  }
}