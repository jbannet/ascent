import 'package:flutter/material.dart';

/// Temporary placeholder for WheelPickerView
/// TODO: Implement spinning wheel picker UI
class WheelPickerView extends StatelessWidget {
  final String questionId;
  final Map<String, dynamic> answers;
  final Function(String, dynamic) onAnswerChanged;
  final Map<String, dynamic>? config;

  const WheelPickerView({
    super.key,
    required this.questionId,
    required this.answers,
    required this.onAnswerChanged,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = answers[questionId] as num?;
    final minValue = config?['minValue'] as int? ?? 0;
    final maxValue = config?['maxValue'] as int? ?? 100;
    final unit = config?['unit'] as String? ?? '';

    return Column(
      children: [
        Text(
          'TODO: Implement Wheel Picker',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text('Current value: ${currentValue ?? minValue} $unit'),
        const SizedBox(height: 16),
        // Temporary slider as placeholder
        Slider(
          value: (currentValue ?? minValue).toDouble(),
          min: minValue.toDouble(),
          max: maxValue.toDouble(),
          divisions: maxValue - minValue,
          label: '${(currentValue ?? minValue)} $unit',
          onChanged: (value) {
            onAnswerChanged(questionId, value.toInt());
          },
        ),
      ],
    );
  }
}