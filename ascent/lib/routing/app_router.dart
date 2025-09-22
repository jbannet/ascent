import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services_and_utilities/app_state/app_state.dart';
import 'routes/exercise_routes.dart';
import 'routes/home_routes.dart';
import 'routes/onboarding_routes.dart';
import 'routes/plan_routes.dart';

/// Main application router configuration using GoRouter
///
/// This is the central routing hub that combines all route modules and provides
/// state-driven navigation logic for the fitness app. The router handles:
/// - Module-based route organization (home, onboarding, plan, exercise)
/// - Smart redirects based on user's app state (profile/plan existence)
/// - Error handling for invalid routes
/// - Development vs production navigation flows
class AppRouter {
  static final GoRouter router = GoRouter(
    // Start users at the root path ('/')
    // The actual association to TemporaryNavigatorView happens in home_routes.dart
    initialLocation: '/',

    // Enable debug logging for route transitions during development
    debugLogDiagnostics: true,

    routes: [
      // Combine all route modules using spread operator
      // Each module defines routes for a specific feature area
      ...HomeRoutes.routes,        // Root path and development navigation
      ...OnboardingRoutes.routes,  // User profile creation workflow
      ...PlanRoutes.routes,        // Fitness plan display and interaction
      ...ExerciseRoutes.routes,    // Individual exercise views

      // Special route that provides intelligent navigation based on app state
      // This is the main entry point for production app flow
      GoRoute(
        path: '/real',

        // Redirect logic based on what data the user has saved
        redirect: (context, state) {
          // Get current app state to check user's progress
          final appState = context.read<AppState>();

          // User hasn't completed onboarding yet - send to survey
          if (!appState.hasProfile) {
            return '/onboarding';
          }

          // User has profile but no generated plan - send to summary/plan generation
          if (!appState.hasPlan) {
            return '/onboarding-summary';
          }

          // User has both profile and plan - send to main app
          return '/plan';
        },

        // This builder never actually renders since we always redirect
        // Required by GoRouter but returns empty widget
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],

    // Custom error page shown when user navigates to invalid route
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),

            // Error title
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // Error details (if available)
            Text(state.error?.toString() ?? 'Unknown error'),
            const SizedBox(height: 16),

            // Button to return to home page
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
