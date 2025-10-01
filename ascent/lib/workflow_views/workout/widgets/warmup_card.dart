import 'package:flutter/material.dart';
import '../../../models/workout/warmup_block.dart';
import 'countdown_timer.dart';

/// Card for warmup blocks
class WarmupCard extends StatelessWidget {
  final WarmupBlock block;
  final int blockNumber;
  final int totalBlocks;
  final VoidCallback onFinished;
  final VoidCallback onSkip;

  const WarmupCard({
    super.key,
    required this.block,
    required this.blockNumber,
    required this.totalBlocks,
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
                  'Block $blockNumber of $totalBlocks',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Timer
            Center(
              child: CountdownTimer(
                durationSeconds: block.estimateDurationSec(),
                onComplete: onFinished,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 24),

            // Pattern list
            Text(
              'Warmup Movements',
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Move through your full range of motion in a controlled manner. Start slow and gradually increase intensity.',
                    style: TextStyle(fontSize: 14, height: 1.5),
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
}
