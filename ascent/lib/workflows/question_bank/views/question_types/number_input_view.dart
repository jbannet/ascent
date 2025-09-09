import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../question_input_view.dart';

/// Number input widget for questions requiring numeric answers.
class NumberInputView extends QuestionInputView {
  const NumberInputView({
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
    final currentAnswerNum = getCurrentAnswerAs<num>()?.toString() ?? '';
    
    final allowDecimals = config['allowDecimals'] as bool? ?? true;
    final unit = config['unit'] as String?;
    
    return TextFormField(
      initialValue: currentAnswerNum,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimals),
      inputFormatters: allowDecimals
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        if (value.isNotEmpty) {
          final number = allowDecimals 
              ? double.tryParse(value)
              : int.tryParse(value);
          if (number != null) {
            onAnswerChanged(questionId, number);
          }
        } else {
          onAnswerChanged(questionId, null);
        }
      },
      decoration: InputDecoration(
        hintText: config['placeholder'] as String?,
        suffixText: unit,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
    );
  }
}