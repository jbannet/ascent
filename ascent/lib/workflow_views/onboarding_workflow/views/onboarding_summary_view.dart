import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services_and_utilities/app_state/app_state.dart';
import 'onboarding_summary/widgets/summary_header.dart';
import 'onboarding_summary/widgets/metrics_grid/metrics_grid_view.dart';
import 'onboarding_summary/widgets/category_allocation/category_allocation_view.dart';
import 'onboarding_summary/widgets/risk_factors_section.dart';
import 'onboarding_summary/widgets/summary_action_buttons.dart';

class OnboardingSummaryView extends StatelessWidget {
  const OnboardingSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final fitnessProfile = context.watch<AppState>().profile;

    if (fitnessProfile == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No fitness profile found.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete onboarding to view your personalized summary.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const SummaryHeader(),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metrics Cards Grid
                    MetricsGridView(fitnessProfile: fitnessProfile),
                    const SizedBox(height: 24),
                    // Category Allocation
                    CategoryAllocationView(fitnessProfile: fitnessProfile),
                    const SizedBox(height: 24),
                    // Risk Factors & Priorities
                    RiskFactorsSection(fitnessProfile: fitnessProfile),
                  ],
                ),
              ),
            ),
            // Action buttons
            const SummaryActionButtons(),
          ],
        ),
      ),
    );
  }
}
