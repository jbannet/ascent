import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../services/general_utilities/num_formatter.dart';

class NumberInputWidget extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final String? placeholder;
  final double? currentValue;
  final Function(String questionId, double value) onAnswerChanged;
  final bool isRequired;
  final double? minValue;
  final double? maxValue;
  final bool allowDecimals;
  final int? decimalPlaces;
  final String? unit;
  final List<String>? unitOptions; // For toggleable units like cm/ft-in
  final String? selectedUnit;
  final Function(String)? onUnitChanged;

  const NumberInputWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    this.placeholder,
    this.currentValue,
    required this.onAnswerChanged,
    this.isRequired = true,
    this.minValue,
    this.maxValue,
    this.allowDecimals = true,
    this.decimalPlaces = 2,
    this.unit,
    this.unitOptions,
    this.selectedUnit,
    this.onUnitChanged,
  });

  /// Creates NumberInputWidget from configuration map with validation
  NumberInputWidget.fromConfig(Map<String, dynamic> config, {super.key})
    : questionId = config['questionId'] ?? 
        (throw ArgumentError('NumberInputWidget: questionId is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      title = config['title'] ?? 
        (throw ArgumentError('NumberInputWidget: title is required. Question ID: ${config['questionId'] ?? 'missing'}')),
      subtitle = config['subtitle'] as String?,
      placeholder = config['placeholder'] as String?,
      currentValue = config['currentValue'] as double?,
      onAnswerChanged = config['onAnswerChanged'] ?? 
        (throw ArgumentError('NumberInputWidget: onAnswerChanged is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      isRequired = config['isRequired'] as bool? ?? true,
      minValue = config['minValue'] as double?,
      maxValue = config['maxValue'] as double?,
      allowDecimals = config['allowDecimals'] as bool? ?? true,
      decimalPlaces = config['decimalPlaces'] as int? ?? 2,
      unit = config['unit'] as String?,
      unitOptions = config['unitOptions'] != null 
          ? List<String>.from(config['unitOptions'] as List)
          : null,
      selectedUnit = config['selectedUnit'] as String?,
      onUnitChanged = config['onUnitChanged'] as Function(String)?;

  @override
  State<NumberInputWidget> createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  late TextEditingController _controller;
  String? _errorText;
  String? _currentUnit;

  @override
  void initState() {
    super.initState();
    _currentUnit = widget.selectedUnit ?? widget.unitOptions?.first ?? widget.unit;
    _controller = TextEditingController(
      text: widget.currentValue != null 
          ? formatWithNPlaces(widget.currentValue!, widget.allowDecimals ? (widget.decimalPlaces ?? 2) : 0)
          : '',
    );
  }

  @override
  void didUpdateWidget(NumberInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      _controller.text = widget.currentValue != null 
          ? formatWithNPlaces(widget.currentValue!, widget.allowDecimals ? (widget.decimalPlaces ?? 2) : 0)
          : '';
    }
    if (widget.selectedUnit != oldWidget.selectedUnit) {
      _currentUnit = widget.selectedUnit ?? widget.unitOptions?.first ?? widget.unit;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _controller.text.trim();
    String? error;

    // Required validation
    if (widget.isRequired && text.isEmpty) {
      error = 'This field is required';
    } else if (text.isNotEmpty) {
      final number = double.tryParse(text);
      
      if (number == null) {
        error = 'Please enter a valid number';
      } else {
        // Min value validation
        if (widget.minValue != null && number < widget.minValue!) {
          error = 'Must be at least ${widget.minValue}';
        }
        // Max value validation
        else if (widget.maxValue != null && number > widget.maxValue!) {
          error = 'Must be no more than ${widget.maxValue}';
        }
        // Decimal places validation
        else if (!widget.allowDecimals && number != number.round()) {
          error = 'Decimals are not allowed';
        }
      }
    }

    if (error != _errorText) {
      setState(() {
        _errorText = error;
      });
    }
  }

  void _onUnitChanged(String unit) {
    setState(() {
      _currentUnit = unit;
    });
    if (widget.onUnitChanged != null) {
      widget.onUnitChanged!(unit);
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    if (widget.allowDecimals) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        if (widget.decimalPlaces != null)
          _DecimalTextInputFormatter(decimalRange: widget.decimalPlaces!),
      ];
    } else {
      return [FilteringTextInputFormatter.digitsOnly];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
        if (widget.minValue != null || widget.maxValue != null)
          Text(
            _buildRangeText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Number Input Field with optional unit selector
        Row(
          children: [
            // Main input field
            Expanded(
              child: TextFormField(
                controller: _controller,
                keyboardType: widget.allowDecimals 
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                inputFormatters: _getInputFormatters(),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  errorText: _errorText,
                  suffixText: widget.unitOptions == null ? _currentUnit : null,
                  suffixStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                onChanged: (text) {
                  // Clear error when user starts typing
                  if (_errorText != null) {
                    setState(() {
                      _errorText = null;
                    });
                  }
                  
                  // Parse and validate the number
                  final number = double.tryParse(text);
                  if (number != null) {
                    widget.onAnswerChanged(widget.questionId, number);
                  }
                },
                onFieldSubmitted: (_) => _validateInput(),
              ),
            ),
            
            // Unit selector if multiple units available
            if (widget.unitOptions != null && widget.unitOptions!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _currentUnit,
                  items: widget.unitOptions!.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          unit,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _onUnitChanged(value);
                    }
                  },
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _buildRangeText() {
    if (widget.minValue != null && widget.maxValue != null) {
      return 'Range: ${widget.minValue} - ${widget.maxValue}';
    } else if (widget.minValue != null) {
      return 'Min: ${widget.minValue}';
    } else if (widget.maxValue != null) {
      return 'Max: ${widget.maxValue}';
    }
    return '';
  }
}

class _DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  _DecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    
    if (newText.contains('.')) {
      String substring = newText.substring(newText.indexOf('.') + 1);
      if (substring.length > decimalRange) {
        return oldValue;
      }
    }
    
    return newValue;
  }
}