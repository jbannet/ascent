import 'package:flutter/material.dart';
import '../../../models/workout/workout.dart';
import '../../../models/workout/block.dart';
import '../../../models/workout/warmup_block.dart';
import '../../../models/workout/cooldown_block.dart';
import '../../../models/workout/exercise_block.dart';
import '../../../models/workout/rest_block.dart';

/// Card showing workout overview before starting
class WorkoutOverviewCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onStart;

  const WorkoutOverviewCard({
    super.key,
    required this.workout,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = workout.blocks ?? [];
    final totalDuration = _calculateTotalDuration(blocks);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    workout.style.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workout.style.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.type.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Duration Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    context,
                    Icons.timer,
                    '${(totalDuration / 60).ceil()} min',
                    'Duration',
                  ),
                  _buildInfoItem(
                    context,
                    Icons.fitness_center,
                    '${blocks.length}',
                    'Blocks',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Workout Structure
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout Structure',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...blocks.map((block) => _buildBlockPreview(context, block)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Start Button
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Start Workout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildBlockPreview(BuildContext context, Block block) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            _getBlockIcon(block),
            size: 20,
            color: _getBlockColor(block),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              block.label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${(block.estimateDurationSec() / 60).ceil()} min',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  IconData _getBlockIcon(Block block) {
    if (block is WarmupBlock) {
      return Icons.self_improvement;
    } else if (block is CooldownBlock) {
      return Icons.ac_unit;
    } else if (block is ExerciseBlock) {
      return Icons.fitness_center;
    } else if (block is RestBlock) {
      return Icons.pause_circle;
    }
    return Icons.help_outline;
  }

  Color _getBlockColor(Block block) {
    if (block is WarmupBlock) {
      return Colors.orange;
    } else if (block is CooldownBlock) {
      return Colors.blue;
    } else if (block is ExerciseBlock) {
      return Colors.red;
    } else if (block is RestBlock) {
      return Colors.purple;
    }
    return Colors.grey;
  }

  int _calculateTotalDuration(List<Block> blocks) {
    return blocks.fold(0, (sum, block) => sum + block.estimateDurationSec());
  }
}
