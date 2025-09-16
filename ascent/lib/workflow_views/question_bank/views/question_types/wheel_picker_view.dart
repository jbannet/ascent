import 'package:flutter/material.dart';
import '../question_input_view.dart';

/// Spinning wheel picker widget for selecting numeric values.
/// Provides a scrollable wheel interface for selecting values within a range.
class WheelPickerView extends QuestionInputView {
  const WheelPickerView({
    super.key,
    required super.questionId,
    required super.answers,
    required super.onAnswerChanged,
    super.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = this.config ?? <String, dynamic>{};
    final currentValue = getCurrentAnswerAs<int>() ?? (config['minValue'] as int? ?? 0);
    
    final minValue = config['minValue'] as int? ?? 0;
    final maxValue = config['maxValue'] as int? ?? 100;
    final step = config['step'] as int? ?? 1;
    final unit = config['unit'] as String? ?? '';
    
    // Generate the list of values based on min, max, and step
    final values = <int>[];
    for (int i = minValue; i <= maxValue; i += step) {
      values.add(i);
    }
    
    final currentIndex = values.indexOf(currentValue);
    final validIndex = currentIndex >= 0 ? currentIndex : 0;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          // Header showing current value
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '$currentValue $unit',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Wheel picker
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Selection indicator
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  // Wheel scroll view
                  ListWheelScrollView.useDelegate(
                    controller: FixedExtentScrollController(
                      initialItem: validIndex,
                    ),
                    itemExtent: 50,
                    physics: const FixedExtentScrollPhysics(),
                    diameterRatio: 1.5,
                    perspective: 0.003,
                    onSelectedItemChanged: (index) {
                      if (index >= 0 && index < values.length) {
                        onAnswerChanged(questionId, values[index]);
                      }
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index >= values.length) return null;
                        final value = values[index];
                        final isSelected = value == currentValue;
                        
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            value.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isSelected 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.w500,
                              fontSize: isSelected ? 24 : 20,
                            ),
                          ),
                        );
                      },
                      childCount: values.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Unit label
          if (unit.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                unit,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}