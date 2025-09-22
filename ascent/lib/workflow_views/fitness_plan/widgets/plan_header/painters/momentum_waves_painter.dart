import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../../theme/app_colors.dart';

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
      opacity: 0.02, // More transparent
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
      opacity: 0.035, // More transparent
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
      opacity: 0.05, // More transparent
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
      opacity: 0.045, // More transparent
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
      opacity: 0.075, // More transparent
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
      ..color = color.withValues(alpha: opacity)
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
        color.withValues(alpha: opacity),
        color.withValues(alpha: opacity * 0.8),
        color.withValues(alpha: opacity * 0.5),
        color.withValues(alpha: opacity * 0.25),
        color.withValues(alpha: opacity * 0.1),
        color.withValues(alpha: opacity * 0.03),
        Colors.white.withValues(alpha: 0.0), // Fade to transparent white
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