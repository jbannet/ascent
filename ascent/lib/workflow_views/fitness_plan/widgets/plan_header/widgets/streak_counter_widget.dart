import 'package:flutter/material.dart';
import '../../../../../../theme/app_colors.dart';

class StreakCounterWidget extends StatelessWidget {
  final int currentStreak;

  const StreakCounterWidget({
    super.key,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.congratulationsYellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.congratulationsYellow.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppColors.congratulationsYellow,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                currentStreak.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.congratulationsYellow,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'day streak',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}