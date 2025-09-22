import 'package:flutter/material.dart';
import 'top_metrics_row.dart';
import 'center_metrics_row.dart';

class StatsMainContent extends StatelessWidget {
  final int allTimeMinutes;
  final int trailing4WeeksMinutes;
  final int thisWeekMinutes;
  final Animation<double> countUpAnimation;
  final Animation<double> nutritionAnimation;
  final Animation<double> sleepAnimation;

  const StatsMainContent({
    super.key,
    required this.allTimeMinutes,
    required this.trailing4WeeksMinutes,
    required this.thisWeekMinutes,
    required this.countUpAnimation,
    required this.nutritionAnimation,
    required this.sleepAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent, // Make background transparent to show waves
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Top row: 4-week left, streak center, this week right
          TopMetricsRow(
            trailing4WeeksMinutes: trailing4WeeksMinutes,
            thisWeekMinutes: thisWeekMinutes,
            currentStreak: 2000, // Mock streak data - in real app, this would come from Plan model
          ),
          const SizedBox(height: 20),
          // Center: Main number with nutrition and sleep on sides
          CenterMetricsRow(
            countUpAnimation: countUpAnimation,
            nutritionAnimation: nutritionAnimation,
            sleepAnimation: sleepAnimation,
          ),
        ],
      ),
    );
  }
}