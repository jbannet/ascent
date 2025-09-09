import 'package:flutter/material.dart';

/// Configuration for each nutrition type in the slider cards
class NutritionCardConfig {
  final String type;
  final String icon;
  final String label;
  final Color color;
  final int maxValue;

  const NutritionCardConfig({
    required this.type,
    required this.icon,
    required this.label,
    required this.color,
    required this.maxValue,
  });

  static const Map<String, NutritionCardConfig> configs = {
    'treats': NutritionCardConfig(
      type: 'treats',
      icon: '🍪',
      label: 'Sweet Treats',
      color: Color(0xFFFF6F61), // Coral
      maxValue: 15,
    ),
    'sodas': NutritionCardConfig(
      type: 'sodas',
      icon: '🥤',
      label: 'Sodas & Drinks',
      color: Color(0xFFE9C46A), // Amber
      maxValue: 15,
    ),
    'grains': NutritionCardConfig(
      type: 'grains',
      icon: '🌾',
      label: 'Grain Servings',
      color: Color(0xFF29AD8F), // Teal
      maxValue: 15,
    ),
    'alcohol': NutritionCardConfig(
      type: 'alcohol',
      icon: '🍷',
      label: 'Alcohol (weekly)',
      color: Color(0xFF8A4FD3), // Purple
      maxValue: 20,
    ),
  };
}

/// Horizontal slider cards widget for nutrition tracking
/// Shows all 4 nutrition metrics as stacked cards with sliders
class HorizontalSliderCards extends StatefulWidget {
  final Map<String, int> allValues; // Current values for all nutrition types
  final String currentType; // Which type is currently active
  final Function(String type, int value) onValueChanged;

  const HorizontalSliderCards({
    super.key,
    required this.allValues,
    required this.currentType,
    required this.onValueChanged,
  });

  @override
  State<HorizontalSliderCards> createState() => _HorizontalSliderCardsState();
}

class _HorizontalSliderCardsState extends State<HorizontalSliderCards>
    with TickerProviderStateMixin {

  late AnimationController _expansionController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Start glow animation
    _glowController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(HorizontalSliderCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate expansion when active type changes
    if (oldWidget.currentType != widget.currentType) {
      _expansionController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Cards stack
        ...NutritionCardConfig.configs.entries.map((entry) {
          final config = entry.value;
          final isActive = config.type == widget.currentType;
          final value = widget.allValues[config.type] ?? 0;
          
          return _buildNutritionCard(
            config: config,
            value: value,
            isActive: isActive,
            theme: theme,
          );
        }),
      ],
    );
  }

  Widget _buildNutritionCard({
    required NutritionCardConfig config,
    required int value,
    required bool isActive,
    required ThemeData theme,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_expansionController, _glowController]),
      builder: (context, child) {
        final expansionValue = isActive ? _expansionController.value : 0.0;
        final glowValue = isActive ? _glowController.value : 0.0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isActive ? 100 + (expansionValue * 10) : 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive 
                  ? config.color.withValues(alpha: 0.5 + (glowValue * 0.3))
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive ? [
                BoxShadow(
                  color: config.color.withValues(alpha: 0.2 + (glowValue * 0.2)),
                  blurRadius: 8 + (glowValue * 4),
                  spreadRadius: 1 + (glowValue * 2),
                ),
              ] : null,
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1.0 : 0.7,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon and label
                    _buildCardHeader(config, theme, isActive),
                    
                    const SizedBox(width: 16),
                    
                    // Slider
                    Expanded(
                      child: _buildSlider(config, value, theme, isActive),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Value display
                    _buildValueDisplay(value, config, theme, isActive),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardHeader(NutritionCardConfig config, ThemeData theme, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.icon,
          style: TextStyle(
            fontSize: isActive ? 24 : 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          config.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isActive 
              ? config.color
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(NutritionCardConfig config, int value, ThemeData theme, bool isActive) {
    return GestureDetector(
      onTapDown: isActive ? (details) {
        // Calculate value from tap position
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        final relativePosition = localPosition.dx / renderBox.size.width;
        final newValue = (relativePosition * config.maxValue).clamp(0, config.maxValue).round();
        
        widget.onValueChanged(config.type, newValue);
      } : null,
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Track
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Active track
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 4,
                width: (value / config.maxValue) * 200, // Approximate slider width
                decoration: BoxDecoration(
                  color: isActive ? config.color : config.color.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Slider thumb
            Positioned(
              left: (value / config.maxValue) * 200 - 10, // Center the thumb
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isActive ? config.color : config.color.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            
            // Tick marks
            if (isActive) ..._buildTickMarks(config, theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTickMarks(NutritionCardConfig config, ThemeData theme) {
    final tickMarks = <Widget>[];
    final stepSize = 200 / config.maxValue; // Approximate slider width divided by max value
    
    for (int i = 0; i <= config.maxValue; i += 5) { // Show ticks every 5 values
      tickMarks.add(
        Positioned(
          left: i * stepSize - 1,
          child: Container(
            width: 2,
            height: 8,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    
    return tickMarks;
  }

  Widget _buildValueDisplay(int value, NutritionCardConfig config, ThemeData theme, bool isActive) {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: isActive 
          ? config.color.withValues(alpha: 0.1)
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive 
            ? config.color.withValues(alpha: 0.3)
            : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isActive 
              ? config.color
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
            fontSize: isActive ? 20 : 18,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}