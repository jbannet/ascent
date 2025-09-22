import 'package:flutter/material.dart';
import '../../../../../../models/fitness_profile_model/fitness_profile.dart';
import '../../../../../../theme/app_colors.dart';
import 'base_metric_card.dart';

class SessionCommitmentCard extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const SessionCommitmentCard({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
    final fullSessions = fitnessProfile.fullWorkoutsPerWeek;
    final microSessions = fitnessProfile.microWorkoutsPerWeek;
    final weeklyMinutes = fitnessProfile.features['weekly_training_minutes'] ?? 0.0;
    final trainingDays = fitnessProfile.features['total_training_days'] ?? 0.0;

    return BaseMetricCard(
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
}