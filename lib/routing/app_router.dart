import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../onboarding_workflow/views/onboarding_survey_container.dart';
import '../fitness_plan/views/plan_view.dart';
import '../fitness_plan/views/week_view.dart';
import '../fitness_plan/views/day_view.dart';
import '../fitness_plan/views/block_view.dart';
import '../fitness_plan/views/exercise_view.dart';
import '../fitness_plan/models/plan.dart';
import '../fitness_plan/models/blocks/exercise_prescription_step.dart';
import '../fitness_plan/enums/day_of_week.dart';
import '../temporary_navigator_view.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const TemporaryNavigatorView(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => OnboardingSurveyContainer(
          onComplete: () {
            context.go('/');
          },
        ),
      ),
      GoRoute(
        path: RouteNames.plan,
        name: 'plan',
        builder: (context, state) {
          final plan = state.extra as Plan?;
          
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
      GoRoute(
        path: RouteNames.exercise,
        name: 'exercise',
        builder: (context, state) {
          final step = state.extra as ExercisePrescriptionStep?;
          
          if (step == null) {
            return const Center(child: Text('Exercise not found'));
          }
          
          return ExerciseView(
            step: step,
          );
        },
      ),
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
              onPressed: () => context.go(RouteNames.onboarding),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}