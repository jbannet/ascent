import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';
import '../question_input_view.dart';

/// Multiple choice widget for questions allowing multiple selections.
class MultipleChoiceView extends QuestionInputView {
  const MultipleChoiceView({
    super.key,
    required super.questionId,
    required super.answers,
    required super.onAnswerChanged,
    super.options,
    super.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedValues = getCurrentAnswerAsList() ?? <String>[];
    final optionsList = options ?? <QuestionOption>[];
    final maxSelections = config?['maxSelections'] as int?;
    
    return Column(
      children: optionsList.map((option) {
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
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
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
                        if (!newSelection.contains(option.value)) {
                          newSelection.add(option.value);
                        }
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
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected 
                                ? theme.colorScheme.primary
                                : canSelect 
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        if (option.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            option.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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