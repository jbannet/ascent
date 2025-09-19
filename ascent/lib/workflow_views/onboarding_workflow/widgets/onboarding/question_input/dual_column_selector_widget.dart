import 'package:flutter/material.dart';

/// A dual column selector widget for session commitment selection.
/// 
/// Displays two columns of numbered buttons (0-7) representing days per week.
/// When a button is clicked, it clears all selections in that column and
/// fills from the bottom up to the selected number with the primary color.
class DualColumnSelectorWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onChanged;
  final Map<String, dynamic>? initialValue;

  const DualColumnSelectorWidget({
    super.key,
    required this.config,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<DualColumnSelectorWidget> createState() => _DualColumnSelectorWidgetState();
}

class _DualColumnSelectorWidgetState extends State<DualColumnSelectorWidget> {
  late int leftValue;
  late int rightValue;
  
  @override
  void initState() {
    super.initState();
    leftValue = widget.initialValue?['full_sessions'] ?? 0;
    rightValue = widget.initialValue?['micro_sessions'] ?? 0;
  }
  
  void _updateValues(int left, int right) async {
    final oldLeft = leftValue;
    final oldRight = rightValue;
    
    // Determine which column is changing and animate it
    if (left != oldLeft) {
      await _animateColumnChange(left, true);
    }
    if (right != oldRight) {
      await _animateColumnChange(right, false);
    }
    
    widget.onChanged({
      'full_sessions': left,
      'micro_sessions': right,
    });
  }
  
  Future<void> _animateColumnChange(int targetValue, bool isLeft) async {
    final currentValue = isLeft ? leftValue : rightValue;
    
    if (targetValue > currentValue) {
      // Animate up (light up buttons one by one)
      for (int i = currentValue + 1; i <= targetValue; i++) {
        setState(() {
          if (isLeft) {
            leftValue = i;
          } else {
            rightValue = i;
          }
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } else if (targetValue < currentValue) {
      // Animate down (turn off buttons one by one)
      for (int i = currentValue; i > targetValue; i--) {
        setState(() {
          if (isLeft) {
            leftValue = i - 1;
          } else {
            rightValue = i - 1;
          }
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
  
  Widget _buildColumn({
    required String label,
    required String description,
    required int currentValue,
    required bool isLeft,
  }) {
    final config = isLeft ? widget.config['leftColumn'] : widget.config['rightColumn'];
    final maxValue = config['maxValue'] ?? 7;

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // Use grid layout for micro sessions (right column) when maxValue > 7
          if (!isLeft && maxValue > 7)
            _buildGridLayout(currentValue, maxValue)
          else
            _buildVerticalLayout(currentValue, maxValue, isLeft),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(int currentValue, int maxValue, bool isLeft) {
    return Column(
      children: List.generate(maxValue + 1, (index) {
        final buttonValue = maxValue - index; // maxValue, maxValue-1, ..., 1, 0
        final isSelected = buttonValue <= currentValue && buttonValue > 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                if (isLeft) {
                  _updateValues(buttonValue, rightValue);
                } else {
                  _updateValues(leftValue, buttonValue);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
                foregroundColor: isSelected
                  ? Colors.white
                  : Colors.black87,
                elevation: isSelected ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonValue == 0 ? 'None' : '$buttonValue',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGridLayout(int currentValue, int maxValue) {
    final rows = (maxValue / 2).ceil();

    return Column(
      children: [
        // Grid rows from top to bottom, but numbered from bottom to top
        ...List.generate(rows, (rowIndex) {
          final topRowIndex = rows - 1 - rowIndex; // Reverse row order for bottom-up numbering
          final leftValue = topRowIndex * 2 + 1;
          final rightValue = topRowIndex * 2 + 2;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                // Left button in this row
                Expanded(
                  child: _buildGridButton(leftValue, currentValue, maxValue),
                ),
                const SizedBox(width: 8),
                // Right button in this row (if it exists)
                Expanded(
                  child: rightValue <= maxValue
                    ? _buildGridButton(rightValue, currentValue, maxValue)
                    : const SizedBox(), // Empty space if no right button
                ),
              ],
            ),
          );
        }),
        // None button spans both columns
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _updateValues(leftValue, 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentValue == 0
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
                foregroundColor: currentValue == 0
                  ? Colors.white
                  : Colors.black87,
                elevation: currentValue == 0 ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'None',
                style: TextStyle(
                  fontWeight: currentValue == 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridButton(int buttonValue, int currentValue, int maxValue) {
    final isSelected = buttonValue <= currentValue && buttonValue > 0;

    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: () => _updateValues(leftValue, buttonValue),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey[200],
          foregroundColor: isSelected
            ? Colors.white
            : Colors.black87,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(
          '$buttonValue',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final leftConfig = widget.config['leftColumn'] as Map<String, dynamic>;
    final rightConfig = widget.config['rightColumn'] as Map<String, dynamic>;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColumn(
          label: leftConfig['label'] ?? 'Full Sessions',
          description: leftConfig['description'] ?? '30-60 minutes',
          currentValue: leftValue,
          isLeft: true,
        ),
        const SizedBox(width: 16),
        _buildColumn(
          label: rightConfig['label'] ?? 'Micro Sessions',
          description: rightConfig['description'] ?? '7-15 minutes',
          currentValue: rightValue,
          isLeft: false,
        ),
      ],
    );
  }
}