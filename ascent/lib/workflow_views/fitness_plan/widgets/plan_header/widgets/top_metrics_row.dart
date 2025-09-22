import 'package:flutter/material.dart';
import '../../../../../../theme/app_colors.dart';
import 'streak_counter_widget.dart';

class TopMetricsRow extends StatelessWidget {
  final int trailing4WeeksMinutes;
  final int thisWeekMinutes;
  final int currentStreak;

  const TopMetricsRow({
    super.key,
    required this.trailing4WeeksMinutes,
    required this.thisWeekMinutes,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTopMetric(trailing4WeeksMinutes.toString(), 'last 4wk', Icons.trending_up),
        StreakCounterWidget(currentStreak: currentStreak),
        _buildTopMetric(thisWeekMinutes.toString(), 'this week', Icons.calendar_today),
      ],
    );
  }

  Widget _buildTopMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.basePurple.withValues(alpha: 0.6),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          '$value min',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.basePurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}