import 'package:flutter/material.dart';
import '../../../../models/blocks/exercise_prescription_step.dart';

class ExerciseStepCard extends StatelessWidget {
  final ExercisePrescriptionStep step;
  final VoidCallback? onTapDetails;

  const ExerciseStepCard({
    super.key,
    required this.step,
    this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTime = step.mode.name == 'time';
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTapDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                step.displayName,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildPrescriptionInfo(context, isTime),
              if (step.tempo != null) ...[
                const SizedBox(height: 16),
                _buildTempoChip(context),
              ],
              if (step.cues.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildCues(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionInfo(BuildContext context, bool isTime) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetric(
                context,
                'Sets',
                step.sets.toString(),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
              ),
              _buildMetric(
                context,
                isTime ? 'Time' : 'Reps',
                isTime ? '${step.timeSecPerSet}s' : step.reps.toString(),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
              ),
              _buildMetric(
                context,
                'Rest',
                '${step.restSecBetweenSets}s',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTempoChip(BuildContext context) {
    return Chip(
      label: Text('Tempo: ${step.tempo}'),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }

  Widget _buildCues(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          'Cues',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...step.cues.map((cue) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  cue,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}