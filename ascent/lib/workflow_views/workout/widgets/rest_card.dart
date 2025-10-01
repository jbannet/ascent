import 'package:flutter/material.dart';
import '../../../models/workout/rest_block.dart';
import 'countdown_timer.dart';

/// Card for rest/break blocks
class RestCard extends StatelessWidget {
  final RestBlock block;
  final int blockNumber;
  final int totalBlocks;
  final VoidCallback onFinished;
  final VoidCallback onSkip;

  const RestCard({
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pause_circle, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      'Rest',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
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

            const SizedBox(height: 40),

            // Message
            Text(
              'Take a Rest',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Timer
            Center(
              child: CountdownTimer(
                durationSeconds: block.durationSec,
                onComplete: onFinished,
                color: Colors.purple,
              ),
            ),

            const SizedBox(height: 32),

            // Rest tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Breathe deeply and let your heart rate recover. Stay hydrated.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),

            const Spacer(),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    child: const Text('Skip Rest'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onFinished,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Finish Rest'),
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
