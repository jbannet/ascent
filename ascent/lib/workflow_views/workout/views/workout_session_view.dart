import 'package:flutter/material.dart';
import '../../../models/workout/workout.dart';
import '../../../models/workout/block.dart';
import '../../../models/workout/block_step.dart';
import '../../../models/workout/warmup_step.dart';
import '../../../models/workout/cooldown_step.dart';
import '../../../models/workout/exercise_prescription_step.dart';
import '../../../models/workout/rest_step.dart';
import '../widgets/workout_overview_card.dart';
import '../widgets/warmup_card.dart';
import '../widgets/cooldown_card.dart';
import '../widgets/exercise_card.dart';
import '../widgets/rest_card.dart';

/// Main view for executing a workout session
class WorkoutSessionView extends StatefulWidget {
  final Workout workout;

  const WorkoutSessionView({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutSessionView> createState() => _WorkoutSessionViewState();
}

class _WorkoutSessionViewState extends State<WorkoutSessionView> {
  bool _hasStarted = false;
  int _currentStepIndex = 0;
  late PageController _pageController;
  late List<BlockStep> _allSteps;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _allSteps = _flattenSteps();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Flatten all steps from all blocks into a single list
  List<BlockStep> _flattenSteps() {
    final steps = <BlockStep>[];
    if (widget.workout.blocks != null) {
      for (final block in widget.workout.blocks!) {
        steps.addAll(block.items);
      }
    }
    return steps;
  }

  /// Get the block that contains the current step
  Block _getBlockForStep(int stepIndex) {
    if (widget.workout.blocks == null) {
      throw StateError('No blocks in workout');
    }

    int stepCount = 0;
    for (final block in widget.workout.blocks!) {
      stepCount += block.items.length;
      if (stepIndex < stepCount) {
        return block;
      }
    }

    throw RangeError('Step index out of range');
  }

  void _startWorkout() {
    setState(() {
      _hasStarted = true;
    });
  }

  void _completeStep() {
    if (_currentStepIndex < _allSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _pageController.animateToPage(
        _currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeWorkout();
    }
  }

  void _skipStep() {
    _completeStep(); // Same as complete for now
  }

  void _completeWorkout() {
    widget.workout.markCompleted();
    setState(() {}); // Trigger rebuild to show completion screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.workout.style.displayName} Workout'),
        actions: [
          if (_hasStarted && !widget.workout.isCompleted)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitDialog(context),
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasStarted) {
      return WorkoutOverviewCard(
        workout: widget.workout,
        onStart: _startWorkout,
      );
    }

    if (widget.workout.isCompleted) {
      return _buildCompletionScreen();
    }

    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Disable manual swiping
      itemCount: _allSteps.length,
      itemBuilder: (context, index) {
        final step = _allSteps[index];
        final block = _getBlockForStep(index);

        return _buildStepCard(step, block, index + 1);
      },
    );
  }

  Widget _buildStepCard(BlockStep step, Block block, int stepNumber) {
    if (step is WarmupStep) {
      return WarmupCard(
        step: step,
        stepNumber: stepNumber,
        totalSteps: _allSteps.length,
        onFinished: _completeStep,
        onSkip: _skipStep,
      );
    } else if (step is CooldownStep) {
      return CooldownCard(
        step: step,
        stepNumber: stepNumber,
        totalSteps: _allSteps.length,
        onFinished: _completeStep,
        onSkip: _skipStep,
      );
    } else if (step is RestStep) {
      return RestCard(
        step: step,
        stepNumber: stepNumber,
        totalSteps: _allSteps.length,
        onFinished: _completeStep,
        onSkip: _skipStep,
      );
    } else if (step is ExercisePrescriptionStep) {
      return ExerciseCard(
        step: step,
        stepNumber: stepNumber,
        totalSteps: _allSteps.length,
        onFinished: _completeStep,
        onSkip: _skipStep,
      );
    }

    // Fallback
    return const Center(child: Text('Unknown step type'));
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Workout Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Great job completing your ${widget.workout.style.displayName} workout!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Done', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Workout?'),
        content: const Text(
          'Are you sure you want to exit this workout? Your progress will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit workout
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
