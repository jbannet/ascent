import 'package:flutter/material.dart';

class DatePickerWidget extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final DateTime? currentValue;
  final Function(String questionId, DateTime value) onAnswerChanged;
  final bool isRequired;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? placeholder;
  final DatePickerMode initialDatePickerMode;

  const DatePickerWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    this.currentValue,
    required this.onAnswerChanged,
    this.isRequired = true,
    this.minDate,
    this.maxDate,
    this.placeholder,
    this.initialDatePickerMode = DatePickerMode.day,
  });

  /// Creates DatePickerWidget from configuration map with validation
  DatePickerWidget.fromConfig(Map<String, dynamic> config, {super.key})
    : questionId = config['questionId'] ?? 
        (throw ArgumentError('DatePickerWidget: questionId is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      title = config['title'] ?? 
        (throw ArgumentError('DatePickerWidget: title is required. Question ID: ${config['questionId'] ?? 'missing'}')),
      subtitle = config['subtitle'] as String?,
      currentValue = config['currentValue'] as DateTime?,
      onAnswerChanged = config['onAnswerChanged'] ?? 
        (throw ArgumentError('DatePickerWidget: onAnswerChanged is required. Question: "${config['title'] ?? 'unknown'}" (ID: ${config['questionId'] ?? 'missing'})')),
      isRequired = config['isRequired'] as bool? ?? true,
      minDate = _parseDate(config['minDate']),
      maxDate = _parseDate(config['maxDate']),
      placeholder = config['placeholder'] as String?,
      initialDatePickerMode = _parseDatePickerMode(config['initialDatePickerMode'] as String?) ?? DatePickerMode.day;

  /// Helper to parse date from string
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Helper to parse DatePickerMode from string
  static DatePickerMode? _parseDatePickerMode(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'day': return DatePickerMode.day;
      case 'year': return DatePickerMode.year;
      default: return DatePickerMode.day;
    }
  }

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.currentValue;
  }

  @override
  void didUpdateWidget(DatePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      _selectedDate = widget.currentValue;
    }
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = widget.minDate ?? DateTime(now.year - 100);
    final DateTime lastDate = widget.maxDate ?? DateTime(now.year + 10);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? 
          (now.isBefore(lastDate) && now.isAfter(firstDate) 
              ? now 
              : firstDate),
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: widget.initialDatePickerMode,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onAnswerChanged(widget.questionId, picked);
    }
  }

  void _clearDate() {
    if (!widget.isRequired) {
      setState(() {
        _selectedDate = null;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDateRangeText() {
    if (widget.minDate != null && widget.maxDate != null) {
      return 'Between ${_formatDate(widget.minDate!)} and ${_formatDate(widget.maxDate!)}';
    } else if (widget.minDate != null) {
      return 'After ${_formatDate(widget.minDate!)}';
    } else if (widget.maxDate != null) {
      return 'Before ${_formatDate(widget.maxDate!)}';
    }
    return '';
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
        
        // Required indicator and date range info
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
            
            if (_getDateRangeText().isNotEmpty)
              Flexible(
                child: Text(
                  _getDateRangeText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Date Picker Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedDate != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: _selectedDate != null ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: _selectedDate != null
                    ? theme.colorScheme.primary.withValues(alpha: 0.05)
                    : theme.colorScheme.surface,
              ),
              child: Row(
                children: [
                  // Calendar icon
                  Icon(
                    Icons.calendar_today_outlined,
                    color: _selectedDate != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Date text or placeholder
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : widget.placeholder ?? 'Select a date',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _selectedDate != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: _selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  
                  // Clear button (if not required and date is selected)
                  if (!widget.isRequired && _selectedDate != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _clearDate,
                      child: Icon(
                        Icons.clear,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
                  ],
                  
                  // Dropdown arrow
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Selected date preview with additional info
        if (_selectedDate != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_selectedDate!),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Show days from now if it's a future date
                if (_selectedDate!.isAfter(DateTime.now())) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedDate!.difference(DateTime.now()).inDays + 1} days from now',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        
        // Quick date options (for common selections)
        if (widget.maxDate != null && widget.maxDate!.isAfter(DateTime.now())) ...[
          const SizedBox(height: 16),
          Text(
            'Quick Options',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildQuickOptions(theme),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildQuickOptions(ThemeData theme) {
    final now = DateTime.now();
    final quickOptions = <String, DateTime>{
      '1 month': DateTime(now.year, now.month + 1, now.day),
      '3 months': DateTime(now.year, now.month + 3, now.day),
      '6 months': DateTime(now.year, now.month + 6, now.day),
      '1 year': DateTime(now.year + 1, now.month, now.day),
    };

    return quickOptions.entries
        .where((entry) => 
            widget.maxDate == null || entry.value.isBefore(widget.maxDate!) ||
            entry.value.isAtSameMomentAs(widget.maxDate!))
        .map((entry) {
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == entry.value.year &&
          _selectedDate!.month == entry.value.month &&
          _selectedDate!.day == entry.value.day;

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = entry.value;
          });
          widget.onAnswerChanged(widget.questionId, entry.value);
        },
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
            entry.key,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
    }).toList();
  }
}