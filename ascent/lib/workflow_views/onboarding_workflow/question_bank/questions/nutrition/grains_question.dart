import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../views/question_views/nutrition_views/nutrition_table_bars.dart';
import '../../../views/question_views/nutrition_views/nutrition_state_manager.dart';
import '../onboarding_question.dart';

/// Grains servings question for nutrition assessment.
/// 
/// Asks about daily consumption of grains and starches in a positive,
/// educational way. This is the third question in the nutrition onboarding
/// flow and adds the third bar to the persistent chart visualization.
/// Note: For grains, higher values can be healthy (unlike treats/sodas).
class GrainsQuestion extends OnboardingQuestion {
  static const String questionId = 'grains';
  static final GrainsQuestion instance = GrainsQuestion._();
  GrainsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => GrainsQuestion.questionId;
  
  @override
  String get questionText => 'How many servings of grains do you eat per day?';
  
  @override
  String get section => 'nutrition_profile';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.custom;
  
  @override
  String? get subtitle => 'Examples: 1 slice bread, 1/2 cup rice or pasta, 1 cup cereal, 1 small bagel';
  
  String? get reason => 'Grains are an important energy source for your workouts. Understanding your intake helps us optimize your training fuel and recovery nutrition.';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0,
    'maxValue': 15,
    'step': 1,
    'showValue': true,
    'unit': 'servings',
  };
  
  //MARK: VALIDATION
  
  /// Validation is handled by the UI
  
  //MARK: ANSWER STORAGE
  
  double? _grainsCount;
  
  @override
  String? get answer => _grainsCount?.toString();
  
  /// Set the grains count with a typed double
  void setGrainsCount(double? value) => _grainsCount = value;
  
  /// Get the grains count as a typed double
  double? get grainsCount => _grainsCount;
  
  /// Get the grains count as answerDouble
  double? get answerDouble => _grainsCount;
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is double) {
      _grainsCount = json;
    } else if (json is num) {
      _grainsCount = json.toDouble();
    } else if (json is String) {
      _grainsCount = double.tryParse(json);
    } else {
      _grainsCount = null;
    }
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get grains count as integer from answers
  int? getGrainsCount(Map<String, dynamic> answers) {
    return _grainsCount?.toInt();
  }
  

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return NutritionTableBars(
      allValues: NutritionStateManager.instance.getAllNutritionValues(),
      currentType: 'grains',
      onValueChanged: (type, newValue) {
        if (type == 'grains') {
          setGrainsCount(newValue.toDouble());
          NutritionStateManager.instance.updateNutritionValue('grains', newValue);
          onAnswerChanged();
        }
      },
    );
  }
}