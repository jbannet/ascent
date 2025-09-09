import 'package:flutter/material.dart';

/// Temporary placeholder for DualPickerView
/// TODO: Implement dual column picker UI for miles and tenths
class DualPickerView extends StatelessWidget {
  final String questionId;
  final Map<String, dynamic> answers;
  final Function(String, dynamic) onAnswerChanged;
  final Map<String, dynamic>? config;

  const DualPickerView({
    super.key,
    required this.questionId,
    required this.answers,
    required this.onAnswerChanged,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = answers[questionId] as num?;
    final maxValue = config?['maxValue'] as double? ?? 2.9;
    final unit = config?['unit'] as String? ?? '';

    return Column(
      children: [
        Text(
          'TODO: Implement Dual Picker',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text('Current value: ${currentValue ?? 0.0} $unit'),
        const SizedBox(height: 16),
        // Temporary slider as placeholder
        Slider(
          value: (currentValue ?? 0.0).toDouble(),
          min: 0.0,
          max: maxValue,
          divisions: (maxValue * 10).toInt(),
          label: '${(currentValue ?? 0.0).toStringAsFixed(1)} $unit',
          onChanged: (value) {
            onAnswerChanged(questionId, double.parse(value.toStringAsFixed(1)));
          },
        ),
      ],
    );
  }
}