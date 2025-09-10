import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/dual_picker_view.dart';
import '../onboarding_question.dart';

/// Q4: How far can you run/walk in 12 minutes? (Cooper Test)
/// 
/// This question assesses cardiovascular fitness using the standardized Cooper 12-minute test.
/// It contributes to cardio fitness, VO2 max estimation, and training intensity features.
class Q4TwelveMinuteRunQuestion extends OnboardingQuestion {
  static const String questionId = 'Q4';
  static final Q4TwelveMinuteRunQuestion instance = Q4TwelveMinuteRunQuestion._();
  Q4TwelveMinuteRunQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q4TwelveMinuteRunQuestion.questionId;
  
  @override
  String get questionText => 'Approximately how far can you run/walk in 12 minutes?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.dualPicker;
  
  @override
  String? get subtitle => 'Select distance in miles (it\'s alright to select 0 if you have trouble walking distances)';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'leftColumn': {
      'label': 'miles',
      'values': [0, 1, 2],
    },
    'rightColumn': {
      'label': 'tenths', 
      'values': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],
    },
    'maxValue': 2.9,
    'showTotal': true,
    'unit': 'miles',
  };
  
  
  //MARK: VALIDATION
  
  /// Validation is handled by the dual picker UI
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is num) {
      _runDistance = json;
    } else if (json is String) {
      _runDistance = num.tryParse(json);
    } else {
      _runDistance = null;
    }
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get twelve minute run distance as double from answers (in miles)
  double? getTwelveMinuteRunDistance(Map<String, dynamic> answers) {
    final distance = answers[questionId];
    if (distance == null) return null;
    return distance is double ? distance : double.tryParse(distance.toString());
  }

  //MARK: TYPED ANSWER INTERFACE
  
  //MARK: ANSWER STORAGE
  
  num? _runDistance;
  
  @override
  String? get answer => _runDistance?.toString();
  
  /// Set the twelve minute run distance with a typed num (no validation needed)
  void setRunDistance(num? value) => _runDistance = value;
  
  /// Get the twelve minute run distance as a typed double
  double? get answerDouble => _runDistance?.toDouble();
  
  /// Get the twelve minute run distance as a typed num
  num? get runDistance => _runDistance;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return Column(
      children: [
        DualPickerView(
          questionId: id,
          answers: {id: _runDistance},
          onAnswerChanged: (questionId, value) {
            setRunDistance(value);
            onAnswerChanged();
          },
          config: config,
        ),
        const SizedBox(height: 40),
        Image.asset(
          'assets/images/kettle_running.png',
          height: 180,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}