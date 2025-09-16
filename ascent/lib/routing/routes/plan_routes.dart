import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../workflow_views/fitness_plan/views/plan_view.dart';
import '../../workflow_views/fitness_plan/views/week_view.dart';
import '../../workflow_views/fitness_plan/views/day_view.dart';
import '../../workflow_views/fitness_plan/views/block_cards/block_view.dart';
import '../../models/fitness_plan/plan.dart';
import '../../enums/day_of_week.dart';
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
      routes: [
        GoRoute(
          path: ':planId/week/:weekIndex',
          name: 'week',
          builder: (context, state) {
            final weekIndex = int.parse(state.pathParameters['weekIndex']!);
            final plan = state.extra as Plan?;
            
            if (plan == null) {
              // Handle missing plan - in production would load from storage/API
              return const Center(child: Text('Plan not found'));
            }
            
            return WeekView(
              plan: plan,
              weekIndex: weekIndex,
            );
          },
          routes: [
            GoRoute(
              path: 'day/:dayName',
              name: 'day',
              builder: (context, state) {
                final weekIndex = int.parse(state.pathParameters['weekIndex']!);
                final dayName = state.pathParameters['dayName']!;
                final plan = state.extra as Plan?;
                
                if (plan == null) {
                  return const Center(child: Text('Plan not found'));
                }
                
                final dayOfWeek = DayOfWeek.values.firstWhere(
                  (d) => d.name == dayName,
                  orElse: () => DayOfWeek.mon,
                );
                
                return DayView(
                  plan: plan,
                  weekIndex: weekIndex,
                  dayOfWeek: dayOfWeek,
                );
              },
              routes: [
                GoRoute(
                  path: 'block/:blockIndex',
                  name: 'block',
                  builder: (context, state) {
                    final weekIndex = int.parse(state.pathParameters['weekIndex']!);
                    final dayName = state.pathParameters['dayName']!;
                    final blockIndex = int.parse(state.pathParameters['blockIndex']!);
                    final plan = state.extra as Plan?;
                    
                    if (plan == null) {
                      return const Center(child: Text('Plan not found'));
                    }
                    
                    final dayOfWeek = DayOfWeek.values.firstWhere(
                      (d) => d.name == dayName,
                      orElse: () => DayOfWeek.mon,
                    );
                    
                    final week = plan.weeks.firstWhere((w) => w.weekIndex == weekIndex);
                    final day = week.days.firstWhere((d) => d.dow == dayOfWeek);
                    final session = plan.sessions.firstWhere((s) => s.id == day.sessionId);
                    final block = session.blocks[blockIndex];
                    
                    return BlockView(
                      block: block,
                      onOpenExercise: (step) {
                        context.push(
                          RouteNames.exercisePath(step.exerciseId),
                          extra: step,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}