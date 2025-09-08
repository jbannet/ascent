import 'package:flutter/material.dart';

/// A height selector widget with separate dropdowns for feet and inches.
/// 
/// Provides an intuitive interface for height selection in US imperial units
/// with dropdown selectors for feet (3-8) and inches (0-11).
class HeightSelectorWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onChanged;
  final Map<String, dynamic>? initialValue;

  const HeightSelectorWidget({
    super.key,
    required this.config,
    required this.onChanged,
    this.initialValue,
  });

  /// Factory constructor to create from configuration
  factory HeightSelectorWidget.fromConfig({
    required Map<String, dynamic> config,
    required Function(Map<String, dynamic>) onChanged,
    Map<String, dynamic>? initialValue,
  }) {
    return HeightSelectorWidget(
      config: config,
      onChanged: onChanged,
      initialValue: initialValue,
    );
  }

  @override
  State<HeightSelectorWidget> createState() => _HeightSelectorWidgetState();
}

class _HeightSelectorWidgetState extends State<HeightSelectorWidget> {
  late int feet;
  late int inches;

  @override
  void initState() {
    super.initState();
    feet = widget.initialValue?['feet'] ?? 5;
    inches = widget.initialValue?['inches'] ?? 6;
  }

  void _updateHeight(int newFeet, int newInches) {
    setState(() {
      feet = newFeet;
      inches = newInches;
    });
    widget.onChanged({
      'feet': newFeet,
      'inches': newInches,
    });
  }

  Widget _buildDropdown({
    required String label,
    required String unit,
    required int value,
    required int minValue,
    required int maxValue,
    required bool isFeet,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                items: List.generate(maxValue - minValue + 1, (index) {
                  final dropdownValue = minValue + index;
                  return DropdownMenuItem<int>(
                    value: dropdownValue,
                    child: Text(
                      '$dropdownValue $unit',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    if (isFeet) {
                      _updateHeight(newValue, inches);
                    } else {
                      _updateHeight(feet, newValue);
                    }
                  }
                },
                icon: const Icon(Icons.keyboard_arrow_down),
                iconSize: 24,
                elevation: 2,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                ),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display current selection
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            'Selected height: $feet\'$inches"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        
        // Dropdowns
        Row(
          children: [
            _buildDropdown(
              label: 'Feet',
              unit: 'ft',
              value: feet,
              minValue: 3,
              maxValue: 8,
              isFeet: true,
            ),
            const SizedBox(width: 16),
            _buildDropdown(
              label: 'Inches',
              unit: 'in',
              value: inches,
              minValue: 0,
              maxValue: 11,
              isFeet: false,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Quick select common heights
        Text(
          'Quick select:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickSelectButton("5'0\"", 5, 0),
            _buildQuickSelectButton("5'3\"", 5, 3),
            _buildQuickSelectButton("5'6\"", 5, 6),
            _buildQuickSelectButton("5'9\"", 5, 9),
            _buildQuickSelectButton("6'0\"", 6, 0),
            _buildQuickSelectButton("6'3\"", 6, 3),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickSelectButton(String label, int quickFeet, int quickInches) {
    final isSelected = feet == quickFeet && inches == quickInches;
    
    return GestureDetector(
      onTap: () => _updateHeight(quickFeet, quickInches),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}