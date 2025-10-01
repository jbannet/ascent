import 'package:flutter/material.dart';
import '../../../models/workout/workout.dart';
import '../../../constants_and_enums/session_type.dart';
import '../../../constants_and_enums/workout_enums/workout_style_enum.dart';
import 'workout_session_view.dart';

/// View to pick a workout style and generate a workout
class WorkoutStylePickerView extends StatefulWidget {
  const WorkoutStylePickerView({super.key});

  @override
  State<WorkoutStylePickerView> createState() => _WorkoutStylePickerViewState();
}

class _WorkoutStylePickerViewState extends State<WorkoutStylePickerView> {
  SessionType _selectedType = SessionType.micro;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Workout Style'),
      ),
      body: Column(
        children: [
          // Session type toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Length',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<SessionType>(
                      segments: const [
                        ButtonSegment(
                          value: SessionType.micro,
                          label: Text('Micro (~12 min)'),
                          icon: Icon(Icons.timer),
                        ),
                        ButtonSegment(
                          value: SessionType.full,
                          label: Text('Full (~60 min)'),
                          icon: Icon(Icons.fitness_center),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (Set<SessionType> newSelection) {
                        setState(() {
                          _selectedType = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Workout styles grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: WorkoutStyle.values.length,
              itemBuilder: (context, index) {
                final style = WorkoutStyle.values[index];
                return _buildStyleCard(context, style);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleCard(BuildContext context, WorkoutStyle style) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _isGenerating ? null : () => _selectStyle(context, style),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                style.icon,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 8),
              Text(
                _getShortName(style),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getShortName(WorkoutStyle style) {
    switch (style) {
      case WorkoutStyle.fullBody:
        return 'Full Body';
      case WorkoutStyle.upperLowerSplit:
        return 'Upper/Lower';
      case WorkoutStyle.pushPullLegs:
        return 'Push/Pull/Legs';
      case WorkoutStyle.concurrentHybrid:
        return 'Hybrid';
      case WorkoutStyle.circuitMetabolic:
        return 'Circuit';
      case WorkoutStyle.enduranceDominant:
        return 'Endurance';
      case WorkoutStyle.strongmanFunctional:
        return 'Strongman';
      case WorkoutStyle.crossfitMixed:
        return 'CrossFit';
      case WorkoutStyle.functionalMovement:
        return 'Functional';
      case WorkoutStyle.yogaFocused:
        return 'Yoga';
      case WorkoutStyle.seniorSpecific:
        return 'Senior';
      case WorkoutStyle.pilatesStyle:
        return 'Pilates';
      case WorkoutStyle.athleticConditioning:
        return 'Athletic';
    }
  }

  Future<void> _selectStyle(BuildContext context, WorkoutStyle style) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Create workout
      final workout = Workout(
        type: _selectedType,
        style: style,
      );

      // Generate blocks
      final blocks = await workout.generateBlocks();
      workout.blocks = blocks;

      // Navigate to workout session
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WorkoutSessionView(workout: workout),
          ),
        );
      }
    } catch (e) {
      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to generate workout: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
