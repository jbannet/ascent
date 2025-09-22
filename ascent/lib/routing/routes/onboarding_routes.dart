import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services_and_utilities/app_state/app_state.dart';
import '../../workflow_views/onboarding_workflow/views/onboarding_summary_view.dart';
import '../../workflow_views/onboarding_workflow/views/onboarding_survey_container.dart';

/// Onboarding workflow routes for the application
///
/// These routes handle the user's initial journey through the app:
/// 1. Survey collection (/onboarding) - Gather user fitness information
/// 2. Profile summary (/onboarding-summary) - Show results and generate plan
///
/// The workflow creates a FitnessProfile which is persisted to storage and
/// used to generate personalized workout plans. Users are automatically
/// redirected here from '/real' if they haven't completed onboarding.
class OnboardingRoutes {
  static List<RouteBase> routes = [
    // First step: Fitness survey to collect user information
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',

      // Shows the survey container that collects:
      // - Demographics (age, gender, weight, height)
      // - Experience level and fitness goals
      // - Preferences and constraints
      // - Equipment availability
      builder: (context, state) => const OnboardingSurveyContainer(),
    ),

    // Second step: Profile summary and plan generation
    GoRoute(
      path: '/onboarding-summary',
      name: 'onboarding_summary',

      // This route expects a FitnessProfile to exist in AppState
      // If accessed directly without completing the survey, shows error
      builder: (context, state) {
        // Watch AppState for changes (rebuilds when profile updates)
        final appState = context.watch<AppState>();
        final profile = appState.profile;

        // Safety check: ensure user has completed the survey
        // This can happen if user navigates directly to this route
        if (profile == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'No fitness profile available',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        // Show the summary view which displays:
        // - User's fitness profile breakdown
        // - Calculated fitness metrics
        // - Plan generation and preview
        // - Navigation to main app
        return OnboardingSummaryView(fitnessProfile: profile);
      },
    ),
  ];
}
