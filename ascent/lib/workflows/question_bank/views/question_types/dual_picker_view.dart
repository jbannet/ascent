import 'package:flutter/material.dart';
import '../question_input_view.dart';

/// Dual column picker widget for selecting values with two independent columns.
/// Commonly used for distance (miles + tenths) or time (minutes + seconds).
class DualPickerView extends QuestionInputView {
  const DualPickerView({
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
    final currentValue = getCurrentAnswerAs<num>() ?? 0.0;
    
    final leftColumn = config['leftColumn'] as Map<String, dynamic>? ?? {};
    final rightColumn = config['rightColumn'] as Map<String, dynamic>? ?? {};
    final unit = config['unit'] as String? ?? '';
    final showTotal = config['showTotal'] as bool? ?? true;
    
    final leftValues = (leftColumn['values'] as List?)?.cast<num>() ?? [0];
    final rightValues = (rightColumn['values'] as List?)?.cast<num>() ?? [0];
    final leftLabel = leftColumn['label'] as String? ?? 'Left';
    final rightLabel = rightColumn['label'] as String? ?? 'Right';
    
    // Extract current left and right values from the total
    final currentLeftValue = currentValue.floor();
    final currentRightValue = double.parse((currentValue - currentLeftValue).toStringAsFixed(1));
    
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
          if (showTotal)
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
                '${currentValue.toStringAsFixed(1)} $unit',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left column picker
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        leftLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                            initialItem: leftValues.indexOf(currentLeftValue),
                          ),
                          itemExtent: 40,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            final newLeftValue = leftValues[index];
                            final newTotal = newLeftValue + currentRightValue;
                            onAnswerChanged(questionId, newTotal);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index >= leftValues.length) return null;
                              final value = leftValues[index];
                              final isSelected = value == currentLeftValue;
                              
                              return Container(
                                alignment: Alignment.center,
                                child: Text(
                                  value.toString(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isSelected 
                                        ? theme.colorScheme.primary 
                                        : theme.colorScheme.onSurface,
                                    fontWeight: isSelected 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                            childCount: leftValues.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Right column picker
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        rightLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                            initialItem: _findClosestIndex(rightValues, currentRightValue),
                          ),
                          itemExtent: 40,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            final newRightValue = rightValues[index];
                            final newTotal = currentLeftValue + newRightValue;
                            onAnswerChanged(questionId, newTotal);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index >= rightValues.length) return null;
                              final value = rightValues[index];
                              final isSelected = _isValueSelected(value, currentRightValue);
                              
                              return Container(
                                alignment: Alignment.center,
                                child: Text(
                                  value.toStringAsFixed(1),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isSelected 
                                        ? theme.colorScheme.primary 
                                        : theme.colorScheme.onSurface,
                                    fontWeight: isSelected 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                            childCount: rightValues.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Finds the index of the value closest to the target in a list of numbers.
  int _findClosestIndex(List<num> values, num target) {
    if (values.isEmpty) return 0;
    
    int closestIndex = 0;
    num closestDifference = (values[0] - target).abs();
    
    for (int i = 1; i < values.length; i++) {
      final difference = (values[i] - target).abs();
      if (difference < closestDifference) {
        closestIndex = i;
        closestDifference = difference;
      }
    }
    
    return closestIndex;
  }
  
  /// Checks if the given value matches the current selection (with decimal precision tolerance).
  bool _isValueSelected(num value, num currentValue) {
    return (value - currentValue).abs() < 0.001;
  }
}