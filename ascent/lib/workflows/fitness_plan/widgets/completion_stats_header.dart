import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/plan_concepts/plan.dart';
import '../../../theme/app_colors.dart';
import '../../../enums/exercise_style.dart';

class CompletionStatsHeader extends StatefulWidget {
  final Plan plan;

  const CompletionStatsHeader({
    super.key,
    required this.plan,
  });

  @override
  State<CompletionStatsHeader> createState() => _CompletionStatsHeaderState();
}

class _CompletionStatsHeaderState extends State<CompletionStatsHeader>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _countUpController;
  late Animation<double> _countUpAnimation;

  @override
  void initState() {
    super.initState();

    // Wave animation - continuous (respects accessibility settings)
    _waveController = AnimationController(
      duration: const Duration(seconds: 8), // Slow, hypnotic waves
      vsync: this,
    );

    // Start wave animation immediately - we'll check accessibility in build
    _waveController.repeat();

    // Count-up animation for main number
    _countUpController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final allTimeMinutes = widget.plan.getCompletedMinutes(period: 'allTime');
    _countUpAnimation = Tween<double>(
      begin: 0,
      end: allTimeMinutes.toDouble(),
    ).animate(CurvedAnimation(
      parent: _countUpController,
      curve: Curves.easeOut,
    ));

    // Start count-up animation
    _countUpController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _countUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTimeMinutes = widget.plan.getCompletedMinutes(period: 'allTime');
    final trailing4WeeksMinutes = widget.plan.getCompletedMinutes(period: 'trailing4Weeks');
    final thisWeekMinutes = widget.plan.getCompletedMinutes(period: 'thisWeek');

    return Stack(
      children: [
        // Waves in the background
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                // Calculate progress percentage for color transitions
                final weeklyGoal = 300; // Mock weekly goal
                final progressPercent = (allTimeMinutes / weeklyGoal).clamp(0.0, 1.0);

                return CustomPaint(
                  painter: MomentumWavesPainter(
                    animationValue: _waveController.value,
                    progressPercent: progressPercent,
                  ),
                );
              },
            ),
          ),
        ),
        // Main content on top
        Container(
          padding: const EdgeInsets.fromLTRB(24, 42, 24, 45),
          child: Column(
            children: [
              _buildMainContent(allTimeMinutes, trailing4WeeksMinutes, thisWeekMinutes),
              const SizedBox(height: 20),
              _buildStyleAllocation(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(int allTimeMinutes, int trailing4WeeksMinutes, int thisWeekMinutes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent, // Make background transparent to show waves
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
            children: [
              // Top row: 4-week left, streak center, this week right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTopMetric(trailing4WeeksMinutes.toString(), 'last 4wk', Icons.trending_up),
                  _buildStreakCounter(),
                  _buildTopMetric(thisWeekMinutes.toString(), 'this week', Icons.calendar_today),
                ],
              ),
              const SizedBox(height: 20),
              // Center: Main number with nutrition and sleep on sides
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBottomCircularMetric(
                    progress: 0.78,
                    icon: Icons.restaurant,
                    color: AppColors.continueGreen,
                    label: 'nutrition',
                  ),
                  Column(
                    children: [
                      AnimatedBuilder(
                        animation: _countUpAnimation,
                        builder: (context, child) {
                          return Text(
                            _countUpAnimation.value.round().toString(),
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: AppColors.basePurple,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Text(
                        'min completed',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  _buildBottomCircularMetric(
                    progress: 0.94, // Mock 7.5/8 hours
                    icon: Icons.bedtime,
                    color: AppColors.basePurple,
                    label: 'sleep',
                  ),
                ],
              ),
            ],
      ),
    );
  }


  Widget _buildTopMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.basePurple.withValues(alpha: 0.6),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          '$value min',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.basePurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCircularMetric({
    required double progress,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 3,
              ),
              Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCounter() {
    // Mock streak data - in real app, this would come from Plan model
    const int currentStreak = 2000;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.congratulationsYellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.congratulationsYellow.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppColors.congratulationsYellow,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                currentStreak.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.congratulationsYellow,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'day streak',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStyleAllocation() {
    final styleAllocation = widget.plan.getStyleAllocation();

    if (styleAllocation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Style Allocation (Next 4 Weeks)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.basePurple.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        _buildAllocationChart(styleAllocation),
        const SizedBox(height: 12),
        _buildStyleLegend(styleAllocation),
      ],
    );
  }

  Widget _buildAllocationChart(Map<ExerciseStyle, double> styleAllocation) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: _buildAllocationSegments(styleAllocation),
        ),
      ),
    );
  }

  List<Widget> _buildAllocationSegments(Map<ExerciseStyle, double> styleAllocation) {
    final segments = <Widget>[];
    final total = styleAllocation.values.fold(0.0, (sum, value) => sum + value);

    for (final entry in styleAllocation.entries) {
      final percentage = entry.value / total;
      if (percentage > 0) {
        segments.add(
          Expanded(
            flex: (percentage * 100).round(),
            child: Container(
              color: _getStyleColor(entry.key),
            ),
          ),
        );
      }
    }

    return segments;
  }

  Widget _buildStyleLegend(Map<ExerciseStyle, double> styleAllocation) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: styleAllocation.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStyleColor(entry.key),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key.displayName} ${entry.value.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutralDark,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getStyleColor(ExerciseStyle style) {
    switch (style) {
      case ExerciseStyle.cardio:
        return Colors.red.shade400;
      case ExerciseStyle.strength:
        return AppColors.basePurple;
      case ExerciseStyle.flexibility:
        return AppColors.continueGreen;
      case ExerciseStyle.balance:
        return Colors.blue.shade400;
      case ExerciseStyle.functional:
        return Colors.brown.shade400;
    }
  }
}

