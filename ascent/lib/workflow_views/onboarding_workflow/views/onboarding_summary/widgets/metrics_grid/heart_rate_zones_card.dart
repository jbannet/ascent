import 'package:flutter/material.dart';
import '../../../../../../models/fitness_profile_model/fitness_profile.dart';
import 'base_metric_card.dart';

class HeartRateZonesCard extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const HeartRateZonesCard({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
    return BaseMetricCard(
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
}