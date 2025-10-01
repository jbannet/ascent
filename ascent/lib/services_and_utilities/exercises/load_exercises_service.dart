import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/workout/exercise.dart';
import '../../constants_and_enums/workout_enums/movement_pattern.dart';

class LoadExercisesService {
  // Cache: pattern+style -> List<Exercise>
  static final Map<String, List<Exercise>> _cache = {};

  /// Load exercises that match the given pattern and optionally the workout style
  static Future<List<Exercise>> loadExercisesForPattern(
    MovementPattern pattern, [
    String? workoutStyle,
  ]) async {
    final cacheKey = workoutStyle != null
        ? '${pattern.name}_$workoutStyle'
        : pattern.name;

    // Return cached if available
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Load all exercises from assets
    final allExercises = await loadAllExercises();

    // Filter by pattern and optionally by style
    final filtered = allExercises.where((exercise) {
      final hasPattern = exercise.movementPatterns.contains(pattern);
      if (!hasPattern) return false;

      if (workoutStyle != null) {
        return exercise.workoutStyles.contains(workoutStyle);
      }
      return true;
    }).toList();

    // Cache and return
    _cache[cacheKey] = filtered;
    return filtered;
  }

  /// Load all exercises from the assets directory
  static Future<List<Exercise>> loadAllExercises() async {
    try {
      // Load the asset manifest to find all exercise JSON files
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Find all exercise JSON files
      final exerciseFiles = manifestMap.keys
          .where((String key) =>
              key.startsWith('assets/exercises/') &&
              key.endsWith('.json'))
          .toList();

      // Load each exercise file
      final List<Exercise> exercises = [];
      for (final filePath in exerciseFiles) {
        try {
          final content = await rootBundle.loadString(filePath);
          final jsonData = json.decode(content) as Map<String, dynamic>;

          // Extract ID from filename (remove path and .json extension)
          final id = filePath.split('/').last.replaceAll('.json', '');

          final exercise = Exercise.fromJson(jsonData, id);
          exercises.add(exercise);
        } catch (e) {
          // Log error but continue loading other exercises
          print('Error loading exercise from $filePath: $e');
        }
      }

      return exercises;
    } catch (e) {
      print('Error loading exercises: $e');
      return [];
    }
  }

  /// Clear the cache (useful for testing)
  static void clearCache() {
    _cache.clear();
  }
}
