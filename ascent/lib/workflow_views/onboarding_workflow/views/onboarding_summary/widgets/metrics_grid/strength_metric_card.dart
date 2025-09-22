import 'package:flutter/material.dart';
import '../../../../../../models/fitness_profile_model/fitness_profile.dart';
import '../../../../../../theme/app_colors.dart';
import '../../models/metric_row.dart';
import 'base_metric_card.dart';

class StrengthMetricCard extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const StrengthMetricCard({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
    final upperPercentile = fitnessProfile.features['upper_body_strength_percentile'] ?? 0.0;
    final lowerPercentile = fitnessProfile.features['lower_body_strength_percentile'] ?? 0.0;
    final repMin = fitnessProfile.features['strength_optimal_rep_range_min'] ?? 8.0;
    final repMax = fitnessProfile.features['strength_optimal_rep_range_max'] ?? 12.0;
    final recoveryHours = fitnessProfile.features['strength_recovery_hours'] ?? 48.0;

    return BaseMetricCard(
      title: 'Strength Metrics',
      icon: Icons.fitness_center,
      color: AppColors.basePurple,
      metrics: [
        MetricRow('Upper Body', '${upperPercentile.toStringAsFixed(0)}%'),
        MetricRow('Lower Body', '${lowerPercentile.toStringAsFixed(0)}%'),
        MetricRow('Rep Range', '${repMin.toInt()}-${repMax.toInt()}'),
        MetricRow('Recovery', '${recoveryHours.toInt()}h'),
      ],
    );
  }
}