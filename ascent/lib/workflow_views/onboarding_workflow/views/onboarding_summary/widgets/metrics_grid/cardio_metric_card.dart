import 'package:flutter/material.dart';
import '../../../../../../models/fitness_profile_model/fitness_profile.dart';
import '../../../../../../theme/app_colors.dart';
import '../../models/metric_row.dart';
import 'base_metric_card.dart';

class CardioMetricCard extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const CardioMetricCard({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
    final vo2max = fitnessProfile.features['vo2max'] ?? 0.0;
    final metsCapacity = fitnessProfile.features['mets_capacity'] ?? 0.0;
    final cardioPercentile = fitnessProfile.features['cardio_fitness_percentile'] ?? 0.0;
    final recoveryDays = fitnessProfile.features['cardio_recovery_days'] ?? 0.0;

    return BaseMetricCard(
      title: 'Cardio Fitness',
      icon: Icons.directions_run,
      color: AppColors.doneTeal,
      metrics: [
        MetricRow('VO2 Max', '${vo2max.toStringAsFixed(1)} ml/kg/min'),
        MetricRow('METs', metsCapacity.toStringAsFixed(1)),
        MetricRow('Percentile', '${cardioPercentile.toStringAsFixed(0)}%'),
        MetricRow('Recovery', '${recoveryDays.toStringAsFixed(0)} days'),
      ],
    );
  }
}