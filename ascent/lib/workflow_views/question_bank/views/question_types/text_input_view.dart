import 'package:flutter/material.dart';
import '../question_input_view.dart';

/// Text input widget for questions requiring text answers.
class TextInputView extends QuestionInputView {
  const TextInputView({
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
    final currentAnswerText = getCurrentAnswerAs<String>() ?? '';
    
    return TextFormField(
      initialValue: currentAnswerText,
      onChanged: (value) => onAnswerChanged(questionId, value),
      decoration: InputDecoration(
        hintText: config['placeholder'] as String?,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      maxLength: config['maxLength'] as int?,
      minLines: config['minLines'] as int? ?? 1,
      maxLines: config['maxLines'] as int? ?? 1,
    );
  }
}