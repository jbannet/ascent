import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../fitness_plan/views/exercise_view.dart';
import '../../fitness_plan/models/blocks/exercise_prescription_step.dart';
import '../route_names.dart';

/// Exercise-related routes for the application
class ExerciseRoutes {
  static List<RouteBase> routes = [
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
  ];
}