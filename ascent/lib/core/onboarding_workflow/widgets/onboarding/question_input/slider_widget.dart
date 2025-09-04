import 'package:flutter/material.dart';

class SliderWidget extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final double minValue;
  final double maxValue;
  final double? currentValue;
  final Function(String questionId, double value) onAnswerChanged;
  final bool isRequired;
  final int? divisions;
  final String? unit;
  final bool showValue;
  final double? step;
  final String Function(double)? labelFormatter;

  const SliderWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    required this.minValue,
    required this.maxValue,
    this.currentValue,
    required this.onAnswerChanged,
    this.isRequired = true,
    this.divisions,
    this.unit,
    this.showValue = true,
    this.step,
    this.labelFormatter,
  });

  /// Creates SliderWidget from configuration map with validation
  SliderWidget.fromConfig(Map<String, dynamic> config, {super.key})
    : questionId = config['questionId'] ?? 
        (throw ArgumentError('SliderWidget: questionId is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      title = config['title'] ?? 
        (throw ArgumentError('SliderWidget: title is required. Question ID: ${config['questionId'] ?? 'missing'}')),
      subtitle = config['subtitle'] as String?,
      minValue = config['minValue'] ?? 
        (throw ArgumentError('SliderWidget: minValue is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      maxValue = config['maxValue'] ?? 
        (throw ArgumentError('SliderWidget: maxValue is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      currentValue = config['currentValue'] as double?,
      onAnswerChanged = config['onAnswerChanged'] ?? 
        (throw ArgumentError('SliderWidget: onAnswerChanged is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      isRequired = config['isRequired'] as bool? ?? true,
      divisions = config['divisions'] as int?,
      unit = config['unit'] as String?,
      showValue = config['showValue'] as bool? ?? true,
      step = config['step'] as double?,
      labelFormatter = config['labelFormatter'] as String Function(double)?;

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentValue;
  }

  @override
  void didUpdateWidget(SliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      _currentValue = widget.currentValue;
    }
  }

  void _onSliderChanged(double value) {
    double finalValue = value;
    
    // Apply step if provided
    if (widget.step != null) {
      finalValue = (value / widget.step!).round() * widget.step!;
      finalValue = finalValue.clamp(widget.minValue, widget.maxValue);
    }
    
    setState(() {
      _currentValue = finalValue;
    });
    
    widget.onAnswerChanged(widget.questionId, finalValue);
  }

  String _formatValue(double value) {
    if (widget.labelFormatter != null) {
      return widget.labelFormatter!(value);
    }
    
    // Show as integer if it's a whole number, otherwise show 1 decimal place
    if (value == value.roundToDouble()) {
      return '${value.toInt()}${widget.unit ?? ''}';
    } else {
      return '${value.toStringAsFixed(1)}${widget.unit ?? ''}';
    }
  }

  List<String> _generateLabels() {
    final int divisions = widget.divisions ?? 4;
    final List<String> labels = [];
    
    for (int i = 0; i <= divisions; i++) {
      final double value = widget.minValue + 
          (widget.maxValue - widget.minValue) * (i / divisions);
      labels.add(_formatValue(value));
    }
    
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = _generateLabels();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle if provided
        if (widget.subtitle != null) ...[
          Text(
            widget.subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Range info
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Range: ${_formatValue(widget.minValue)} - ${_formatValue(widget.maxValue)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Current Value Display
        if (widget.showValue && _currentValue != null) ...[
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _formatValue(_currentValue!),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Slider
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                  thumbColor: theme.colorScheme.primary,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  trackHeight: 6,
                  valueIndicatorColor: theme.colorScheme.primary,
                  valueIndicatorTextStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                child: Slider(
                  value: _currentValue ?? widget.minValue,
                  min: widget.minValue,
                  max: widget.maxValue,
                  divisions: widget.divisions,
                  label: _currentValue != null ? _formatValue(_currentValue!) : null,
                  onChanged: _onSliderChanged,
                ),
              ),
              
              // Scale labels
              if (widget.divisions != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels.map((label) {
                    return Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Tap to select specific values (for discrete sliders)
        if (widget.divisions != null && widget.divisions! <= 10) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.divisions! + 1, (index) {
              final double value = widget.minValue + 
                  (widget.maxValue - widget.minValue) * (index / widget.divisions!);
              final bool isSelected = _currentValue == value;
              
              return GestureDetector(
                onTap: () => _onSliderChanged(value),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatValue(value),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected 
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}