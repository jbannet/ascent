import 'package:flutter/material.dart';
import '../../../models/blocks/block.dart';
import '../../../models/blocks/block_step.dart';
import '../../../models/blocks/exercise_prescription_step.dart';
import 'block_step_card_factory.dart';

class BlockView extends StatefulWidget {
  final Block block;
  final void Function(ExercisePrescriptionStep step)? onOpenExercise;

  const BlockView({super.key, required this.block, this.onOpenExercise});

  @override
  State<BlockView> createState() => _BlockViewState();
}

class _BlockViewState extends State<BlockView> {
  late PageController _pageController;
  int _currentStepIndex = 0;
  int _currentRound = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<BlockStep> get _currentRoundSteps {
    return widget.block.items;
  }

  void _nextStep() {
    if (_currentStepIndex < _currentRoundSteps.length - 1) {
      setState(() => _currentStepIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeRound();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeRound() {
    if (_currentRound < widget.block.rounds) {
      final restSeconds = widget.block.restSecBetweenRounds;
      if (restSeconds > 0) {
        _showBetweenRoundsRest(restSeconds);
      } else {
        _startNextRound();
      }
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _startNextRound() {
    setState(() {
      _currentRound++;
      _currentStepIndex = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showBetweenRoundsRest(int seconds) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: true,
      builder: (ctx) => _BetweenRoundsRestSheet(
        seconds: seconds,
        currentRound: _currentRound,
        totalRounds: widget.block.rounds,
        onComplete: () {
          Navigator.of(ctx).pop();
          _startNextRound();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estMin = (widget.block.estimateDurationSec() / 60).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.block.label ?? 'Workout Block'),
        actions: [
          if (widget.block.rounds > 1)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Round $_currentRound/${widget.block.rounds}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderInfo(context, estMin),
          _buildProgressIndicator(context),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStepIndex = index);
              },
              itemCount: _currentRoundSteps.length,
              itemBuilder: (context, index) {
                final step = _currentRoundSteps[index];
                return BlockStepCardFactory.createCard(
                  step: step,
                  onExerciseTap: step is ExercisePrescriptionStep
                      ? () => widget.onOpenExercise?.call(step)
                      : null,
                  onRestComplete: _nextStep,
                );
              },
            ),
          ),
          _buildNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, int estMin) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoChip(
            context,
            Icons.timer_outlined,
            '~$estMin min',
            theme.colorScheme.primaryContainer,
          ),
          if (widget.block.rounds > 1)
            _buildInfoChip(
              context,
              Icons.repeat,
              '${widget.block.rounds} rounds',
              theme.colorScheme.secondaryContainer,
            ),
          _buildInfoChip(
            context,
            Icons.fitness_center,
            '${_currentRoundSteps.length} steps',
            theme.colorScheme.tertiaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_currentStepIndex + 1) / _currentRoundSteps.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStepIndex + 1} of ${_currentRoundSteps.length}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    final canGoBack = _currentStepIndex > 0;
    final isLastStep = _currentStepIndex >= _currentRoundSteps.length - 1;
    final isLastRound = _currentRound >= widget.block.rounds;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (canGoBack)
            OutlinedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            )
          else
            const SizedBox(width: 100),
          const Spacer(),
          FilledButton.icon(
            onPressed: _nextStep,
            icon: Icon(isLastStep && isLastRound ? Icons.check : Icons.arrow_forward),
            label: Text(
              isLastStep
                  ? (isLastRound ? 'Complete' : 'Next Round')
                  : 'Next Step',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _BetweenRoundsRestSheet extends StatefulWidget {
  final int seconds;
  final int currentRound;
  final int totalRounds;
  final VoidCallback onComplete;

  const _BetweenRoundsRestSheet({
    required this.seconds,
    required this.currentRound,
    required this.totalRounds,
    required this.onComplete,
  });

  @override
  State<_BetweenRoundsRestSheet> createState() => _BetweenRoundsRestSheetState();
}

class _BetweenRoundsRestSheetState extends State<_BetweenRoundsRestSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    )..forward();
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Round ${widget.currentRound} Complete!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get ready for round ${widget.currentRound + 1}',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final remainingSeconds = 
                  (widget.seconds * (1 - _controller.value)).ceil();
              
              return Column(
                children: [
                  Text(
                    remainingSeconds.toString(),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: widget.onComplete,
                    child: Text('Skip Rest • Start Round ${widget.currentRound + 1}'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}