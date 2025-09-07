import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Number input widget for questions requiring numeric answers.
class NumberInputView extends StatefulWidget {
  final String questionId;
  final num? currentAnswer;
  final Function(String, num) onAnswerChanged;
  final Map<String, dynamic>? config;

  const NumberInputView({
    super.key,
    required this.questionId,
    this.currentAnswer,
    required this.onAnswerChanged,
    this.config,
  });

  @override
  State<NumberInputView> createState() => _NumberInputViewState();
}

class _NumberInputViewState extends State<NumberInputView> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentAnswer?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config ?? <String, dynamic>{};
    final allowDecimals = config['allowDecimals'] as bool? ?? true;
    final unit = config['unit'] as String?;
    
    return TextFormField(
      controller: _controller,
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
            widget.onAnswerChanged(widget.questionId, number);
          }
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