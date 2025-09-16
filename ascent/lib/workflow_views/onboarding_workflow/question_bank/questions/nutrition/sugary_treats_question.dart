import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../views/question_views/nutrition/nutrition_table_bars.dart';
import '../../../views/question_views/nutrition/nutrition_state_manager.dart';
import '../onboarding_question.dart';

/// Sugary treats consumption question for nutrition assessment.
/// 
/// Asks about daily consumption of sweet treats (cookies, candy, pastries, etc.)
/// in a positive, non-judgmental way. This is the first question in the nutrition
/// onboarding flow and introduces the persistent chart visualization.
class SugaryTreatsQuestion extends OnboardingQuestion {
  static const String questionId = 'sugary_treats';
  static final SugaryTreatsQuestion instance = SugaryTreatsQuestion._();
  SugaryTreatsQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => SugaryTreatsQuestion.questionId;
  
  @override
  String get questionText => 'How many sweet treats do you enjoy per day?';
  
  @override
  String get section => 'nutrition_profile';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.custom;
  
  @override
  String? get subtitle => 'Examples: cookies, cake, pastries, candy, chocolate, cupcakes, donuts, ice cream';
  
  String? get reason => 'Understanding your sweet treat habits helps us personalize your nutrition guidance and create realistic, sustainable recommendations.';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0,
    'maxValue': 15,
    'step': 1,
    'showValue': true,
    'unit': 'treats',
  };
  
  //MARK: VALIDATION
  
  /// Validation is handled by the UI
  
  //MARK: ANSWER STORAGE
  
  double? _sugaryTreatsCount;
  
  @override
  String? get answer => _sugaryTreatsCount?.toString();
  
  /// Set the sugary treats count with a typed double
  void setSugaryTreatsCount(double? value) => _sugaryTreatsCount = value;
  
  /// Get the sugary treats count as a typed double
  double? get sugaryTreatsCount => _sugaryTreatsCount;
  
  /// Get the sugary treats count as answerDouble
  double? get answerDouble => _sugaryTreatsCount;
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is double) {
      _sugaryTreatsCount = json;
    } else if (json is num) {
      _sugaryTreatsCount = json.toDouble();
    } else if (json is String) {
      _sugaryTreatsCount = double.tryParse(json);
    } else {
      _sugaryTreatsCount = null;
    }
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get sugary treats count as integer from answers
  int? getSugaryTreatsCount(Map<String, dynamic> answers) {
    return _sugaryTreatsCount?.toInt();
  }
  

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return NutritionTableBars(
      allValues: NutritionStateManager.instance.getAllNutritionValues(),
      currentType: 'treats',
      onValueChanged: (type, newValue) {
        if (type == 'treats') {
          setSugaryTreatsCount(newValue.toDouble());
          NutritionStateManager.instance.updateNutritionValue('treats', newValue);
          onAnswerChanged();
        }
      },
    );
  }
}