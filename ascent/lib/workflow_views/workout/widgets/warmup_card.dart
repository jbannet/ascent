import 'package:flutter/material.dart';
import '../../../models/workout/warmup_step.dart';
import 'countdown_timer.dart';

/// Card for warmup steps
class WarmupCard extends StatelessWidget {
  final WarmupStep step;
  final int stepNumber;
  final int totalSteps;
  final VoidCallback onFinished;
  final VoidCallback onSkip;

  const WarmupCard({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    required this.onFinished,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.self_improvement, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Warmup',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                    ),
                  ],
                ),
                Text(
                  'Step $stepNumber of $totalSteps',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Timer
            Center(
              child: CountdownTimer(
                durationSeconds: step.durationSec,
                onComplete: onFinished,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 24),

            // Pattern name
            Text(
              _formatPatternName(step.pattern.name),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getInstructions(),
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onFinished,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Finished'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPatternName(String pattern) {
    // Convert camelCase to Title Case
    return pattern
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getInstructions() {
    // Generic warmup instructions based on pattern
    switch (step.pattern.name) {
      case 'dynamicStretch':
        return 'Perform dynamic stretching movements. Move through your full range of motion in a controlled manner. Examples: leg swings, arm circles, torso twists.';
      case 'mobilityDrill':
        return 'Focus on joint mobility. Move slowly and deliberately through each position. Breathe deeply and relax into each movement.';
      default:
        return 'Warm up your body gradually. Start slow and increase intensity. Focus on the movements you\'ll be doing in your workout.';
    }
  }
}
