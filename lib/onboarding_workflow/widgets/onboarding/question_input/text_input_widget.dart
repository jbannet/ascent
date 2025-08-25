import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputWidget extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final String? placeholder;
  final String? currentValue;
  final Function(String questionId, String value) onAnswerChanged;
  final bool isRequired;
  final int? maxLength;
  final int? minLength;
  final bool multiline;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const TextInputWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    this.placeholder,
    this.currentValue,
    required this.onAnswerChanged,
    this.isRequired = true,
    this.maxLength,
    this.minLength,
    this.multiline = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  /// Creates TextInputWidget from configuration map with validation
  TextInputWidget.fromConfig(Map<String, dynamic> config, {super.key})
    : questionId = config['questionId'] ?? 
        (throw ArgumentError('TextInputWidget: questionId is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      title = config['title'] ?? 
        (throw ArgumentError('TextInputWidget: title is required. Question ID: ${config['questionId'] ?? 'missing'}')),
      subtitle = config['subtitle'] as String?,
      placeholder = config['placeholder'] as String?,
      currentValue = config['currentValue'] as String?,
      onAnswerChanged = config['onAnswerChanged'] ?? 
        (throw ArgumentError('TextInputWidget: onAnswerChanged is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      isRequired = config['isRequired'] as bool? ?? true,
      maxLength = config['maxLength'] as int?,
      minLength = config['minLength'] as int?,
      multiline = config['multiline'] as bool? ?? false,
      keyboardType = _parseKeyboardType(config['keyboardType'] as String?),
      inputFormatters = config['inputFormatters'] as List<TextInputFormatter>?,
      validator = config['validator'] as String? Function(String?)?;

  /// Helper to parse keyboard type from string
  static TextInputType? _parseKeyboardType(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'text': return TextInputType.text;
      case 'multiline': return TextInputType.multiline;
      case 'number': return TextInputType.number;
      case 'phone': return TextInputType.phone;
      case 'email': return TextInputType.emailAddress;
      case 'url': return TextInputType.url;
      case 'name': return TextInputType.name;
      default: return TextInputType.text;
    }
  }

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue ?? '');
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(TextInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      _controller.text = widget.currentValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final value = _controller.text;
    
    // Clear error when user starts typing
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }
    
    widget.onAnswerChanged(widget.questionId, value);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _validateInput();
    }
  }

  void _validateInput() {
    final value = _controller.text;
    String? error;

    // Required validation
    if (widget.isRequired && value.trim().isEmpty) {
      error = 'This field is required';
    }
    // Min length validation
    else if (widget.minLength != null && value.length < widget.minLength!) {
      error = 'Must be at least ${widget.minLength} characters';
    }
    // Max length validation
    else if (widget.maxLength != null && value.length > widget.maxLength!) {
      error = 'Must be no more than ${widget.maxLength} characters';
    }
    // Custom validator
    else if (widget.validator != null) {
      error = widget.validator!(value);
    }

    if (error != _errorText) {
      setState(() {
        _errorText = error;
      });
    }
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
        
        // Required indicator and character count
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.isRequired)
              Text(
                '* Required',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              const SizedBox.shrink(),
            
            if (widget.maxLength != null)
              Text(
                '${_controller.text.length}/${widget.maxLength}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _controller.text.length > widget.maxLength! 
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Text Input Field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType ?? 
              (widget.multiline ? TextInputType.multiline : TextInputType.text),
          inputFormatters: widget.inputFormatters,
          maxLines: widget.multiline ? null : 1,
          minLines: widget.multiline ? 3 : 1,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            errorText: _errorText,
            counterText: '', // Hide default counter since we show custom one
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
          onFieldSubmitted: (_) => _validateInput(),
        ),
        
        // Helper text for validation rules
        if (widget.minLength != null || widget.maxLength != null) ...[
          const SizedBox(height: 8),
          Text(
            _buildHelperText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  String _buildHelperText() {
    if (widget.minLength != null && widget.maxLength != null) {
      return 'Enter ${widget.minLength}-${widget.maxLength} characters';
    } else if (widget.minLength != null) {
      return 'Minimum ${widget.minLength} characters';
    } else if (widget.maxLength != null) {
      return 'Maximum ${widget.maxLength} characters';
    }
    return '';
  }
}