import 'package:flutter/material.dart';
import '../../../models/workout/cooldown_step.dart';
import 'countdown_timer.dart';

/// Card for cooldown steps
class CooldownCard extends StatelessWidget {
  final CooldownStep step;
  final int stepNumber;
  final int totalSteps;
  final VoidCallback onFinished;
  final VoidCallback onSkip;

  const CooldownCard({
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
                    const Icon(Icons.ac_unit, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Cooldown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
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
                color: Colors.blue,
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
                color: Colors.blue.withValues(alpha: 0.1),
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
                      backgroundColor: Colors.blue,
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
    // Generic cooldown instructions based on pattern
    switch (step.pattern.name) {
      case 'staticStretch':
        return 'Hold each stretch position. Breathe deeply and relax into the stretch. Don\'t bounce. Hold for 20-30 seconds per position.';
      case 'steadyStateCardio':
        return 'Walk or move at an easy pace. Bring your heart rate down gradually. Focus on deep, controlled breathing.';
      default:
        return 'Cool down gradually. Let your heart rate and breathing return to normal. This helps reduce muscle soreness.';
    }
  }
}
