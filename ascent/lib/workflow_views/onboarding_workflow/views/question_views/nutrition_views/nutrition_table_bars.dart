import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuration for each nutrition type in the table bars
class NutritionBarConfig {
  final String type;
  final String icon;
  final Color color;
  final int maxValue;

  const NutritionBarConfig({
    required this.type,
    required this.icon,
    required this.color,
    required this.maxValue,
  });

  static const Map<String, NutritionBarConfig> configs = {
    'treats': NutritionBarConfig(
      type: 'treats',
      icon: '🍪',
      color: Color(0xFFFF6F61), // Coral
      maxValue: 15,
    ),
    'sodas': NutritionBarConfig(
      type: 'sodas',
      icon: '🥤',
      color: Color(0xFFE9C46A), // Amber
      maxValue: 15,
    ),
    'grains': NutritionBarConfig(
      type: 'grains',
      icon: '🌾',
      color: Color(0xFF29AD8F), // Teal
      maxValue: 15,
    ),
    'alcohol': NutritionBarConfig(
      type: 'alcohol',
      icon: '🍷',
      color: Color(0xFF8A4FD3), // Purple
      maxValue: 20,
    ),
  };
}

/// Table-based nutrition bar widget with click/drag interaction
class NutritionTableBars extends StatefulWidget {
  final Map<String, int> allValues;
  final String currentType;
  final Function(String type, int value) onValueChanged;

  const NutritionTableBars({
    super.key,
    required this.allValues,
    required this.currentType,
    required this.onValueChanged,
  });

  @override
  State<NutritionTableBars> createState() => _NutritionTableBarsState();
}

class _NutritionTableBarsState extends State<NutritionTableBars> {
  final GlobalKey _tableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeConfig = NutritionBarConfig.configs[widget.currentType];
    final currentValue = widget.allValues[widget.currentType] ?? 0;

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (currentValue < (activeConfig?.maxValue ?? 15)) {
              widget.onValueChanged(widget.currentType, currentValue + 1);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (currentValue > 0) {
              widget.onValueChanged(widget.currentType, currentValue - 1);
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
        // Table
        Semantics(
          label: 'Nutrition tracking graph. Currently editing ${widget.currentType} with $currentValue servings per day.',
          hint: 'Tap or drag anywhere to adjust. Use arrow keys to increase or decrease.',
          slider: true,
          value: currentValue.toString(),
          increasedValue: (currentValue + 1).toString(),
          decreasedValue: (currentValue - 1).toString(),
          onIncrease: currentValue < (activeConfig?.maxValue ?? 15) ? () {
            widget.onValueChanged(widget.currentType, currentValue + 1);
          } : null,
          onDecrease: currentValue > 0 ? () {
            widget.onValueChanged(widget.currentType, currentValue - 1);
          } : null,
          child: GestureDetector(
            onTapDown: (details) => _handleGraphTap(details),
            onPanUpdate: (details) => _handleGraphDrag(details),
            child: Container(
            key: _tableKey,
            height: 300, // Fixed height for vertical bars
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                // Left scale (numbers)
                _buildLeftScale(theme),

                // Nutrition bars (vertical)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: NutritionBarConfig.configs.entries.map((entry) {
                      final config = entry.value;
                      final value = widget.allValues[config.type] ?? 0;
                      final isActive = config.type == widget.currentType;

                      return _buildVerticalNutritionBar(config, value, isActive, theme);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),

        const SizedBox(height: 8),
        
        // Bottom icons
        _buildBottomIcons(theme),
        ],
      ),
    );
  }

