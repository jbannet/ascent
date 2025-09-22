import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/fitness_profile_model/fitness_profile.dart';
import '../../../services_and_utilities/app_state/app_state.dart';
import '../../../theme/general_widgets/buttons/universal_elevated_button.dart';
import '../../../theme/general_widgets/buttons/universal_outlined_button.dart';
import '../../../constants_and_enums/category_enum.dart';
import '../../../theme/app_colors.dart';
import '../../fitness_plan/widgets/completion_stats_header.dart';

class OnboardingSummaryView extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const OnboardingSummaryView({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metrics Cards Grid
                    _buildMetricsGrid(context),
                    const SizedBox(height: 24),
                    // Category Allocation
                    _buildCategoryAllocation(context),
                    const SizedBox(height: 24),
                    // Risk Factors & Priorities
                    _buildRiskFactorsAndPriorities(),
                  ],
                ),
              ),
            ),
            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Fitness Profile',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.basePurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return StaggeredGrid.extent(
      maxCrossAxisExtent: 220,  // Max width 220px per card
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildCardioCard(context),
        _buildStrengthCard(context),
        _buildHeartRateZonesCard(context),
        _buildSessionCommitmentCard(context),
      ],
    );
  }

  Widget _buildCardioCard(BuildContext context) {
    final vo2max = fitnessProfile.features['vo2max'] ?? 0.0;
    final metsCapacity = fitnessProfile.features['mets_capacity'] ?? 0.0;
    final cardioPercentile = fitnessProfile.features['cardio_fitness_percentile'] ?? 0.0;
    final recoveryDays = fitnessProfile.features['cardio_recovery_days'] ?? 0.0;

    return _buildMetricCard(context,
      title: 'Cardio Fitness',
      icon: Icons.directions_run,
      color: AppColors.doneTeal,
      metrics: [
        _MetricRow('VO2 Max', '${vo2max.toStringAsFixed(1)} ml/kg/min'),
        _MetricRow('METs', metsCapacity.toStringAsFixed(1)),
        _MetricRow('Percentile', '${cardioPercentile.toStringAsFixed(0)}%'),
        _MetricRow('Recovery', '${recoveryDays.toStringAsFixed(0)} days'),
      ],
    );
  }

  Widget _buildStrengthCard(BuildContext context) {
    final upperPercentile = fitnessProfile.features['upper_body_strength_percentile'] ?? 0.0;
    final lowerPercentile = fitnessProfile.features['lower_body_strength_percentile'] ?? 0.0;
    final repMin = fitnessProfile.features['strength_optimal_rep_range_min'] ?? 8.0;
    final repMax = fitnessProfile.features['strength_optimal_rep_range_max'] ?? 12.0;
    final recoveryHours = fitnessProfile.features['strength_recovery_hours'] ?? 48.0;

    return _buildMetricCard(context,
      title: 'Strength Metrics',
      icon: Icons.fitness_center,
      color: AppColors.basePurple,
      metrics: [
        _MetricRow('Upper Body', '${upperPercentile.toStringAsFixed(0)}%'),
        _MetricRow('Lower Body', '${lowerPercentile.toStringAsFixed(0)}%'),
        _MetricRow('Rep Range', '${repMin.toInt()}-${repMax.toInt()}'),
        _MetricRow('Recovery', '${recoveryHours.toInt()}h'),
      ],
    );
  }

  Widget _buildHeartRateZonesCard(BuildContext context) {
    return _buildMetricCard(context,
      title: 'Heart Rate Zones',
      icon: Icons.favorite_border,
      color: Colors.red,
      child: Column(
        children: [
          _buildHRZone('Zone 1', fitnessProfile.features['hr_zone1'] ?? 0.0, Colors.blue),
          _buildHRZone('Zone 2', fitnessProfile.features['hr_zone2'] ?? 0.0, Colors.green),
          _buildHRZone('Zone 3', fitnessProfile.features['hr_zone3'] ?? 0.0, Colors.yellow),
          _buildHRZone('Zone 4', fitnessProfile.features['hr_zone4'] ?? 0.0, Colors.orange),
          _buildHRZone('Zone 5', fitnessProfile.features['hr_zone5'] ?? 0.0, Colors.red),
        ],
      ),
    );
  }

  Widget _buildHRZone(String label, double bpm, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Text(
            '${bpm.toInt()} bpm',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCommitmentCard(BuildContext context) {
    final fullSessions = fitnessProfile.fullWorkoutsPerWeek;
    final microSessions = fitnessProfile.microWorkoutsPerWeek;
    final weeklyMinutes = fitnessProfile.features['weekly_training_minutes'] ?? 0.0;
    final trainingDays = fitnessProfile.features['total_training_days'] ?? 0.0;

    return _buildMetricCard(context,
      title: 'Weekly Commitment',
      icon: Icons.calendar_month,
      color: AppColors.continueGreen,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBigNumber(fullSessions, 'Full'),
              _buildBigNumber(microSessions, 'Micro'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minutes/Week',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                weeklyMinutes.toInt().toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Training Days',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                trainingDays.toInt().toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigNumber(int number, String label) {
    return Column(
      children: [
        Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.basePurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    List<_MetricRow>? metrics,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child ?? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: metrics?.map((m) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  m.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  m.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            )).toList() ?? <Widget>[],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAllocation(BuildContext context) {
    final allocations = fitnessProfile.categoryAllocationsAsPercentages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended plan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: AllocationBarConstants.barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AllocationBarConstants.barBorderRadius),
            color: Colors.grey.shade200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AllocationBarConstants.barBorderRadius),
            child: Row(
              children: _buildAllocationSegments(allocations),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildAllocationLegend(context, allocations),
      ],
    );
  }

  List<Widget> _buildAllocationSegments(Map<Category, double> allocations) {
    final segments = <Widget>[];
    final total = allocations.values.fold(0.0, (sum, value) => sum + value);

    if (total == 0) return [Container()];

    for (final entry in allocations.entries) {
      final percentage = entry.value / total;
      if (percentage > 0) {
        segments.add(
          Expanded(
            flex: (percentage * 100).round(),
            child: Container(
              color: entry.key.color,
            ),
          ),
        );
      }
    }

    return segments;
  }

  Widget _buildAllocationLegend(BuildContext context, Map<Category, double> allocations) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: allocations.entries.where((e) => e.value > 0).map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.key.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key.displayName} ${entry.value.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRiskFactorsAndPriorities() {
    final fallRisk = fitnessProfile.features['fall_risk_score'] ?? 0.0;
    final jointHealth = fitnessProfile.features['joint_health_score'] ?? 0.0;
    final impactTolerance = fitnessProfile.features['impact_tolerance'] ?? 0.0;

    // Only show if there are notable risk factors
    if (fallRisk == 0 && jointHealth >= 8 && impactTolerance >= 8) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Considerations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            children: [
              if (fallRisk > 0)
                _buildConsiderationRow(Icons.warning, 'Fall Risk Score: ${fallRisk.toInt()}'),
              if (jointHealth < 8)
                _buildConsiderationRow(Icons.accessibility_new, 'Joint Health: ${jointHealth.toInt()}/10'),
              if (impactTolerance < 8)
                _buildConsiderationRow(Icons.fitness_center, 'Low Impact Recommended'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsiderationRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: UniversalOutlinedButton(
              onPressed: () {
                // Navigate back to onboarding
                context.go('/onboarding');
              },
              child: const Text('Edit'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: UniversalElevatedButton(
              onPressed: () async {
                final appState = context.read<AppState>();
                await appState.generatePlan();
                if (!context.mounted) return;
                context.go('/plan');
              },
              child: const Text('Generate my plan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow {
  final String label;
  final String value;

  const _MetricRow(this.label, this.value);
}
