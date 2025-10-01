import 'package:flutter/material.dart';
import '../../../models/workout/exercise_block.dart';
import '../../../models/workout/exercise.dart';
import '../../../services_and_utilities/exercises/load_exercises_service.dart';
import 'countdown_timer.dart';

/// Card for exercise blocks
class ExerciseCard extends StatefulWidget {
  final ExerciseBlock block;
  final int blockNumber;
  final int totalBlocks;
  final VoidCallback onFinished;
  final VoidCallback onSkip;

  const ExerciseCard({
    super.key,
    required this.block,
    required this.blockNumber,
    required this.totalBlocks,
    required this.onFinished,
    required this.onSkip,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  Exercise? _exercise;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  Future<void> _loadExercise() async {
    try {
      // Load all exercises and find the one matching this exerciseId
      final allExercises = await LoadExercisesService.loadAllExercises();
      final exercise = allExercises.firstWhere(
        (ex) => ex.id == widget.block.exerciseId || ex.name == widget.block.exerciseId,
        orElse: () => allExercises.first, // Fallback to first exercise
      );
      setState(() {
        _exercise = exercise;
        _isLoading = false;
      });
    } catch (e) {
      // If loading fails, just show without detailed instructions
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
                    const Icon(Icons.fitness_center, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Exercise',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                    ),
                  ],
                ),
                Text(
                  'Block ${widget.blockNumber} of ${widget.totalBlocks}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Exercise name
            Text(
              widget.block.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Sets and reps
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.block.sets} sets × ${widget.block.reps} reps',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Timer
            Center(
              child: CountdownTimer(
                durationSeconds: widget.block.estimateDurationSec(),
                onComplete: widget.onFinished,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            // Instructions
            if (_exercise != null && _exercise!.instructions.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Instructions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._exercise!.instructions.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.key + 1}. ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        const Text(
                          '⚠️ Watchouts:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Maintain proper form. If you feel pain (not muscle fatigue), stop immediately.',
                          style: TextStyle(
                            height: 1.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_exercise == null || _exercise!.instructions.isEmpty)
              const Spacer(),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onSkip,
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onFinished,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
