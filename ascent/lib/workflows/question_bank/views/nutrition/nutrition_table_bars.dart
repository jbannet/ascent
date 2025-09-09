import 'package:flutter/material.dart';

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
  double _tableWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTableWidth();
    });
  }

  void _updateTableWidth() {
    final RenderBox? renderBox = _tableKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _tableWidth = renderBox.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Table
        Container(
          key: _tableKey,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Nutrition bars
              ...NutritionBarConfig.configs.entries.map((entry) {
                final config = entry.value;
                final value = widget.allValues[config.type] ?? 0;
                final isActive = config.type == widget.currentType;
                
                return _buildNutritionBar(config, value, isActive, theme);
              }),
              
              // Bottom scale
              _buildBottomScale(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBar(NutritionBarConfig config, int value, bool isActive, ThemeData theme) {
    const rowHeight = 50.0;
    const iconWidth = 60.0;
    
    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          // Icon column (fixed width)
          Container(
            width: iconWidth,
            height: rowHeight,
            color: theme.colorScheme.surface,
            child: Center(
              child: Text(
                config.icon,
                style: TextStyle(
                  fontSize: isActive ? 24 : 20,
                ),
              ),
            ),
          ),
          
          // Bar area (expandable)
          Expanded(
            child: GestureDetector(
              onTapDown: isActive ? (details) => _handleTap(details, config) : null,
              onPanUpdate: isActive ? (details) => _handleDrag(details, config) : null,
              child: Container(
                height: rowHeight,
                color: Colors.transparent,
                child: Stack(
                  children: [
                    // Background bar (empty state)
                    Container(
                      height: rowHeight,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    
                    // Filled bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: rowHeight,
                      width: _getBarWidth(value, config.maxValue),
                      decoration: BoxDecoration(
                        color: isActive 
                          ? config.color
                          : config.color.withValues(alpha: 0.6),
                      ),
                    ),
                    
                    // Value text (positioned at bar end)
                    if (value > 0) _buildValueText(value, config, theme, isActive),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueText(int value, NutritionBarConfig config, ThemeData theme, bool isActive) {
    const iconWidth = 60.0;
    final barWidth = _getBarWidth(value, config.maxValue);
    final leftPosition = barWidth + 8; // 8px padding from bar end
    
    return Positioned(
      left: leftPosition,
      top: 12, // Center vertically in 50px row
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

  Widget _buildBottomScale(ThemeData theme) {
    const iconWidth = 60.0;
    
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          // Empty space for icon column
          SizedBox(width: iconWidth),
          
          // Scale markers
          Expanded(
            child: Stack(
              children: [
                // Scale line
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                
                // Scale numbers
                ..._buildScaleMarkers(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScaleMarkers(ThemeData theme) {
    if (_tableWidth == 0) return [];
    
    const iconWidth = 60.0;
    final barAreaWidth = _tableWidth - iconWidth;
    final markers = <Widget>[];
    
    final scaleValues = [0, 5, 10, 15];
    
    for (final value in scaleValues) {
      final position = (value / 15) * barAreaWidth;
      
      markers.add(
        Positioned(
          left: position - 10, // Center the text
          top: 0,
          child: Container(
            width: 20,
            alignment: Alignment.center,
            child: Text(
              value == 15 ? '15+' : value.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ),
        ),
      );
      
      // Add tick mark
      markers.add(
        Positioned(
          left: position - 0.5,
          top: 8,
          child: Container(
            width: 1,
            height: 6,
            color: theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
      );
    }
    
    return markers;
  }

  double _getBarWidth(int value, int maxValue) {
    if (_tableWidth == 0) return 0;
    
    const iconWidth = 60.0;
    final barAreaWidth = _tableWidth - iconWidth;
    final ratio = (value / maxValue).clamp(0.0, 1.0);
    
    return barAreaWidth * ratio;
  }

  void _handleTap(TapDownDetails details, NutritionBarConfig config) {
    _updateValueFromPosition(details.localPosition.dx, config);
  }

  void _handleDrag(DragUpdateDetails details, NutritionBarConfig config) {
    _updateValueFromPosition(details.localPosition.dx, config);
  }

  void _updateValueFromPosition(double x, NutritionBarConfig config) {
    if (_tableWidth == 0) return;
    
    const iconWidth = 60.0;
    final barAreaWidth = _tableWidth - iconWidth;
    final relativeX = (x / barAreaWidth).clamp(0.0, 1.0);
    final newValue = (relativeX * config.maxValue).round().clamp(0, config.maxValue);
    
    widget.onValueChanged(config.type, newValue);
  }
}