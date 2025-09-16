import 'package:flutter/material.dart';
import '../../../models/plan_concepts/plan.dart';
import '../widgets/completion_stats_header.dart';
import '../widgets/week_card.dart';

class PlanView extends StatelessWidget {
  final Plan plan;
  const PlanView({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final next4Weeks = plan.getNext4Weeks();
    final currentWeekIndex = plan.currentWeekIndex;

    // Debug: Print actual plan data
    debugPrint('🔍 PLAN DEBUG:');
    debugPrint('Total weeks in plan: ${plan.weeks.length}');
    debugPrint('Week indices: ${plan.weeks.map((w) => w.weekIndex).toList()}');
    debugPrint('Current week index: $currentWeekIndex');
    debugPrint('Next 4 weeks found: ${next4Weeks.length}');
    debugPrint('Next 4 week indices: ${next4Weeks.map((w) => w.weekIndex).toList()}');
    debugPrint('📊 SESSION DEBUG:');
    debugPrint('Total sessions in plan: ${plan.sessions.length}');
    for (int i = 0; i < plan.sessions.length; i++) {
      final session = plan.sessions[i];
      debugPrint('Session $i: ${session.title} - Type: ${session.type.name} - Style: ${session.style.name}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Plan'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Navigate to success tracker
            },
            child: const Text('View my successes'),
          ),
        ],
      ),
      body: next4Weeks.isNotEmpty
          ? ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: next4Weeks.length + 1, // +1 for CompletionStatsHeader
              separatorBuilder: (_, index) {
                if (index == 0) return const SizedBox(height: 8); // Space after completion stats header
                return const SizedBox(height: 4); // Normal space between week cards
              },
              itemBuilder: (_, index) {
                if (index == 0) {
                  // First item is the completion stats header (now includes style allocation)
                  return CompletionStatsHeader(plan: plan);
                }

                final weekIndex = index - 1;
                final week = next4Weeks[weekIndex];
                final isCurrentWeek = week.weekIndex == currentWeekIndex;

                return WeekCard(
                  plan: plan,
                  week: week,
                  isCurrentWeek: isCurrentWeek,
                );
              },
            )
          : _buildEmptyState(context),
    );
  }


  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No upcoming weeks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your plan will appear here once weeks are scheduled.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}