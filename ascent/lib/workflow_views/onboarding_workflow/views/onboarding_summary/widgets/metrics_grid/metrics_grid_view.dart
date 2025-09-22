import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../../../models/fitness_profile_model/fitness_profile.dart';
import 'cardio_metric_card.dart';
import 'strength_metric_card.dart';
import 'heart_rate_zones_card.dart';
import 'session_commitment_card.dart';

class MetricsGridView extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const MetricsGridView({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.extent(
      maxCrossAxisExtent: 220,  // Max width 220px per card
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        CardioMetricCard(fitnessProfile: fitnessProfile),
        StrengthMetricCard(fitnessProfile: fitnessProfile),
        HeartRateZonesCard(fitnessProfile: fitnessProfile),
        SessionCommitmentCard(fitnessProfile: fitnessProfile),
      ],
    );
  }
}