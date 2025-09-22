import 'package:flutter/material.dart';
import '../../models/metric_row.dart';

class BaseMetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<MetricRow>? metrics;
  final Widget? child;

  const BaseMetricCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.metrics,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child ?? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: metrics?.map((m) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  m.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  m.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            )).toList() ?? <Widget>[],
          ),
        ],
      ),
    );
  }
}