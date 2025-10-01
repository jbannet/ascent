import 'package:flutter/material.dart';
import '../../../models/workout/workout.dart';
import '../../../models/workout/block.dart';
import '../../../models/workout/warmup_block.dart';
import '../../../models/workout/cooldown_block.dart';
import '../../../models/workout/exercise_block.dart';
import '../../../models/workout/rest_block.dart';
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
  int _currentBlockIndex = 0;
  late PageController _pageController;
  late List<Block> _allBlocks;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _allBlocks = widget.workout.blocks ?? [];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startWorkout() {
    setState(() {
      _hasStarted = true;
    });
  }

  void _completeBlock() {
    if (_currentBlockIndex < _allBlocks.length - 1) {
      setState(() {
        _currentBlockIndex++;
      });
      _pageController.animateToPage(
        _currentBlockIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeWorkout();
    }
  }

  void _skipBlock() {
    _completeBlock(); // Same as complete for now
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
      itemCount: _allBlocks.length,
      itemBuilder: (context, index) {
        final block = _allBlocks[index];
        return _buildBlockCard(block, index + 1);
      },
    );
  }

  Widget _buildBlockCard(Block block, int blockNumber) {
    if (block is WarmupBlock) {
      return WarmupCard(
        block: block,
        blockNumber: blockNumber,
        totalBlocks: _allBlocks.length,
        onFinished: _completeBlock,
        onSkip: _skipBlock,
      );
    } else if (block is CooldownBlock) {
      return CooldownCard(
        block: block,
        blockNumber: blockNumber,
        totalBlocks: _allBlocks.length,
        onFinished: _completeBlock,
        onSkip: _skipBlock,
      );
    } else if (block is RestBlock) {
      return RestCard(
        block: block,
        blockNumber: blockNumber,
        totalBlocks: _allBlocks.length,
        onFinished: _completeBlock,
        onSkip: _skipBlock,
      );
    } else if (block is ExerciseBlock) {
      return ExerciseCard(
        block: block,
        blockNumber: blockNumber,
        totalBlocks: _allBlocks.length,
        onFinished: _completeBlock,
        onSkip: _skipBlock,
      );
    }

    // Fallback
    return const Center(child: Text('Unknown block type'));
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
