import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/question_types/slider_view.dart';
import '../../views/nutrition/diet_quality_chart.dart';
import '../onboarding_question.dart';
import 'sugary_treats_question.dart';

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
  EnumQuestionType get questionType => EnumQuestionType.slider;
  
  @override
  String? get subtitle => 'Including sodas, energy drinks, sweetened teas, and fruit juices with added sugar.';
  
  String? get reason => 'Tracking sugary beverages helps us understand your hydration patterns and sugar intake, which affects energy levels and workout performance.';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
    'minValue': 0,
    'maxValue': 10,
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
    final value = answers[questionId];
    return value?.toInt();
  }
  
  /// Get nutrition data for chart visualization including previous answers
  Map<String, int?> getNutritionData(Map<String, dynamic> answers) {
    return {
      'sugary_treats': SugaryTreatsQuestion.instance.getSugaryTreatsCount(answers),
      'sodas': getSodasCount(answers),
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
        // Diet quality chart - shows first two bars as user adjusts slider
        DietQualityChart(
          nutritionData: getNutritionData({id: answer}),
          activeMetrics: const ['sugary_treats', 'sodas'],
          currentQuestionId: id,
          encouragementMessage: 'Your profile is taking shape! Let\'s add your drink preferences. 🥤',
        ),
        
        const SizedBox(height: 24),
        
        // Slider input
        SliderView(
          questionId: id,
          answers: {id: _sodasCount},
          onAnswerChanged: (questionId, value) {
            setSodasCount(value);
            onAnswerChanged();
          },
          config: config,
        ),
        
        const SizedBox(height: 16),
        
        // Helpful context
        _buildDrinkExamples(),
      ],
    );
  }
  
  Widget _buildDrinkExamples() {
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
                    'Examples of sweet drinks:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '🥤 Regular sodas (Coke, Pepsi, Sprite)\n'
                '⚡ Energy drinks (Red Bull, Monster)\n'
                '🧃 Sweetened juices, iced teas\n'
                '🥛 Flavored milks, smoothies with added sugar',
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
                      Icons.info_outline,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Diet sodas and water don\'t count here',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontSize: 11,
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