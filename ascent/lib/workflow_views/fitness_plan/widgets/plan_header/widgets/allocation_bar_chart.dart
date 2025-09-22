import 'package:flutter/material.dart';
import '../../../../../../constants_and_enums/category_enum.dart';
import '../../../../../../theme/app_colors.dart';
import '../models/allocation_bar_constants.dart';

class AllocationBarChart extends StatelessWidget {
  final Map<Category, double> categoryAllocations;

  const AllocationBarChart({
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
        _buildAllocationChart(),
        const SizedBox(height: 12),
        _buildStyleLegend(context),
      ],
    );
  }

  Widget _buildAllocationChart() {
    return Container(
      height: AllocationBarConstants.barHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AllocationBarConstants.barBorderRadius),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AllocationBarConstants.barBorderRadius),
        child: Row(
          children: _buildAllocationSegments(),
        ),
      ),
    );
  }

  List<Widget> _buildAllocationSegments() {
    final segments = <Widget>[];
    final total = categoryAllocations.values.fold(0.0, (sum, value) => sum + value);

    for (final entry in categoryAllocations.entries) {
      final percentage = entry.value / total;
      if (percentage > 0) {
        segments.add(
          Expanded(
            flex: (percentage * 100).round(),
            child: Container(
              color: entry.key.color,
            ),
          ),
        );
      }
    }

    return segments;
  }

  Widget _buildStyleLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryAllocations.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.key.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key.displayName} ${entry.value.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.neutralDark,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}