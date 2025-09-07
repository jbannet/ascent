import 'package:flutter/material.dart';
import '../../../onboarding_workflow/models/questions/question_option.dart';

/// Single choice widget for questions requiring one selection from multiple options.
class SingleChoiceView extends StatelessWidget {
  final String questionId;
  final String? currentAnswer;
  final Function(String, String) onAnswerChanged;
  final List<QuestionOption> options;

  const SingleChoiceView({
    super.key,
    required this.questionId,
    this.currentAnswer,
    required this.onAnswerChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: options.map((option) {
        final isSelected = currentAnswer == option.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onAnswerChanged(questionId, option.value),
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
                  Radio<String>(
                    value: option.value,
                    groupValue: currentAnswer,
                    onChanged: (value) {
                      if (value != null) {
                        onAnswerChanged(questionId, value);
                      }
                    },
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
                          ),
                        ),
                        if (option.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            option.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
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