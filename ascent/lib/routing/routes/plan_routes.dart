import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../workflow_views/fitness_plan/views/plan_view.dart';
import '../../models/fitness_plan/plan.dart';
import '../route_names.dart';

/// Plan-related routes for the application
class PlanRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: RouteNames.plan,
      name: 'plan',
      builder: (context, state) {
        Plan? plan;

        if (state.extra is Plan) {
          plan = state.extra as Plan;
        } else if (state.extra is Map<String, dynamic>) {
          // Handle case where extra gets serialized (happens with inspector)
          plan = Plan.fromJson(state.extra as Map<String, dynamic>);
        }

        if (plan == null) {
          // For development, create a mock plan
          // In production, would load from storage/API
          return const Center(child: Text('No plan available'));
        }

        return PlanView(plan: plan);
      },
    ),
  ];
}