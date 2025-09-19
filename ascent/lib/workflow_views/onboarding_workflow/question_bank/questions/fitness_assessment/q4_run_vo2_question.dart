import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../models/questions/enum_question_type.dart';
import '../onboarding_question.dart';
import '../../../../../constants_and_enums/constants.dart';

/// Data class for storing run performance data
class RunPerformanceData {
  final double distanceMiles;
  final int timeMinutes;
  final String selectedUnit;

  RunPerformanceData({
    required this.distanceMiles,
    required this.timeMinutes,
    required this.selectedUnit,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    AnswerConstants.runDistanceMiles: distanceMiles,
    AnswerConstants.runTimeMinutes: timeMinutes,
    AnswerConstants.runSelectedUnit: selectedUnit,
  };

  /// Create from JSON
  factory RunPerformanceData.fromJson(Map<String, dynamic> json) {
    return RunPerformanceData(
      distanceMiles: json[AnswerConstants.runDistanceMiles]?.toDouble() ?? 0.0,
      timeMinutes: json[AnswerConstants.runTimeMinutes]?.toInt() ?? 30,
      selectedUnit: json[AnswerConstants.runSelectedUnit] ?? 'miles',
    );
  }

  /// Create from legacy Cooper test distance (in miles)
  factory RunPerformanceData.fromLegacyCooperTest(double distanceMiles) {
    return RunPerformanceData(
      distanceMiles: distanceMiles,
      timeMinutes: 12, // Cooper test is always 12 minutes
      selectedUnit: 'miles',
    );
  }
}

/// Q4: How far in what time can you run before reaching exhaustion?
///
/// This question assesses cardiovascular fitness by capturing the user's best running performance.
/// It contributes to cardio fitness, VO2 max estimation, and training intensity features.
class Q4TwelveMinuteRunQuestion extends OnboardingQuestion {
  static const String questionId = 'Q4';
  static final Q4TwelveMinuteRunQuestion instance = Q4TwelveMinuteRunQuestion._();
  Q4TwelveMinuteRunQuestion._();
  
  //MARK: UI PRESENTATION DATA
  
  @override
  String get id => Q4TwelveMinuteRunQuestion.questionId;
  
  @override
  String get questionText => 'How far in what time can you run before reaching exhaustion?';
  
  @override
  String get section => 'fitness_assessment';
  
  @override
  EnumQuestionType get questionType => EnumQuestionType.custom;
  
  @override
  String? get subtitle => 'For example, a best race time or max time at a pace on a treadmill - you can use either miles or kilometers';
  
  @override
  Map<String, dynamic> get config => {
    'isRequired': true,
  };
  
  
  //MARK: VALIDATION
  
  /// Validation is handled by the dual picker UI
  
  @override
  void fromJsonValue(dynamic json) {
    if (json is RunPerformanceData) {
      _runPerformanceData = json;
    } else if (json is Map<String, dynamic>) {
      _runPerformanceData = RunPerformanceData.fromJson(json);
    } else if (json is String) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(json);
        _runPerformanceData = RunPerformanceData.fromJson(decoded);
      } catch (e) {
        _runPerformanceData = null;
      }
    } else if (json is num) {
      // Legacy support for old Cooper test format
      _runPerformanceData = RunPerformanceData.fromLegacyCooperTest(json.toDouble());
    } else {
      _runPerformanceData = null;
    }
  }
  
  //MARK: TYPED ACCESSOR
  
  /// Get run distance in miles from answers
  double? getRunDistanceMiles(Map<String, dynamic> answers) {
    final answer = answers[questionId];
    if (answer == null) return null;

    if (answer is Map<String, dynamic>) {
      return answer['distanceMiles']?.toDouble();
    } else if (answer is num) {
      // Legacy support for old Cooper test format
      return answer.toDouble();
    }
    return null;
  }

  /// Get run time in minutes from answers
  int? getRunTimeMinutes(Map<String, dynamic> answers) {
    final answer = answers[questionId];
    if (answer == null) return null;

    if (answer is Map<String, dynamic>) {
      return answer['timeMinutes']?.toInt();
    } else if (answer is num) {
      // Legacy support - assume 12 minutes for old Cooper test
      return 12;
    }
    return null;
  }

  //MARK: TYPED ANSWER INTERFACE
  
  //MARK: ANSWER STORAGE

  RunPerformanceData? _runPerformanceData;
  
  @override
  String? get answer => _runPerformanceData != null ? jsonEncode(_runPerformanceData!.toJson()) : null;

  /// Get the typed run performance data
  RunPerformanceData? get runPerformanceData => _runPerformanceData;

  /// Set the run distance and time with unit conversion if needed
  void setRunData({
    required double distance,
    required String unit,
    required int timeMinutes,
  }) {
    final distanceMiles = unit == 'km' ? distance * 0.621371 : distance;
    _runPerformanceData = RunPerformanceData(
      distanceMiles: distanceMiles,
      timeMinutes: timeMinutes,
      selectedUnit: unit,
    );
  }

  /// Get the run distance as a typed double (always in miles)
  double? get runDistanceMiles => _runPerformanceData?.distanceMiles;

  /// Get the run time as a typed int (in minutes)
  int? get runTimeMinutes => _runPerformanceData?.timeMinutes;

  /// Get the selected unit for display
  String get selectedUnit => _runPerformanceData?.selectedUnit ?? 'miles';

  get answerDouble => null;

  @override
  Widget buildAnswerWidget(
    Function() onAnswerChanged,
  ) {
    return _DistanceTimePickerWidget(
      initialDistanceMiles: _runPerformanceData?.distanceMiles,
      initialTimeMinutes: _runPerformanceData?.timeMinutes,
      initialUnit: _runPerformanceData?.selectedUnit ?? 'miles',
      onChanged: (distance, unit, timeMinutes) {
        setRunData(
          distance: distance,
          unit: unit,
          timeMinutes: timeMinutes,
        );
        onAnswerChanged();
      },
    );
  }
}

