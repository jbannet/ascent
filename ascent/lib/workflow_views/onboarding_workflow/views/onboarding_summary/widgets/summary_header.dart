import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';

class SummaryHeader extends StatelessWidget {
  const SummaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Fitness Profile',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.basePurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}