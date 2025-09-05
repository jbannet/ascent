import 'package:flutter/material.dart';

/// Date picker widget for questions requiring date selection.
class DatePickerView extends StatelessWidget {
  final String questionId;
  final DateTime? currentAnswer;
  final Function(String, DateTime) onAnswerChanged;
  final Map<String, dynamic>? config;

  const DatePickerView({
    super.key,
    required this.questionId,
    this.currentAnswer,
    required this.onAnswerChanged,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = this.config ?? <String, dynamic>{};
    
    // Parse date strings from config
    DateTime? minDate;
    DateTime? maxDate;
    
    if (config['minDate'] != null) {
      minDate = DateTime.tryParse(config['minDate'] as String);
    }
    if (config['maxDate'] != null) {
      maxDate = DateTime.tryParse(config['maxDate'] as String);
    }
    
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: currentAnswer ?? DateTime.now(),
          firstDate: minDate ?? DateTime(1900),
          lastDate: maxDate ?? DateTime(2100),
        );
        
        if (selectedDate != null) {
          onAnswerChanged(questionId, selectedDate);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
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
                currentAnswer != null
                    ? _formatDate(currentAnswer!)
                    : 'Select a date',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: currentAnswer != null
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}