import 'package:flutter/material.dart';
import '../../../../../../theme/app_colors.dart';
import 'circular_progress_metric.dart';

class CenterMetricsRow extends StatelessWidget {
  final Animation<double> countUpAnimation;
  final Animation<double> nutritionAnimation;
  final Animation<double> sleepAnimation;

  const CenterMetricsRow({
    super.key,
    required this.countUpAnimation,
    required this.nutritionAnimation,
    required this.sleepAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: nutritionAnimation,
          builder: (context, child) {
            return CircularProgressMetric(
              progress: nutritionAnimation.value,
              icon: Icons.restaurant,
              color: AppColors.continueGreen,
              label: 'nutrition',
            );
          },
        ),
        Column(
          children: [
            AnimatedBuilder(
              animation: countUpAnimation,
              builder: (context, child) {
                return Text(
                  countUpAnimation.value.round().toString(),
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: AppColors.basePurple,
                    shadows: [
                      Shadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                );
              },
            ),
            Text(
              'min completed',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        AnimatedBuilder(
          animation: sleepAnimation,
          builder: (context, child) {
            return CircularProgressMetric(
              progress: sleepAnimation.value,
              icon: Icons.bedtime,
              color: AppColors.basePurple,
              label: 'sleep',
            );
          },
        ),
      ],
    );
  }
}