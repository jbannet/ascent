import 'package:flutter/material.dart';
import '../../../models/fitness_plan/plan.dart';
import '../widgets/completion_stats_header.dart';
import '../widgets/week_card.dart';

class PlanView extends StatelessWidget {
  final Plan plan;
  const PlanView({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final next4Weeks = plan.next4Weeks;
    final currentWeekIndex = plan.currentWeekIndex;


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
                if (index == 0) return const SizedBox(height: 0); // No space to allow overlap
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

                return Transform.translate(
                  offset: const Offset(0, -30), // Move week cards up by 30px to overlap waves
                  child: WeekCard(
                    plan: plan,
                    week: week,
                    isCurrentWeek: isCurrentWeek,
                  ),
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