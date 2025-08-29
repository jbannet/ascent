import 'package:go_router/go_router.dart';
import '../../onboarding_workflow/views/onboarding_survey_container.dart';

/// Onboarding workflow routes for the application
class OnboardingRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => OnboardingSurveyContainer(
        onComplete: () {
          context.go('/');
        },
      ),
    ),
  ];
}