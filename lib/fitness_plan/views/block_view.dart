import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/blocks/block.dart';
import '../models/blocks/exercise_prescription_step.dart';
import '../enums/item_mode.dart';

class BlockView extends StatefulWidget {
  final Block block;
  final void Function(ExercisePrescriptionStep step)? onOpenExercise;

  const BlockView({super.key, required this.block, this.onOpenExercise});

  @override
  State<BlockView> createState() => _BlockViewState();
}

class _BlockViewState extends State<BlockView> {
  int currentRound = 1;

  @override
  Widget build(BuildContext context) {
    final b = widget.block;
    final estMin = (b.estimateDurationSec() / 60).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Block'),
        actions: [
          if (b.rounds > 1)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: Text('Round $currentRound/${b.rounds}')),
            ),
        ],
      ),
      body: Column(
        children: [
          _HeaderChips(
            rounds: b.rounds,
            restBetweenRounds: b.restSecBetweenRounds,
            estMin: estMin,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: b.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final ex = b.items[i]; // All items are ExercisePrescriptionStep
                return _ExerciseTile(
                  step: ex,
                  onTap: () => widget.onOpenExercise?.call(ex),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: (b.rounds > 1)
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton(
                onPressed: () {
                  if (currentRound < b.rounds) {
                    setState(() => currentRound++);
                    final rest = b.restSecBetweenRounds;
                    if (rest > 0) _showRestTimer(context, rest, title: 'Between rounds');
                  } else {
                    context.pop(); // or mark block done
                  }
                },
                child: Text(currentRound < b.rounds ? 'Complete round • Next' : 'Block done'),
              ),
            )
          : null,
    );
  }

  void _showRestTimer(BuildContext context, int seconds, {String title = 'Rest'}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => _CountdownSheet(seconds: seconds, title: title),
    );
  }
}

class _HeaderChips extends StatelessWidget {
  final int rounds;
  final int restBetweenRounds;
  final int estMin;
  const _HeaderChips({required this.rounds, required this.restBetweenRounds, required this.estMin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          Chip(label: Text('~$estMin min')),
          if (rounds > 1) Chip(label: Text('$rounds rounds')),
          if (rounds > 1 && restBetweenRounds > 0) Chip(label: Text('Rest $restBetweenRounds s / round')),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ExercisePrescriptionStep step;
  final VoidCallback? onTap;
  const _ExerciseTile({required this.step, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isTimeMode = step.mode == ItemMode.time;
    final primary = isTimeMode
        ? 'Sets ${step.sets} • ${step.timeSecPerSet}s each'
        : 'Sets ${step.sets} • ${step.reps} reps';
    final secondary = 'Rest ${step.restSecBetweenSets}s'
        '${step.tempo != null ? ' • Tempo ${step.tempo}' : ''}';

    return ListTile(
      leading: const Icon(Icons.fitness_center),
      title: Text(step.displayName),
      subtitle: Text('$primary • $secondary'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _CountdownSheet extends StatefulWidget {
  final int seconds;
  final String title;
  const _CountdownSheet({required this.seconds, required this.title});

  @override
  State<_CountdownSheet> createState() => _CountdownSheetState();
}

class _CountdownSheetState extends State<_CountdownSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: Duration(seconds: widget.seconds))..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final remain = (widget.seconds * (1 - _ctrl.value)).ceil();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Text('$remain', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: _ctrl.value),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(remain > 0 ? 'Skip' : 'Done'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}