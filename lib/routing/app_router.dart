import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes/home_routes.dart';
import 'routes/onboarding_routes.dart';
import 'routes/plan_routes.dart';
import 'routes/exercise_routes.dart';

/// Main application router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      ...HomeRoutes.routes,
      ...OnboardingRoutes.routes,
      ...PlanRoutes.routes,
      ...ExerciseRoutes.routes,
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.toString() ?? 'Unknown error'),
            const SizedBox(height: 16),
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