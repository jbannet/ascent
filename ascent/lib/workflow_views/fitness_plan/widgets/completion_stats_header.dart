import 'package:flutter/material.dart';
import '../../../models/fitness_plan/plan.dart';
import '../../../models/fitness_profile_model/fitness_profile.dart';
import 'plan_header/controllers/stats_animation_manager.dart';
import 'plan_header/painters/momentum_waves_painter.dart';
import 'plan_header/widgets/stats_main_content.dart';
import 'plan_header/widgets/category_allocation_section.dart';

class CompletionStatsHeader extends StatefulWidget {
  final Plan plan;
  final FitnessProfile fitnessProfile;

  const CompletionStatsHeader({
    super.key,
    required this.plan,
    required this.fitnessProfile,
  });

  @override
  State<CompletionStatsHeader> createState() => _CompletionStatsHeaderState();
}

class _CompletionStatsHeaderState extends State<CompletionStatsHeader>
    with TickerProviderStateMixin {
  late StatsAnimationManager _animationManager;

  @override
  void initState() {
    super.initState();
    final allTimeMinutes = widget.plan.planProgress.completedMinutes();
    _animationManager = StatsAnimationManager(
      tickerProvider: this,
      completedMinutes: allTimeMinutes,
    );
  }

  @override
  void dispose() {
    _animationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTimeMinutes = widget.plan.planProgress.completedMinutes();
    final trailing4WeeksMinutes = widget.plan.planProgress.completedMinutes();
    final thisWeekMinutes = widget.plan.planProgress.completedMinutes();

    return Stack(
      children: [
        // Waves in the background
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animationManager.waveController,
              builder: (context, child) {
                // Calculate progress percentage for color transitions
                final weeklyGoal = 300; // Mock weekly goal
                final progressPercent = (allTimeMinutes / weeklyGoal).clamp(0.0, 1.0);

                return CustomPaint(
                  painter: MomentumWavesPainter(
                    animationValue: _animationManager.waveController.value,
                    progressPercent: progressPercent,
                  ),
                );
              },
            ),
          ),
        ),
        // Main content on top
        Container(
          padding: const EdgeInsets.fromLTRB(24, 42, 24, 45),
          child: Column(
            children: [
              StatsMainContent(
                allTimeMinutes: allTimeMinutes,
                trailing4WeeksMinutes: trailing4WeeksMinutes,
                thisWeekMinutes: thisWeekMinutes,
                countUpAnimation: _animationManager.countUpAnimation,
                nutritionAnimation: _animationManager.nutritionAnimation,
                sleepAnimation: _animationManager.sleepAnimation,
              ),
              const SizedBox(height: 20),
              CategoryAllocationSection(
                categoryAllocations: widget.fitnessProfile.categoryAllocationsAsPercentages,
              ),
            ],
          ),
        ),
      ],
    );
  }
}