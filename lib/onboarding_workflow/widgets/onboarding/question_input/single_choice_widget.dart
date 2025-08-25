import 'package:flutter/material.dart';

class SingleChoiceOption {
  final String id;
  final String label;
  final String? description;
  final dynamic value;

  const SingleChoiceOption({
    required this.id,
    required this.label,
    this.description,
    required this.value,
  });
}

class SingleChoiceWidget extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final List<SingleChoiceOption> options;
  final String? selectedValue;
  final Function(String questionId, dynamic value) onAnswerChanged;
  final bool isRequired;

  const SingleChoiceWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    required this.options,
    this.selectedValue,
    required this.onAnswerChanged,
    this.isRequired = true,
  });

  /// Creates SingleChoiceWidget from configuration map with validation
  SingleChoiceWidget.fromConfig(Map<String, dynamic> config, {super.key})
    : questionId = config['questionId'] ?? 
        (throw ArgumentError('SingleChoiceWidget: questionId is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      title = config['title'] ?? 
        (throw ArgumentError('SingleChoiceWidget: title is required. Question ID: ${config['questionId'] ?? 'missing'}')),
      subtitle = config['subtitle'] as String?,
      options = config['options'] ?? 
        (throw ArgumentError('SingleChoiceWidget: options is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      selectedValue = config['selectedValue'] as String?,
      onAnswerChanged = config['onAnswerChanged'] ?? 
        (throw ArgumentError('SingleChoiceWidget: onAnswerChanged is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      isRequired = config['isRequired'] as bool? ?? true;

  @override
  State<SingleChoiceWidget> createState() => _SingleChoiceWidgetState();
}

class _SingleChoiceWidgetState extends State<SingleChoiceWidget> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(SingleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _selectedValue = widget.selectedValue;
    }
  }

  void _onOptionSelected(String value) {
    setState(() {
      _selectedValue = value;
    });
    widget.onAnswerChanged(widget.questionId, value);
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
        
        // Required indicator
        if (widget.isRequired) ...[
          const SizedBox(height: 4),
          Text(
            '* Required',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        
        const SizedBox(height: 20),
        
        // Options
        Column(
          children: widget.options.map((option) {
            final isSelected = _selectedValue == option.value.toString();
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onOptionSelected(option.value.toString()),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected 
                          ? theme.colorScheme.primary.withValues(alpha: 0.05)
                          : theme.colorScheme.surface,
                    ),
                    child: Row(
                      children: [
                        // Radio indicator
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? theme.colorScheme.primary 
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
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              if (option.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  option.description!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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