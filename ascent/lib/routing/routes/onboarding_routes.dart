import 'package:go_router/go_router.dart';

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
      builder: (context, state) => const OnboardingSummaryView(),
    ),
  ];
}
