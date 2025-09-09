import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/enum_question_type.dart';
import '../../views/nutrition/nutrition_table_bars.dart';
import '../../views/nutrition/nutrition_state_manager.dart';
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
  
  Widget _buildAlcoholInput(
    Function() onAnswerChanged,
  ) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isPrivate = _isPrivate;
        final numericValue = _alcoholCount?.toInt() ?? 2;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha:  0.1),
            ),
          ),
          child: Column(
            children: [
              // Privacy option button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (isPrivate) {
                      _isPrivate = false;
                      _alcoholCount = numericValue.toDouble();
                    } else {
                      _isPrivate = true;
                      _alcoholCount = null;
                    }
                    onAnswerChanged();
                  },
                  icon: Icon(
                    isPrivate ? Icons.visibility_off : Icons.privacy_tip_outlined,
                    size: 18,
                    color: isPrivate ? theme.colorScheme.primary : theme.colorScheme.outline,
                  ),
                  label: Text(
                    isPrivate ? 'Private answer selected' : 'Prefer not to say',
                    style: TextStyle(
                      color: isPrivate ? theme.colorScheme.primary : theme.colorScheme.outline,
                      fontWeight: isPrivate ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isPrivate 
                      ? theme.colorScheme.primary.withValues(alpha:  0.1)
                      : null,
                    side: BorderSide(
                      color: isPrivate 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha:  0.3),
                    ),
                  ),
                ),
              ),
              
              if (!isPrivate) ...[
                const SizedBox(height: 20),
                
                // Current value display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha:  0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$numericValue drinks/week',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor: theme.colorScheme.primary.withValues(alpha:  0.2),
                    thumbColor: theme.colorScheme.primary,
                    overlayColor: theme.colorScheme.primary.withValues(alpha:  0.2),
                  ),
                  child: Slider(
                    value: (_alcoholCount ?? 0.0).clamp(0.0, 20.0),
                    min: 0.0,
                    max: 20.0,
                    divisions: 20,
                    onChanged: (value) {
                      setAlcoholCount(value);
                      onAnswerChanged();
                    },
                  ),
                ),
                
                // Min/max labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '20+',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildAlcoholExamples() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha:  0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha:  0.1),
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
                    'One drink equals:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '🍺 12 oz beer (5% alcohol)\n'
                '🍷 5 oz wine (12% alcohol)\n'
                '🥃 1.5 oz spirits (40% alcohol)\n'
                '🍹 1 cocktail or mixed drink',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:  0.8),
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
                      Icons.security_outlined,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Your answer is completely private and secure',
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