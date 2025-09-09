import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/slider_view.dart';
import '../../views/nutrition/diet_quality_chart.dart';
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
  EnumQuestionType get questionType => EnumQuestionType.slider;
  
  @override
  String? get subtitle => 'Think cookies, candy, pastries, or desserts - we\'re building your nutrition profile!';
  
  String? get reason => 'Understanding your sweet treat habits helps us personalize your nutrition guidance and create realistic, sustainable recommendations.';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0,
    'maxValue': 10,
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
  
  /// Get nutrition data for chart visualization
  Map<String, int?> getNutritionData(Map<String, dynamic> answers) {
    return {
      'sugary_treats': getSugaryTreatsCount(answers),
      'sodas': null,
      'grains': null,
      'alcohol': null,
    };
  }

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return Column(
      children: [
        // Diet quality chart - shows first bar as user adjusts slider
        DietQualityChart(
          nutritionData: getNutritionData({id: answer}),
          activeMetrics: const ['sugary_treats'],
          currentQuestionId: id,
          encouragementMessage: 'Great start! Let\'s see your sweet treat preferences. 🍪',
        ),
        
        const SizedBox(height: 24),
        
        // Slider input
        SliderView(
          questionId: id,
          answers: {id: _sugaryTreatsCount},
          onAnswerChanged: (questionId, value) {
            setSugaryTreatsCount(value);
            onAnswerChanged();
          },
          config: config,
        ),
        
        const SizedBox(height: 16),
        
        // Helpful context
        _buildTreatExamples(),
      ],
    );
  }
  
  Widget _buildTreatExamples() {
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
                    'Examples of sweet treats:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '🍪 Cookies, cake, pastries\n'
                '🍬 Candy, chocolate bars\n'
                '🧁 Cupcakes, donuts, muffins\n'
                '🍨 Ice cream, frozen yogurt',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}