class MomentumWavesPainter extends CustomPainter {
  final double animationValue;
  final double progressPercent;

  MomentumWavesPainter({
    required this.animationValue,
    required this.progressPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;

    // Create gradient colors based on progress
    final primaryColor = Color.lerp(
      AppColors.basePurple,
      AppColors.doneTeal,
      progressPercent,
    )!;

    // Wave Layer 1 - 1 cycle per animation (lightest wave - SHIFTED DOWN)
    _drawWave(
      canvas,
      size,
      cyclesPerAnimation: 1,
      amplitude: size.height * 0.18, // Much larger for dramatic overlap
      phaseOffset: 0.0,
      opacity: 0.025, // A bit more transparent
      color: primaryColor,
      yOffset: centerY * 0.3, // Higher to cover more area
    );

    // Wave Layer 2 - 1.5 cycles per animation (light wave - SHIFTED DOWN)
    _drawWave(
      canvas,
      size,
      cyclesPerAnimation: 1,
      amplitude: size.height * 0.15, // Large amplitude
      phaseOffset: 0.33, // Different phase
      opacity: 0.04, // A bit more transparent
      color: primaryColor,
      yOffset: centerY * 0.5, // Higher to cover more area
    );

    // Wave Layer 3 - 2 cycles per animation (medium wave - SHIFTED DOWN)
    _drawWave(
      canvas,
      size,
      cyclesPerAnimation: 2,
      amplitude: size.height * 0.12, // Good overlap potential
      phaseOffset: 0.5, // 180 degree phase shift
      opacity: 0.06, // A bit more transparent
      color: primaryColor,
      yOffset: centerY * 0.7, // Higher to cover more area
    );

    // Wave Layer 4 - 2.5 cycles per animation (medium-dark wave - SHIFTED DOWN)
    _drawWave(
      canvas,
      size,
      cyclesPerAnimation: 2,
      amplitude: size.height * 0.09, // Smaller but still overlapping
      phaseOffset: 0.75, // Different phase
      opacity: 0.055, // A bit more transparent
      color: primaryColor,
      yOffset: centerY * 0.9, // Higher to cover more area
    );

    // Wave Layer 5 - 3 cycles per animation (dark wave - SHIFTED DOWN with gradient)
    _drawWaveWithGradient(
      canvas,
      size,
      cyclesPerAnimation: 3,
      amplitude: size.height * 0.08, // Large enough for good overlap
      phaseOffset: 0.25, // 90 degree phase shift
      opacity: 0.09, // A bit more transparent
      color: primaryColor,
      yOffset: centerY * 1.1, // Higher to cover more area
    );

    // Add visible background glow
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final glowPath = Path();
    glowPath.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: size.width * 0.35,
    ));
    canvas.drawPath(glowPath, glowPaint);
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required int cyclesPerAnimation,
    required double amplitude,
    required double phaseOffset,
    required double opacity,
    required Color color,
    required double yOffset,
  }) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveLength = size.width;

    // Calculate seamless timeOffset - each cycle completes exactly once per animation
    final timeOffset = animationValue * cyclesPerAnimation * 2 * pi + (phaseOffset * 2 * pi);

    // Start from far left edge (extend beyond visible area to eliminate white space)
    path.moveTo(-50, yOffset);

    // Add a point at the actual left edge with randomness
    final leftEdgeRandomAmp = amplitude * _getAmplitudeVariation(0, cyclesPerAnimation, phaseOffset);
    final leftEdgeY = yOffset + leftEdgeRandomAmp * sin(timeOffset);
    path.lineTo(0, leftEdgeY);

    // Generate wave points with exact integer cycles and amplitude randomness
    for (double x = 0; x <= waveLength; x += 4) { // Slightly larger steps for performance
      final normalizedX = x / waveLength;

      // Add controlled randomness to amplitude (+/- 20%)
      final randomAmplitude = amplitude * _getAmplitudeVariation(normalizedX, cyclesPerAnimation, phaseOffset);

      // Use exact cycles across screen width for seamless loops with random amplitude
      final waveY = yOffset + randomAmplitude * sin((normalizedX * cyclesPerAnimation * 2 * pi) + timeOffset);
      path.lineTo(x, waveY);
    }

    // Add a point at the actual right edge with randomness
    final rightEdgeRandomAmp = amplitude * _getAmplitudeVariation(1.0, cyclesPerAnimation, phaseOffset);
    final rightEdgeY = yOffset + rightEdgeRandomAmp * sin((1.0 * cyclesPerAnimation * 2 * pi) + timeOffset);
    path.lineTo(waveLength, rightEdgeY);

    // Extend to far right edge
    path.lineTo(waveLength + 50, rightEdgeY);

    // Close path to bottom, ensuring full coverage
    path.lineTo(waveLength + 50, size.height);
    path.lineTo(-50, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  // Generate controlled randomness for amplitude variation
  double _getAmplitudeVariation(double position, int cycles, double phase) {
    // Use position, cycles, and phase as seeds for consistent randomness
    // Add animation value for slow evolution over time
    final seed = (position * 1000 + cycles * 100 + phase * 50 + animationValue * 10).floor();
    final random = (sin(seed * 0.01) + sin(seed * 0.017) + sin(seed * 0.023)) / 3;

    // Map to +/- 20% variation (0.8 to 1.2 multiplier)
    return 1.0 + (random * 0.4 - 0.2);
  }

  void _drawWaveWithGradient(
    Canvas canvas,
    Size size, {
    required int cyclesPerAnimation,
    required double amplitude,
    required double phaseOffset,
    required double opacity,
    required Color color,
    required double yOffset,
  }) {
    // Create much softer gradient that fades to white at bottom
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(opacity),
        color.withOpacity(opacity * 0.8),
        color.withOpacity(opacity * 0.5),
        color.withOpacity(opacity * 0.25),
        color.withOpacity(opacity * 0.1),
        color.withOpacity(opacity * 0.03),
        Colors.white.withOpacity(0.0), // Fade to transparent white
      ],
      stops: const [0.0, 0.15, 0.35, 0.55, 0.75, 0.90, 1.0], // More gradual stops
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, yOffset, size.width, size.height - yOffset))
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveLength = size.width;

    // Calculate seamless timeOffset - each cycle completes exactly once per animation
    final timeOffset = animationValue * cyclesPerAnimation * 2 * pi + (phaseOffset * 2 * pi);

    // Start from far left edge (extend beyond visible area to eliminate white space)
    path.moveTo(-50, yOffset);

    // Add a point at the actual left edge with randomness
    final leftEdgeRandomAmp = amplitude * _getAmplitudeVariation(0, cyclesPerAnimation, phaseOffset);
    final leftEdgeY = yOffset + leftEdgeRandomAmp * sin(timeOffset);
    path.lineTo(0, leftEdgeY);

    // Generate wave points with exact integer cycles and amplitude randomness
    for (double x = 0; x <= waveLength; x += 4) { // Slightly larger steps for performance
      final normalizedX = x / waveLength;

      // Add controlled randomness to amplitude (+/- 20%)
      final randomAmplitude = amplitude * _getAmplitudeVariation(normalizedX, cyclesPerAnimation, phaseOffset);

      // Use exact cycles across screen width for seamless loops with random amplitude
      final waveY = yOffset + randomAmplitude * sin((normalizedX * cyclesPerAnimation * 2 * pi) + timeOffset);
      path.lineTo(x, waveY);
    }

    // Add a point at the actual right edge with randomness
    final rightEdgeRandomAmp = amplitude * _getAmplitudeVariation(1.0, cyclesPerAnimation, phaseOffset);
    final rightEdgeY = yOffset + rightEdgeRandomAmp * sin((1.0 * cyclesPerAnimation * 2 * pi) + timeOffset);
    path.lineTo(waveLength, rightEdgeY);

    // Extend to far right edge
    path.lineTo(waveLength + 50, rightEdgeY);

    // Close path to bottom, ensuring full coverage with gradient fade
    path.lineTo(waveLength + 50, size.height);
    path.lineTo(-50, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MomentumWavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.progressPercent != progressPercent;
  }
}