import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../../../views/question_views/nutrition_views/nutrition_table_bars.dart';
import '../../../views/question_views/nutrition_views/nutrition_state_manager.dart';
import '../onboarding_question.dart';

/// Alcohol consumption question for nutrition assessment with privacy handling.
/// 
/// Asks about weekly alcohol consumption in a respectful, private way.
/// This is the final question in the nutrition onboarding flow and completes
/// the persistent chart visualization. Includes a "Prefer not to say" option
/// for privacy-conscious users.
class AlcoholQuestion extends OnboardingQuestion {
  static const String questionId = 'alcohol';
  static final AlcoholQuestion instance = AlcoholQuestion._();
  AlcoholQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => AlcoholQuestion.questionId;
  
  @override
  String get questionText => 'How many alcoholic drinks do you have per week?';
  
  @override
  String get section => 'nutrition_profile';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.custom; // Custom widget with privacy
  
  @override
  String? get subtitle => 'This helps us provide better hydration and recovery recommendations.';
  
  String? get reason => 'Alcohol affects hydration, sleep quality, and recovery. Understanding your intake helps us personalize your fitness plan and nutrition guidance.';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': false, // Allow skipping for privacy
    'minValue': 0,
    'maxValue': 20,
    'step': 1,
    'showValue': true,
    'unit': 'weekly',
    'allowPrivacy': true,
  };
  
  //MARK: VALIDATION
  
  /// Validation is handled by the UI
  
  //MARK: ANSWER STORAGE
  
  double? _alcoholCount;
  bool _isPrivate = false;
  
  @override
  String? get answer => _isPrivate ? 'prefer_not_to_say' : _alcoholCount?.toString();
  
  /// Set the alcohol count with a typed double
  void setAlcoholCount(double? value) {
    _alcoholCount = value;
    _isPrivate = false; // Clear private flag when setting a value
  }
  
  /// Get the alcohol count as a typed double
  double? get alcoholCount => _alcoholCount;
  
  @override
  void fromJsonValue(dynamic json) {
    if (json == 'prefer_not_to_say') {
      _isPrivate = true;
      _alcoholCount = null;
    } else if (json is double) {
      _alcoholCount = json;
      _isPrivate = false;
    } else if (json is num) {
      _alcoholCount = json.toDouble();
      _isPrivate = false;
    } else if (json is String) {
      _alcoholCount = double.tryParse(json);
      _isPrivate = false;
    } else {
      _alcoholCount = null;
      _isPrivate = false;
    }
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get alcohol count as integer from answers, returns null if private
  int? getAlcoholCount(Map<String, dynamic> answers) {
    if (_isPrivate) return null;
    return _alcoholCount?.toInt();
  }
  
  /// Check if user chose privacy option
  bool isPrivateAnswer(Map<String, dynamic> answers) {
    return answers[questionId] == 'prefer_not_to_say';
  }
  

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Column(
          children: [
            // Privacy status indicator (if private answer is selected)
            if (_isPrivate)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    _isPrivate = false;
                    _alcoholCount = 0.0;
                    NutritionStateManager.instance.updateNutritionValue('alcohol', 0);
                    onAnswerChanged();
                  },
                  icon: Icon(
                    Icons.visibility_off,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    'Private answer selected - tap to change',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            
            // Show chart only if not private
            if (!_isPrivate)
              NutritionTableBars(
                allValues: NutritionStateManager.instance.getAllNutritionValues(),
                currentType: 'alcohol',
                onValueChanged: (type, newValue) {
                  if (type == 'alcohol') {
                    setAlcoholCount(newValue.toDouble());
                    NutritionStateManager.instance.updateNutritionValue('alcohol', newValue);
                    onAnswerChanged();
                  }
                },
              ),
            
            // Add "Prefer not to say" option
            if (!_isPrivate) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  _isPrivate = true;
                  _alcoholCount = null;
                  NutritionStateManager.instance.updateNutritionValue('alcohol', 0);
                  onAnswerChanged();
                },
                icon: Icon(
                  Icons.privacy_tip_outlined,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
                label: Text(
                  'Prefer not to say',
                  style: TextStyle(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}