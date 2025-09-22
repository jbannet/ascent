import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/fitness_plan/plan.dart';
import '../../services_and_utilities/app_state/app_state.dart';
import '../../workflow_views/fitness_plan/views/plan_view.dart';
import '../route_names.dart';

/// Plan-related routes for the application
///
/// This module handles the main fitness plan display route (/plan) which serves
/// as the primary interface after onboarding completion. The route accepts Plan
/// data through multiple channels (navigation extras, AppState) and provides
/// fallback handling for edge cases.
class PlanRoutes {
  static List<RouteBase> routes = [
    // Main plan display route - shows the user's personalized fitness plan
    GoRoute(
      path: RouteNames.plan, // '/plan' - defined in route_names.dart
      name: 'plan',

      // Flexible builder that can receive Plan data from multiple sources
      builder: (context, state) {
        Plan? plan;

        // Priority 1: Direct Plan object passed as navigation extra
        // Used when navigating with: context.push('/plan', extra: planObject)
        if (state.extra is Plan) {
          plan = state.extra as Plan;
        }
        // Priority 2: JSON data passed as navigation extra
        // Used when Plan is serialized/deserialized during navigation
        else if (state.extra is Map<String, dynamic>) {
          plan = Plan.fromJson(state.extra as Map<String, dynamic>);
        }
        // Priority 3: Load from global AppState
        // Used when navigating without extras (most common case)
        // Relies on previously generated/loaded plan in AppState
        else {
          plan = context.read<AppState>().plan;
        }

        // Safety check: ensure we have a plan to display
        // This can happen if user navigates directly to /plan without onboarding
        // or if plan generation failed
        if (plan == null) {
          return const Center(child: Text('No plan available'));
        }

        // Render the main plan view which shows:
        // - Weekly workout schedule
        // - Individual workout details
        // - Progress tracking
        // - Navigation to specific exercises
        return PlanView(plan: plan);
      },
    ),
  ];
}
