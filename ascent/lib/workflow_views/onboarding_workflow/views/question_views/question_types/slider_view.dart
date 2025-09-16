import 'package:flutter/material.dart';
import '../question_input_view.dart';

/// Slider widget for questions requiring selection from a range of values.
class SliderView extends QuestionInputView {
  const SliderView({
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
    
    final minValue = (config['minValue'] as num?)?.toDouble() ?? 0.0;
    final maxValue = (config['maxValue'] as num?)?.toDouble() ?? 100.0;
    final step = (config['step'] as num?)?.toDouble() ?? 1.0;
    final showValue = config['showValue'] as bool? ?? true;
    final unit = config['unit'] as String?;
    
    final currentValue = getCurrentAnswerAs<double>() ?? minValue;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showValue)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatValueWithUnit(currentValue, step, unit),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: currentValue.clamp(minValue, maxValue),
            min: minValue,
            max: maxValue,
            divisions: ((maxValue - minValue) / step).round(),
            onChanged: (value) {
              final steppedValue = (value / step).round() * step;
              onAnswerChanged(questionId, steppedValue);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatValueWithUnit(minValue, step, unit),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                _formatValueWithUnit(maxValue, step, unit),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Format value with unit, removing .0 for whole numbers and adding space before unit
  String _formatValueWithUnit(double value, double step, String? unit) {
    final isWholeNumber = value == value.roundToDouble();
    final formattedValue = isWholeNumber 
        ? value.round().toString() 
        : value.toStringAsFixed(step < 1 ? 1 : 0);
    
    return unit != null ? '$formattedValue $unit' : formattedValue;
  }
}