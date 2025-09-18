import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/fitness_plan/plan.dart';
import '../../../models/fitness_plan/week_of_workouts.dart';
import '../../../enums/session_type.dart';
import '../../../theme/app_colors.dart';
import '../../../routing/route_names.dart';
import 'session_icon.dart';

class WeekCard extends StatelessWidget {
  final Plan plan;
  final WeekOfWorkouts week;
  final bool isCurrentWeek;

  const WeekCard({
    super.key,
    required this.plan,
    required this.week,
    this.isCurrentWeek = false,
  });

  @override
  Widget build(BuildContext context) {
    final completionStats = plan.getCurrentWeekCompletionStats(week.weekIndex);
    final completedCount = completionStats['completed'] ?? 0;
    final totalCount = completionStats['total'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isCurrentWeek ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentWeek
            ? BorderSide(
                color: AppColors.basePurple.withValues(alpha: 0.3),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: Container(
        decoration: isCurrentWeek
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.basePurple.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              )
            : null,
        child: InkWell(
          onTap: () => context.push(
            RouteNames.weekPath(week.weekIndex),
            extra: plan,
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, completedCount, totalCount),
                const SizedBox(height: 12),
                _buildSessionIcons(context),
                if (isCurrentWeek && completedCount > 0) ...[
                  const SizedBox(height: 8),
                  _buildProgressBar(completedCount, totalCount),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int completed, int total) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentWeek ? AppColors.basePurple : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getWeekLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCurrentWeek ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
        const Spacer(),
        if (isCurrentWeek && completed > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.doneTeal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$completed/$total',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right,
          color: isCurrentWeek ? AppColors.basePurple : Colors.grey.shade400,
          size: 20,
        ),
      ],
    );
  }

  String _getWeekLabel() {
    if (isCurrentWeek) {
      return 'This Week';
    }

    final sundayDate = week.startDate;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[sundayDate.month - 1]} ${sundayDate.day}';
  }

  Widget _buildSessionIcons(BuildContext context) {
    // Separate completed and incomplete workouts
    final completedWorkouts = <Widget>[];
    final incompleteWorkouts = <Widget>[];

    for (final workout in week.workouts) {
      final isCompleted = workout.isCompleted;

      final workoutWidget = Stack(
        children: [
          Opacity(
            opacity: isCompleted ? 1.0 : 0.6,
            child: SessionIcon(
              type: workout.type,
              style: workout.style,
              size: 64,
              showBadge: false,
            ),
          ),
          if (isCompleted)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.doneTeal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.check,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      );

      if (isCompleted) {
        completedWorkouts.add(workoutWidget);
      } else {
        incompleteWorkouts.add(workoutWidget);
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...completedWorkouts,  // Completed workouts first (left side)
        ...incompleteWorkouts, // Then incomplete workouts
      ],
    );
  }

  Widget _buildProgressBar(int completed, int total) {
    final progress = completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.doneTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.doneTeal),
          minHeight: 4,
        ),
      ],
    );
  }
}