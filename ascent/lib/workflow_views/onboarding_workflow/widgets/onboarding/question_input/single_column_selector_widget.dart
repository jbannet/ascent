import 'package:flutter/material.dart';

/// A single column selector widget for numeric selection.
///
/// Displays a single column of numbered buttons (0-maxValue) representing counts.
/// When a button is clicked, it clears all selections and fills from the bottom
/// up to the selected number with the primary color, with animation.
class SingleColumnSelectorWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(int) onChanged;
  final int? initialValue;

  const SingleColumnSelectorWidget({
    super.key,
    required this.config,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<SingleColumnSelectorWidget> createState() => _SingleColumnSelectorWidgetState();
}

class _SingleColumnSelectorWidgetState extends State<SingleColumnSelectorWidget> {
  late int currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue ?? 0;
  }

  void _updateValue(int newValue) async {
    final oldValue = currentValue;

    // Animate the change
    await _animateChange(newValue, oldValue);

    widget.onChanged(newValue);
  }

  Future<void> _animateChange(int targetValue, int oldValue) async {
    if (targetValue > oldValue) {
      // Animate up (light up buttons one by one)
      for (int i = oldValue + 1; i <= targetValue; i++) {
        setState(() {
          currentValue = i;
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } else if (targetValue < oldValue) {
      // Animate down (turn off buttons one by one)
      for (int i = oldValue; i > targetValue; i--) {
        setState(() {
          currentValue = i - 1;
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final maxValue = config['maxValue'] ?? 7;
    final label = config['label'] ?? '';
    final description = config['description'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          // Vertical layout of buttons (same logic as DualColumnSelectorWidget._buildVerticalLayout)
          Column(
            children: List.generate(maxValue + 1, (index) {
              final buttonValue = maxValue - index; // maxValue, maxValue-1, ..., 1, 0
              final isSelected = buttonValue == 0
                ? currentValue == 0
                : (buttonValue <= currentValue && buttonValue > 0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      _updateValue(buttonValue);
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
          ),
        ],
      ),
    );
  }
}