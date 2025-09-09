import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/nutrition/nutrition_table_bars.dart';
import '../../views/nutrition/nutrition_state_manager.dart';
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
  
  Widget _buildGrainExamples() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Examples of grain servings:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '🍞 1 slice bread, 1 small roll\n'
                '🍚 1/2 cup cooked rice or pasta\n'
                '🥣 1 cup ready-to-eat cereal\n'
                '🥨 1 small bagel, 1 large crackers',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 14,
                      color: Color(0xFF29AD8F), // continueGreen
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Whole grains provide sustained energy for workouts',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Color(0xFF29AD8F),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}