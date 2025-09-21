import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../views/question_views/nutrition_views/nutrition_table_bars.dart';
import '../../../views/question_views/nutrition_views/nutrition_state_manager.dart';
import '../onboarding_question.dart';

/// Sodas consumption question for nutrition assessment.
/// 
/// Asks about daily consumption of sodas and sugary drinks in a positive,
/// non-judgmental way. This is the second question in the nutrition onboarding
/// flow and adds the second bar to the persistent chart visualization.
class SodasQuestion extends OnboardingQuestion {
  static const String questionId = 'sodas';
  static final SodasQuestion instance = SodasQuestion._();
  SodasQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => SodasQuestion.questionId;
  
  @override
  String get questionText => 'How many sodas or sweet drinks do you have per day?';
  
  @override
  String get section => 'nutrition_profile';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.custom;
  
  @override
  String? get subtitle => 'Examples: regular sodas (Coke, Pepsi), energy drinks, sweetened juices, flavored milks';
  
  String? get reason => 'Tracking sugary beverages helps us understand your hydration patterns and sugar intake, which affects energy levels and workout performance.';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0,
    'maxValue': 15,
    'step': 1,
    'showValue': true,
    'unit': 'drinks',
  };
  
  //MARK: VALIDATION
  
  /// Validation is handled by the UI
  
  //MARK: ANSWER STORAGE
  
  double? _sodasCount;
  
  @override
  String? get answer => _sodasCount?.toString();
  
  /// Set the sodas count with a typed double
  void setSodasCount(double? value) => _sodasCount = value;
  
  /// Get the sodas count as a typed double
  double? get sodasCount => _sodasCount;
  
  /// Get the sodas count as answerDouble
  double? get answerDouble => _sodasCount;
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is double) {
      _sodasCount = json;
    } else if (json is num) {
      _sodasCount = json.toDouble();
    } else if (json is String) {
      _sodasCount = double.tryParse(json);
    } else {
      _sodasCount = null;
    }
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get sodas count as integer from answers
  int? getSodasCount(Map<String, dynamic> answers) {
    return _sodasCount?.toInt();
  }
  

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return NutritionTableBars(
      allValues: NutritionStateManager.instance.getAllNutritionValues(),
      currentType: 'sodas',
      onValueChanged: (type, newValue) {
        if (type == 'sodas') {
          setSodasCount(newValue.toDouble());
          NutritionStateManager.instance.updateNutritionValue('sodas', newValue);
          onAnswerChanged();
        }
      },
    );
  }
}