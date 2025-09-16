import 'package:flutter/material.dart';
import '../../../enums/exercise_style.dart';
import '../../../theme/app_colors.dart';

class StyleAllocationHeader extends StatelessWidget {
  final Map<ExerciseStyle, double> styleAllocation;
  final String title;

  const StyleAllocationHeader({
    super.key,
    required this.styleAllocation,
    this.title = 'Style Allocation (Next 4 Weeks)',
  });

  @override
  Widget build(BuildContext context) {
    if (styleAllocation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.basePurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildAllocationChart(),
            const SizedBox(height: 12),
            _buildStyleLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationChart() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: _buildAllocationSegments(),
        ),
      ),
    );
  }

  List<Widget> _buildAllocationSegments() {
    final segments = <Widget>[];
    final total = styleAllocation.values.fold(0.0, (sum, value) => sum + value);

    for (final entry in styleAllocation.entries) {
      final percentage = entry.value / total;
      if (percentage > 0) {
        segments.add(
          Expanded(
            flex: (percentage * 100).round(),
            child: Container(
              color: _getStyleColor(entry.key),
            ),
          ),
        );
      }
    }

    return segments;
  }

  Widget _buildStyleLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: styleAllocation.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStyleColor(entry.key),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key.displayName} ${entry.value.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getStyleColor(ExerciseStyle style) {
    switch (style) {
      case ExerciseStyle.cardio:
        return Colors.red.shade400;
      case ExerciseStyle.strength:
        return AppColors.basePurple;
      case ExerciseStyle.flexibility:
        return AppColors.continueGreen;
      case ExerciseStyle.balance:
        return Colors.blue.shade400;
      case ExerciseStyle.functional:
        return Colors.brown.shade400;
    }
  }
}