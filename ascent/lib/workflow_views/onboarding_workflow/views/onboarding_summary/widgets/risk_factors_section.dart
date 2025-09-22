import 'package:flutter/material.dart';
import '../../../../../models/fitness_profile_model/fitness_profile.dart';

class RiskFactorsSection extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const RiskFactorsSection({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
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
}