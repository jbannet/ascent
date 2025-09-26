import 'package:flutter/material.dart';
import '../../../../../models/fitness_profile_model/fitness_profile.dart';
import '../../../../../models/fitness_profile_model/fitness_profile_extraction_extensions/recommendations.dart';

class RecommendationsSection extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const RecommendationsSection({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate recommendations on-demand
    fitnessProfile.calculateRecommendations();
    final recommendations = fitnessProfile.recommendationsList ?? [];

    // Take first 3-5 recommendations (already in priority order)
    final topRecs = recommendations.take(5).toList();

    if (topRecs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your personal AI coach says...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Simple cards for each recommendation text
        for (final text in topRecs)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

}