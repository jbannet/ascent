import 'package:flutter/material.dart';
import '../../../../../constants_and_enums/workout_enums/category_to_style_enum.dart';
import '../../../../../../theme/app_colors.dart';
import 'allocation_bar_chart.dart';

class CategoryAllocationSection extends StatelessWidget {
  final Map<Category, double> categoryAllocations;

  const CategoryAllocationSection({
    super.key,
    required this.categoryAllocations,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryAllocations.isEmpty || categoryAllocations.values.every((v) => v == 0)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next 4 weeks',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.basePurple.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        AllocationBarChart(categoryAllocations: categoryAllocations),
      ],
    );
  }
}