/// Custom widget for selecting distance, unit, and time
class _DistanceTimePickerWidget extends StatefulWidget {
  final double? initialDistanceMiles;
  final int? initialTimeMinutes;
  final String initialUnit;
  final Function(double distance, String unit, int timeMinutes) onChanged;

  const _DistanceTimePickerWidget({
    this.initialDistanceMiles,
    this.initialTimeMinutes,
    required this.initialUnit,
    required this.onChanged,
  });

  @override
  State<_DistanceTimePickerWidget> createState() => _DistanceTimePickerWidgetState();
}

class _DistanceTimePickerWidgetState extends State<_DistanceTimePickerWidget> {
  late String _selectedUnit;
  late double _wholeDistance;
  late double _decimalDistance;
  late int _timeMinutes;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.initialUnit;

    // If we have existing data, use it
    if (widget.initialDistanceMiles != null && widget.initialTimeMinutes != null) {
      double displayDistance = widget.initialDistanceMiles!;
      if (_selectedUnit == 'km') {
        displayDistance = widget.initialDistanceMiles! / 0.621371; // Convert miles to km
      }
      _wholeDistance = displayDistance.floor().toDouble();
      _decimalDistance = double.parse((displayDistance - _wholeDistance).toStringAsFixed(1));
      _timeMinutes = widget.initialTimeMinutes!;
    } else {
      // Start with zero/minimal values - user must interact
      _wholeDistance = 0.0;
      _decimalDistance = 0.0;
      _timeMinutes = 10; // Minimum reasonable time
    }
    // NO automatic _updateAnswer() call - wait for user interaction
  }

  void _updateAnswer() {
    final totalDistance = _wholeDistance + _decimalDistance;
    widget.onChanged(totalDistance, _selectedUnit, _timeMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Unit toggle
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedUnit != 'miles') {
                        _selectedUnit = 'miles';
                        // Convert current km distance to miles for display
                        final currentTotal = _wholeDistance + _decimalDistance;
                        final milesDistance = currentTotal * 0.621371;
                        _wholeDistance = milesDistance.floor().toDouble();
                        _decimalDistance = double.parse((milesDistance - _wholeDistance).toStringAsFixed(1));
                        _updateAnswer();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedUnit == 'miles'
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Miles',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedUnit == 'miles'
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedUnit != 'km') {
                        _selectedUnit = 'km';
                        // Convert current miles distance to km for display
                        final currentTotal = _wholeDistance + _decimalDistance;
                        final kmDistance = currentTotal / 0.621371;
                        _wholeDistance = kmDistance.floor().toDouble();
                        _decimalDistance = double.parse((kmDistance - _wholeDistance).toStringAsFixed(1));
                        _updateAnswer();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedUnit == 'km'
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Kilometers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedUnit == 'km'
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Distance and time pickers
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
          ),
          child: Column(
            children: [
              // Total display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  '${(_wholeDistance + _decimalDistance).toStringAsFixed(1)} $_selectedUnit in $_timeMinutes minutes',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Pickers row
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Distance whole number picker
                    Expanded(
                      child: _buildWheelPicker(
                        label: _selectedUnit == 'miles' ? 'Miles' : 'Kilometers',
                        values: List.generate(21, (index) => index.toDouble()), // 0-20
                        selectedValue: _wholeDistance,
                        onChanged: (value) {
                          setState(() {
                            _wholeDistance = value;
                            _updateAnswer();
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Distance decimal picker
                    Expanded(
                      child: _buildWheelPicker(
                        label: 'Tenths',
                        values: [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],
                        selectedValue: _decimalDistance,
                        onChanged: (value) {
                          setState(() {
                            _decimalDistance = value;
                            _updateAnswer();
                          });
                        },
                        formatValue: (value) => value.toStringAsFixed(1),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Time picker
                    Expanded(
                      child: _buildWheelPicker(
                        label: 'Minutes',
                        values: List.generate(121, (index) => (index + 5).toDouble()), // 5-125 minutes
                        selectedValue: _timeMinutes.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _timeMinutes = value.toInt();
                            _updateAnswer();
                          });
                        },
                        formatValue: (value) => value.toInt().toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Running image
        Image.asset(
          'assets/images/kettle_running.png',
          height: 180,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildWheelPicker({
    required String label,
    required List<double> values,
    required double selectedValue,
    required Function(double) onChanged,
    String Function(double)? formatValue,
  }) {
    final theme = Theme.of(context);
    final formatter = formatValue ?? (value) => value.toInt().toString();

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListWheelScrollView.useDelegate(
            controller: FixedExtentScrollController(
              initialItem: _findClosestIndex(values, selectedValue),
            ),
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              onChanged(values[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index >= values.length) return null;
                final value = values[index];
                final isSelected = (value - selectedValue).abs() < 0.001;

                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    formatter(value),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
              childCount: values.length,
            ),
          ),
        ),
      ],
    );
  }

  int _findClosestIndex(List<double> values, double target) {
    if (values.isEmpty) return 0;

    int closestIndex = 0;
    double closestDifference = (values[0] - target).abs();

    for (int i = 1; i < values.length; i++) {
      final difference = (values[i] - target).abs();
      if (difference < closestDifference) {
        closestIndex = i;
        closestDifference = difference;
      }
    }

    return closestIndex;
  }
}