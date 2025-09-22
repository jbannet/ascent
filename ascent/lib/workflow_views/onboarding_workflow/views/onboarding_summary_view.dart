import 'package:flutter/material.dart';
import '../../../models/fitness_profile_model/fitness_profile.dart';
import 'onboarding_summary/widgets/summary_header.dart';
import 'onboarding_summary/widgets/metrics_grid/metrics_grid_view.dart';
import 'onboarding_summary/widgets/category_allocation/category_allocation_view.dart';
import 'onboarding_summary/widgets/risk_factors_section.dart';
import 'onboarding_summary/widgets/summary_action_buttons.dart';

class OnboardingSummaryView extends StatelessWidget {
  final FitnessProfile fitnessProfile;

  const OnboardingSummaryView({
    super.key,
    required this.fitnessProfile,
  });

  @override
  Widget build(BuildContext context) {
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