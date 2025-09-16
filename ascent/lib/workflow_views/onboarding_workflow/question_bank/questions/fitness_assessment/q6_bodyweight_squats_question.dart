import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../views/question_views/question_types/slider_view.dart';
import '../onboarding_question.dart';

/// Q6: How many bodyweight squats can you do continuously (with good form)?
/// 
/// This question assesses lower body strength and muscular endurance.
/// It's a critical functional movement that predicts:
/// - Ability to rise from chairs/floor
/// - Fall prevention capability
/// - Lower body power
/// - Daily activity independence
/// 
/// Good form criteria:
/// - Thighs parallel to ground at bottom
/// - Heels stay on floor
/// - Knees track over toes
/// - Back stays straight
/// - Full hip and knee extension at top
class Q6BodyweightSquatsQuestion extends OnboardingQuestion {
  static const String questionId = 'Q6';
  static final Q6BodyweightSquatsQuestion instance = Q6BodyweightSquatsQuestion._();
  Q6BodyweightSquatsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q6BodyweightSquatsQuestion.questionId;
  
  @override
  String get questionText => 'How many bodyweight squats can you do continuously (with good form)?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.slider;
  
  @override
  String? get subtitle => 'Go down until thighs are parallel to ground, then back up';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0,
    'maxValue': 100,
    'step': 1,
    'showValue': true,
    'unit': 'reps',
  };
  
  
  //MARK: VALIDATION
  
  /// Validation is handled by the slider UI
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is num) {
      _squatsCount = json;
    } else if (json is String) {
      _squatsCount = num.tryParse(json);
    } else {
      _squatsCount = null;
    }
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get squats count as int from answers
  int? getSquatsCount(Map<String, dynamic> answers) {
    final count = answers[questionId];
    if (count == null) return null;
    return count is int ? count : int.tryParse(count.toString());
  }

  //MARK: TYPED ANSWER INTERFACE
  
  //MARK: ANSWER STORAGE
  
  num? _squatsCount;
  
  @override
  String? get answer => _squatsCount?.toString();
  
  /// Set the squats count with a typed num (no validation needed)
  void setSquatsCount(num? value) => _squatsCount = value;
  
  /// Get the squats count as a typed num
  num? get squatsCount => _squatsCount;
  
  /// Get the squats count as answerDouble
  double? get answerDouble => _squatsCount?.toDouble();

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return SliderView(
      questionId: id,
      answers: {id: _squatsCount},
      onAnswerChanged: (questionId, value) {
        setSquatsCount(value);
        onAnswerChanged();
      },
      config: config,
    );
  }
}