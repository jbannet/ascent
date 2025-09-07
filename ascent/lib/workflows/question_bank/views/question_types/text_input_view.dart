import 'package:flutter/material.dart';

/// Text input widget for questions requiring text answers.
class TextInputView extends StatefulWidget {
  final String questionId;
  final String? currentAnswer;
  final Function(String, String) onAnswerChanged;
  final Map<String, dynamic>? config;

  const TextInputView({
    super.key,
    required this.questionId,
    this.currentAnswer,
    required this.onAnswerChanged,
    this.config,
  });

  @override
  State<TextInputView> createState() => _TextInputViewState();
}

class _TextInputViewState extends State<TextInputView> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentAnswer ?? '');
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
    
    return TextFormField(
      controller: _controller,
      onChanged: (value) => widget.onAnswerChanged(widget.questionId, value),
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