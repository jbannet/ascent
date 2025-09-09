import 'package:flutter/material.dart';
import '../question_input_view.dart';

/// Date picker widget for questions requiring date selection.
class DatePickerView extends QuestionInputView {
  const DatePickerView({
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
    final currentDate = getCurrentAnswerAs<DateTime>();
    
    DateTime? minDate;
    DateTime? maxDate;
    
    if (config['minDate'] != null) {
      minDate = DateTime.tryParse(config['minDate'] as String);
    }
    if (config['maxDate'] != null) {
      maxDate = DateTime.tryParse(config['maxDate'] as String);
    }
    
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: currentDate ?? _getValidInitialDate(minDate, maxDate),
              firstDate: minDate ?? DateTime(1900),
              lastDate: maxDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: theme.colorScheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            
            if (selectedDate != null) {
              onAnswerChanged(questionId, selectedDate);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.surface,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentDate != null
                        ? '${currentDate.day}/${currentDate.month}/${currentDate.year}'
                        : 'Select date',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: currentDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Returns a valid initial date that falls within the min/max date constraints.
  /// When no current date is selected, ensures the date picker opens with a valid date.
  DateTime _getValidInitialDate(DateTime? minDate, DateTime? maxDate) {
    final now = DateTime.now();
    final min = minDate ?? DateTime(1900);
    final max = maxDate ?? DateTime(2100);
    
    // If now is within range, use it
    if (!now.isBefore(min) && !now.isAfter(max)) {
      return now;
    }
    
    // If now is after max, use max
    if (now.isAfter(max)) {
      return max;
    }
    
    // If now is before min, use min
    return min;
  }
}