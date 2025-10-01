import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../workflow_views/fitness_plan/views/exercise_view.dart';
import '../../models/workout/exercise_prescription_step.dart';
import '../route_names.dart';

/// Exercise-related routes for the application
///
/// This module handles individual exercise display routes that show detailed
/// views of specific exercises from workout plans. Users navigate here from
/// the main plan view when they want to see exercise instructions, perform
/// the exercise, or track their progress on specific movements.
class ExerciseRoutes {
  static List<RouteBase> routes = [
    // Individual exercise detail route with dynamic exerciseId parameter
    GoRoute(
      path: RouteNames.exercise, // '/exercise/:exerciseId' - defined in route_names.dart
      name: 'exercise',

      // Builder expects ExercisePrescriptionStep data to be passed via navigation extras
      // This ensures the exercise view has all necessary prescription details
      builder: (context, state) {
        // Extract the exercise step data from navigation extras
        // This should be an ExercisePrescriptionStep object containing:
        // - Exercise metadata (name, ID, instructions)
        // - Prescription details (sets, reps, weight, tempo)
        // - Form cues and safety information
        final step = state.extra as ExercisePrescriptionStep?;

        // Safety check: ensure exercise data was provided
        // This prevents crashes if user navigates directly to exercise route
        // or if the navigation didn't include required exercise data
        if (step == null) {
          return const Center(child: Text('Exercise not found'));
        }

        // Render the exercise view which provides:
        // - Exercise instructions and form cues
        // - Set/rep tracking interface
        // - Timer functionality for timed exercises
        // - Progress recording and completion status
        // - Navigation back to workout plan
        return ExerciseView(
          step: step,
        );
      },
    ),
  ];
}