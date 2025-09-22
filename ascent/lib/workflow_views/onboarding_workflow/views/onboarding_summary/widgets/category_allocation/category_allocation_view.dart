import 'package:flutter/material.dart';
import '../../../../../../models/fitness_profile_model/fitness_profile.dart';
import '../../../../../fitness_plan/widgets/plan_header/widgets/allocation_bar_chart.dart';

class CategoryAllocationView extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const CategoryAllocationView({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
    final allocations = fitnessProfile.categoryAllocationsAsPercentages;

    if (allocations.isEmpty || allocations.values.every((v) => v == 0)) {
      return const SizedBox.shrink();
    }

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
        AllocationBarChart(categoryAllocations: allocations),
      ],
    );
  }
}