  Widget _buildVerticalNutritionBar(NutritionBarConfig config, int value, bool isActive, ThemeData theme) {
    const chartHeight = 250.0; // Leave space for padding in 300px container

    return Expanded(
      child: Semantics(
        label: !isActive ? '${config.type}: $value servings per day' : null,
        excludeSemantics: isActive, // Active bar is announced by parent Semantics
        child: Container(
          height: chartHeight,
          margin: const EdgeInsets.symmetric(horizontal: 1), // Minimal margin so bars almost touch
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background bar (empty state) - full width
              Semantics(
                excludeSemantics: true, // Decorative element
                child: Container(
                  width: double.infinity,
                  height: chartHeight,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Filled bar (grows upward from bottom) - full width
              Semantics(
                excludeSemantics: true, // Value is announced by parent
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: _getBarHeight(value, config.maxValue, chartHeight),
                    decoration: BoxDecoration(
                      color: isActive
                        ? config.color
                        : config.color.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Value text (positioned above bar)
              if (value > 0) _buildVerticalValueText(value, config, theme, isActive, chartHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalValueText(int value, NutritionBarConfig config, ThemeData theme, bool isActive, double chartHeight) {
    final barHeight = _getBarHeight(value, config.maxValue, chartHeight);
    // Ensure the badge doesn't go above the chart area (minimum 5px from top)
    final topPosition = (chartHeight - barHeight - 25).clamp(5.0, chartHeight - 20);
    
    return Positioned(
      top: topPosition,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isActive 
            ? config.color
            : config.color.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value >= config.maxValue ? '${config.maxValue}+' : value.toString(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLeftScale(ThemeData theme) {
    return Semantics(
      label: 'Scale from 0 to 15 or more servings per day',
      excludeSemantics: true, // Hide individual scale labels from screen readers
      child: SizedBox(
        width: 40,
        child: SizedBox(
          height: 250, // Match chartHeight exactly
          child: Stack(
          alignment: Alignment.centerRight,
          children: [
            // "0" at the bottom - aligns with bar base
            Positioned(
              bottom: 0,
              right: 8,
              child: Text('0', style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
            ),
            // "5" at 5/15 of height - aligns with 5-unit bar
            Positioned(
              bottom: 83, // 250 * (5/15) = 83.3
              right: 8,
              child: Text('5', style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
            ),
            // "10" at 10/15 of height - aligns with 10-unit bar
            Positioned(
              bottom: 167, // 250 * (10/15) = 166.7
              right: 8,
              child: Text('10', style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
            ),
            // "15+" at the top - aligns with 15-unit bar
            Positioned(
              top: 0,
              right: 8,
              child: Text('15+', style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildBottomIcons(ThemeData theme) {
    return Row(
      children: [
        // Match the left scale width exactly
        SizedBox(width: 40),
        // Icons aligned with bars
        Expanded(
          child: Row(
            children: NutritionBarConfig.configs.entries.map((entry) {
              final config = entry.value;
              final isActive = config.type == widget.currentType;
              
              return Expanded(
                child: Center(
                  child: Semantics(
                    label: '${config.type}${isActive ? ", currently selected" : ""}',
                    button: !isActive,
                    hint: !isActive ? 'Tap to select ${config.type}' : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isActive
                          ? config.color.withValues(alpha: 0.1)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                            ? config.color.withValues(alpha: 0.3)
                            : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        config.icon,
                        style: TextStyle(
                          fontSize: isActive ? 32 : 28,
                        ),
                        semanticsLabel: config.type, // Screen readers will read the type, not emoji
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  double _getBarHeight(int value, int maxValue, double chartHeight) {
    // Handle edge cases that could cause BoxConstraints.lerp assertion errors
    if (maxValue <= 0 || !chartHeight.isFinite || chartHeight <= 0) {
      return 0.0;
    }
    
    // Ensure value is valid
    if (value < 0) {
      return 0.0;
    }
    
    // Calculate ratio and ensure it's valid
    final ratio = (value / maxValue).clamp(0.0, 1.0);
    if (!ratio.isFinite) {
      return 0.0;
    }
    
    // Calculate final height and ensure it's valid
    final height = chartHeight * ratio;
    if (!height.isFinite || height < 0) {
      return 0.0;
    }
    
    return height;
  }

  void _handleGraphTap(TapDownDetails details) {
    _updateValueFromGraphPosition(details.localPosition);
  }

  void _handleGraphDrag(DragUpdateDetails details) {
    _updateValueFromGraphPosition(details.localPosition);
  }

  void _updateValueFromGraphPosition(Offset position) {
    // Get the current active config
    final activeConfig = NutritionBarConfig.configs[widget.currentType];
    if (activeConfig == null) return;

    // Calculate Y position within the chart area
    const chartHeight = 250.0;
    const chartTopPadding = 25.0; // Space at top of 300px container before chart starts

    // Calculate Y position relative to the chart area (not the entire container)
    final chartY = position.dy - chartTopPadding;
    if (chartY < 0 || chartY > chartHeight) return; // Click outside chart area

    // Flip Y coordinate since we want higher values at the top
    final relativeY = (1.0 - (chartY / chartHeight)).clamp(0.0, 1.0);
    final newValue = (relativeY * activeConfig.maxValue).round().clamp(0, activeConfig.maxValue);

    widget.onValueChanged(activeConfig.type, newValue);
  }
}