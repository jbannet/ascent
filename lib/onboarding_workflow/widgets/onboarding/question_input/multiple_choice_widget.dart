import 'package:flutter/material.dart';

class MultipleChoiceOption {
  final String id;
  final String label;
  final String? description;
  final dynamic value;

  const MultipleChoiceOption({
    required this.id,
    required this.label,
    this.description,
    required this.value,
  });
}

class MultipleChoiceWidget extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final List<MultipleChoiceOption> options;
  final List<String>? selectedValues;
  final Function(String questionId, List<String> values) onAnswerChanged;
  final bool isRequired;
  final int? maxSelections;
  final int? minSelections;

  const MultipleChoiceWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    required this.options,
    this.selectedValues,
    required this.onAnswerChanged,
    this.isRequired = true,
    this.maxSelections,
    this.minSelections,
  });

  /// Creates MultipleChoiceWidget from configuration map with validation
  MultipleChoiceWidget.fromConfig(Map<String, dynamic> config, {super.key})
    : questionId = config['questionId'] ?? 
        (throw ArgumentError('MultipleChoiceWidget: questionId is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      title = config['title'] ?? 
        (throw ArgumentError('MultipleChoiceWidget: title is required. Question ID: ${config['questionId'] ?? 'missing'}')),
      subtitle = config['subtitle'] as String?,
      options = config['options'] ?? 
        (throw ArgumentError('MultipleChoiceWidget: options is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      selectedValues = config['selectedValues'] as List<String>?,
      onAnswerChanged = config['onAnswerChanged'] ?? 
        (throw ArgumentError('MultipleChoiceWidget: onAnswerChanged is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      isRequired = config['isRequired'] as bool? ?? true,
      maxSelections = config['maxSelections'] as int?,
      minSelections = config['minSelections'] as int?;

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  List<String> _selectedValues = [];

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.selectedValues?.toList() ?? [];
  }

  @override
  void didUpdateWidget(MultipleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues != oldWidget.selectedValues) {
      _selectedValues = widget.selectedValues?.toList() ?? [];
    }
  }

  void _onOptionToggled(String value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        // Check max selections limit
        if (widget.maxSelections != null && 
            _selectedValues.length >= widget.maxSelections!) {
          // Show feedback that max is reached
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can select up to ${widget.maxSelections} options',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _selectedValues.add(value);
      }
    });
    widget.onAnswerChanged(widget.questionId, _selectedValues);
  }

  String _getSelectionHint() {
    if (widget.maxSelections != null && widget.minSelections != null) {
      return 'Select ${widget.minSelections}-${widget.maxSelections} options';
    } else if (widget.maxSelections != null) {
      return 'Select up to ${widget.maxSelections} options';
    } else if (widget.minSelections != null) {
      return 'Select at least ${widget.minSelections} options';
    }
    return 'Select all that apply';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Title
        Text(
          widget.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        // Subtitle if provided
        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        
        const SizedBox(height: 8),
        
        // Selection hint and required indicator
        Row(
          children: [
            Text(
              _getSelectionHint(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.isRequired) ...[
              const SizedBox(width: 8),
              Text(
                '* Required',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        
        // Selection counter
        if (widget.maxSelections != null) ...[
          const SizedBox(height: 4),
          Text(
            '${_selectedValues.length}/${widget.maxSelections} selected',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
        
        const SizedBox(height: 20),
        
        // Options
        Column(
          children: widget.options.map((option) {
            final isSelected = _selectedValues.contains(option.value.toString());
            final isDisabled = !isSelected && 
                               widget.maxSelections != null && 
                               _selectedValues.length >= widget.maxSelections!;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : () => _onOptionToggled(option.value.toString()),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : isDisabled
                                ? theme.colorScheme.outline.withValues(alpha: 0.2)
                                : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected 
                          ? theme.colorScheme.primary.withValues(alpha: 0.05)
                          : isDisabled
                              ? theme.colorScheme.surface.withValues(alpha: 0.5)
                              : theme.colorScheme.surface,
                    ),
                    child: Row(
                      children: [
                        // Checkbox indicator
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected 
                                  ? theme.colorScheme.primary 
                                  : isDisabled
                                      ? theme.colorScheme.outline.withValues(alpha: 0.3)
                                      : theme.colorScheme.outline,
                              width: 2,
                            ),
                            color: isSelected 
                                ? theme.colorScheme.primary 
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 12,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : null,
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Option content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.w400,
                                  color: isSelected 
                                      ? theme.colorScheme.primary 
                                      : isDisabled
                                          ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                          : theme.colorScheme.onSurface,
                                ),
                              ),
                              if (option.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  option.description!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDisabled
                                        ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}