import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Diet quality visualization chart that builds progressively during nutrition onboarding.
/// 
/// Features:
/// - 4 animated bars representing different nutrition metrics
/// - Positive, non-judgmental scoring system
/// - Sleeping kettlebell mascot for encouragement
/// - Material Design styling with purple/teal accents
/// - Mobile-optimized layout
class DietQualityChart extends StatefulWidget {
  final Map<String, int?> nutritionData;
  final List<String> activeMetrics;
  final String? currentQuestionId;
  final bool showMascot;
  final String? encouragementMessage;

  const DietQualityChart({
    super.key,
    required this.nutritionData,
    this.activeMetrics = const [],
    this.currentQuestionId,
    this.showMascot = true,
    this.encouragementMessage,
  });

  @override
  State<DietQualityChart> createState() => _DietQualityChartState();
}

class _DietQualityChartState extends State<DietQualityChart>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _barController;
  late Animation<double> _chartAnimation;
  late Animation<double> _barAnimation;

  // Chart configuration
  static const double chartHeight = 200.0;
  static const double barWidth = 40.0;
  
  // Nutrition metrics configuration
  static const List<DietMetric> metrics = [
    DietMetric(
      id: 'sugary_treats',
      label: 'Sweet Treats',
      icon: '🍪',
      color: Color(0xFFFF6F61), // restGoalCoral
      maxValue: 10,
      healthyRange: [0, 2], // 0-2 treats per day is ideal
    ),
    DietMetric(
      id: 'sodas',
      label: 'Sodas',
      icon: '🥤',
      color: Color(0xFFE9C46A), // congratulationsYellow
      maxValue: 10,
      healthyRange: [0, 1], // 0-1 soda per day is ideal
    ),
    DietMetric(
      id: 'grains',
      label: 'Grains',
      icon: '🌾',
      color: Color(0xFF29AD8F), // continueGreen
      maxValue: 10,
      healthyRange: [3, 8], // 3-8 servings per day is ideal
    ),
    DietMetric(
      id: 'alcohol',
      label: 'Alcohol',
      icon: '🍷',
      color: Color(0xFF8A4FD3), // basePurple
      maxValue: 20, // weekly servings
      healthyRange: [0, 7], // 0-7 drinks per week
      unit: 'weekly',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _barController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );

    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.elasticOut,
    );

    // Start initial animation
    _chartController.forward();
  }

  @override
  void didUpdateWidget(DietQualityChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate new bars when metrics are added
    if (widget.activeMetrics.length > oldWidget.activeMetrics.length) {
      _barController.reset();
      _barController.forward();
    }
  }

  @override
  void dispose() {
    _chartController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(theme),
              const SizedBox(height: 20),
              _buildChart(theme),
              if (widget.showMascot) ...[
                const SizedBox(height: 20),
                _buildMascotSection(theme),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final completedMetrics = widget.activeMetrics.length;
    final totalMetrics = metrics.length;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Nutrition Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Building your dietary picture...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$completedMetrics/$totalMetrics',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(ThemeData theme) {
    return SizedBox(
      height: chartHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: metrics.map((metric) => _buildBar(metric, theme)).toList(),
      ),
    );
  }

  Widget _buildBar(DietMetric metric, ThemeData theme) {
    final isActive = widget.activeMetrics.contains(metric.id);
    final value = widget.nutritionData[metric.id];
    final isCurrentQuestion = widget.currentQuestionId == metric.id;
    
    // Calculate bar height based on value and healthy range
    double barHeight = 0;
    Color barColor = metric.color.withValues(alpha: 0.3);
    
    if (isActive && value != null) {
      final normalizedValue = (value / metric.maxValue).clamp(0.0, 1.0);
      barHeight = normalizedValue * (chartHeight - 60); // Leave space for labels
      
      // Color based on whether value is in healthy range
      if (value >= metric.healthyRange[0] && value <= metric.healthyRange[1]) {
        barColor = metric.color; // Healthy - full color
      } else {
        barColor = metric.color.withValues(alpha: 0.7); // Less healthy - muted
      }
    }

    return AnimatedBuilder(
      animation: isCurrentQuestion ? _barAnimation : _chartAnimation,
      builder: (context, child) {
        final animationValue = isCurrentQuestion ? _barAnimation.value : _chartAnimation.value;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Value indicator
            if (isActive && value != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  metric.unit == 'weekly' ? '$value/week' : '$value/day',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            
            // Bar
            Transform.scale(
              scaleY: animationValue,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: barWidth,
                height: math.max(barHeight, isActive ? 20 : 10),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(8),
                  gradient: isActive 
                    ? LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          barColor,
                          barColor.withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Icon and label
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive 
                      ? barColor.withValues(alpha: 0.1)
                      : theme.colorScheme.outline.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      metric.icon,
                      style: TextStyle(
                        fontSize: 16,
                        color: isActive ? null : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isActive 
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMascotSection(ThemeData theme) {
    return Row(
      children: [
        // Sleeping kettlebell mascot
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '🏋️‍♀️',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.encouragementMessage ?? _getEncouragementMessage(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getEncouragementMessage() {
    final completedMetrics = widget.activeMetrics.length;
    final totalMetrics = metrics.length;
    
    if (completedMetrics == 0) {
      return "Let's build your nutrition profile together! 💪";
    } else if (completedMetrics < totalMetrics) {
      return "Great progress! Keep going to complete your profile. 🌟";
    } else {
      return "Amazing! Your nutrition profile is complete. Ready to optimize! 🎉";
    }
  }
}

/// Configuration data for each diet metric
class DietMetric {
  final String id;
  final String label;
  final String icon;
  final Color color;
  final int maxValue;
  final List<int> healthyRange;
  final String? unit;

  const DietMetric({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.maxValue,
    required this.healthyRange,
    this.unit,
  });
}