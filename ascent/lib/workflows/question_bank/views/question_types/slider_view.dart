import 'package:flutter/material.dart';

/// Slider widget for questions requiring selection from a range of values.
class SliderView extends StatelessWidget {
  final String questionId;
  final double? currentAnswer;
  final Function(String, double) onAnswerChanged;
  final Map<String, dynamic>? config;

  const SliderView({
    super.key,
    required this.questionId,
    this.currentAnswer,
    required this.onAnswerChanged,
    this.config,
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
    
    final currentValue = currentAnswer ?? minValue;
    
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
                '${currentValue.toStringAsFixed(step < 1 ? 1 : 0)}${unit ?? ''}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.outline.withValues(alpha: 0.3),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            valueIndicatorColor: theme.colorScheme.primary,
            valueIndicatorTextStyle: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
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
                '${minValue.toStringAsFixed(step < 1 ? 1 : 0)}${unit ?? ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '${maxValue.toStringAsFixed(step < 1 ? 1 : 0)}${unit ?? ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}