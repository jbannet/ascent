import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';

/// Multiple choice widget for questions allowing multiple selections.
class MultipleChoiceView extends StatelessWidget {
  final String questionId;
  final List<String>? currentAnswer;
  final Function(String, List<String>) onAnswerChanged;
  final List<QuestionOption> options;
  final Map<String, dynamic>? config;

  const MultipleChoiceView({
    super.key,
    required this.questionId,
    this.currentAnswer,
    required this.onAnswerChanged,
    required this.options,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedValues = currentAnswer ?? <String>[];
    final maxSelections = config?['maxSelections'] as int?;
    
    return Column(
      children: options.map((option) {
        final isSelected = selectedValues.contains(option.value);
        final canSelect = maxSelections == null || 
                         selectedValues.length < maxSelections || 
                         isSelected;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: canSelect ? () {
              final newSelection = List<String>.from(selectedValues);
              if (isSelected) {
                newSelection.remove(option.value);
              } else {
                newSelection.add(option.value);
              }
              onAnswerChanged(questionId, newSelection);
            } : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : canSelect 
                          ? theme.colorScheme.outline.withValues(alpha: 0.3)
                          : theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: canSelect ? (value) {
                      final newSelection = List<String>.from(selectedValues);
                      if (value == true) {
                        newSelection.add(option.value);
                      } else {
                        newSelection.remove(option.value);
                      }
                      onAnswerChanged(questionId, newSelection);
                    } : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: canSelect 
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        if (option.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            option.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: canSelect
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}