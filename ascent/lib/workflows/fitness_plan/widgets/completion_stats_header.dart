import 'package:flutter/material.dart';
import '../../../models/plan_concepts/plan.dart';
import '../../../theme/app_colors.dart';

class CompletionStatsHeader extends StatelessWidget {
  final Plan plan;

  const CompletionStatsHeader({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final allTimeMinutes = plan.getCompletedMinutes(period: 'allTime');
    final trailing4WeeksMinutes = plan.getCompletedMinutes(period: 'trailing4Weeks');
    final thisWeekMinutes = plan.getCompletedMinutes(period: 'thisWeek');

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          _buildNewLayout(allTimeMinutes, trailing4WeeksMinutes, thisWeekMinutes),
          const SizedBox(height: 16),
          _buildSuccessTrackerButton(),
        ],
      ),
    );
  }

  Widget _buildNewLayout(int allTimeMinutes, int trailing4WeeksMinutes, int thisWeekMinutes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circle
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundCirclePainter(),
            ),
          ),
          // Main layout
          Column(
            children: [
              // Top row: 4-week left, this week right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopMetric(trailing4WeeksMinutes.toString(), 'last 4wk', Icons.trending_up),
                  _buildTopMetric(thisWeekMinutes.toString(), 'this week', Icons.calendar_today),
                ],
              ),
              const SizedBox(height: 20),
              // Center: Main number
              Text(
                allTimeMinutes.toString(),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: AppColors.basePurple,
                ),
              ),
              Text(
                'min completed',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // Bottom row: Nutrition left, Sleep right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBottomCircularMetric(
                    progress: 0.78,
                    icon: Icons.restaurant,
                    color: AppColors.continueGreen,
                    label: 'nutrition',
                  ),
                  _buildBottomCircularMetric(
                    progress: 0.94, // Mock 7.5/8 hours
                    icon: Icons.bedtime,
                    color: AppColors.basePurple,
                    label: 'sleep',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessTrackerButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to success tracker view
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Success tracker',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.basePurple.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildTopMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.basePurple.withOpacity(0.6),
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

  Widget _buildBottomCircularMetric({
    required double progress,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 3,
              ),
              Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
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

class _BackgroundCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.basePurple.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw a large circle behind the main content
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.4;

    canvas.drawCircle(center, radius, paint);

    // Add a subtle stroke
    final strokePaint = Paint()
      ..color = AppColors.basePurple.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}