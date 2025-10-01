import 'package:flutter/material.dart';
import '../../../models/workout/exercise_prescription_step.dart';
import '../../../constants_and_enums/item_mode.dart';

class ExerciseView extends StatelessWidget {
  final ExercisePrescriptionStep step;
  const ExerciseView({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final isTimeMode = step.mode == ItemMode.time;
    final primary = isTimeMode
        ? 'Sets ${step.sets} • ${step.timeSecPerSet}s each'
        : 'Sets ${step.sets} • ${step.reps} reps';
    
    return Scaffold(
      appBar: AppBar(title: Text(step.displayName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(primary, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Rest ${step.restSecBetweenSets}s • Tempo ${step.tempo ?? "—"}'),
            const SizedBox(height: 12),
            if (step.cues.isNotEmpty) Wrap(
              spacing: 8,
              children: step.cues.map((c) => Chip(label: Text(c))).toList(),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {/* open set logger or start timer */},
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start set'),
            )
          ],
        ),
      ),
    );
  }
}