import 'package:flutter/material.dart';
import '../../../theme/general_widgets/universal_progress_indicator.dart';

/// Progress bar widget for displaying onboarding completion status
class OnboardingProgressBar extends StatelessWidget {
  final String sectionName;
  final double progressPercentage;
  final int currentQuestionNumber;
  final int totalQuestionCount;
  
  const OnboardingProgressBar({
    super.key,
    required this.sectionName,
    required this.progressPercentage,
    required this.currentQuestionNumber,
    required this.totalQuestionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionName.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          UniversalProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 4),
          Text(
            'Question ${currentQuestionNumber + 1} of $totalQuestionCount',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}