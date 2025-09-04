import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/plan.dart';
import '../../models/session.dart';
import '../../models/blocks/block.dart';
import '../enums/day_of_week.dart';
import '../../../routing/route_names.dart';

class DayView extends StatelessWidget {
  final Plan plan;
  final int weekIndex;
  final DayOfWeek dayOfWeek;
  const DayView({super.key, required this.plan, required this.weekIndex, required this.dayOfWeek});

  @override
  Widget build(BuildContext context) {
    final week = plan.weeks.firstWhere((w) => w.weekIndex == weekIndex);
    final day = week.days.firstWhere((d) => d.dow == dayOfWeek);
    final session = plan.sessions.firstWhere((s) => s.id == day.sessionId);

    final estMin = _estimateSessionMinutes(session);

    return Scaffold(
      appBar: AppBar(title: Text(session.title)),
      body: ListView.builder(
        itemCount: session.blocks.length,
        itemBuilder: (_, i) {
          final b = session.blocks[i];
          final blockMin = (b.estimateDurationSec() / 60).ceil();
          return Card(
            child: ListTile(
              title: Text('Block ${i + 1}'),
              subtitle: Text('$blockMin min • ${_blockSummary(b)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(
                RouteNames.blockPath(plan.planId, weekIndex, dayOfWeek.name, i),
                extra: plan,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton(
          onPressed: () {/* start guided flow or mark complete */},
          child: Text('Start • ~$estMin min'),
        ),
      ),
    );
  }

  int _estimateSessionMinutes(Session s) =>
      (s.blocks.fold<int>(0, (sum, b) => sum + b.estimateDurationSec()) / 60).ceil();

  String _blockSummary(Block b) {
    final exCount = b.items.length; // All items are ExercisePrescriptionStep (exercises)
    final restCount = 0; // Rest is handled between sets, not as separate items
    return '$exCount exercises • $restCount rests • ${b.rounds} round(s)';
  }
}