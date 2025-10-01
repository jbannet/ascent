import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/workout/exercise.dart';
import '../../constants_and_enums/workout_enums/movement_pattern.dart';

class LoadExercisesService {
  static final List<Exercise> _cache = [];

  /// Get all exercises that match the given MovementPattern
  /// Optionally filter by compound/isolation preference
  static Future<List<Exercise>> getExercises(
    MovementPattern movementPattern, {
    bool? preferCompound,
  }) async {
    if (_cache.isEmpty) {
      print('LoadExercisesService: exercise cache empty, loading assets');
      await _load();
      print('LoadExercisesService: cache populated with ${_cache.length} exercises');
    }

    var exercises = _cache.where((exercise) =>
      exercise.movementPatterns.contains(movementPattern)
    ).toList();
    print('LoadExercisesService: ${exercises.length} exercises match pattern '
        '${movementPattern.name} before preference filtering');

    // Filter by mechanic preference if specified
    if (preferCompound != null) {
      final mechanic = preferCompound ? 'compound' : 'isolation';
      final filtered = exercises.where((e) => e.mechanic == mechanic).toList();
      // Use filtered list if not empty, otherwise fall back to all exercises
      if (filtered.isNotEmpty) {
        exercises = filtered;
        print('LoadExercisesService: applying mechanic preference $mechanic '
            '-> ${exercises.length} matches');
      } else {
        print('LoadExercisesService: mechanic preference $mechanic yielded no results; '
            'retaining ${exercises.length} pattern matches');
      }
    }

    print('LoadExercisesService: returning ${exercises.length} exercises for '
        '${movementPattern.name} (preferCompound=$preferCompound)');

    return exercises;
  }

  /// Get all exercises (loads cache if needed)
  static Future<List<Exercise>> getAllExercises() async {
    if (_cache.isEmpty) {
      await _load();
    }
    return _cache;
  }

  /// Load all exercises from the assets directory into cache
  static Future<void> _load() async {
    try {
      // Load the exercises index JSON that lists all exercise directories
      final indexContent = await rootBundle.loadString('assets/exercises/exercises_index.json');
      final List<dynamic> exerciseNames = json.decode(indexContent);

      print('LoadExercisesService: Found ${exerciseNames.length} exercises in index');

      // Load each exercise file
      for (final name in exerciseNames) {
        final filePath = 'assets/exercises/$name/exercise.json';
        try {
          final content = await rootBundle.loadString(filePath);
          final jsonData = json.decode(content) as Map<String, dynamic>;

          // Use the name from the JSON as the ID
          final id = jsonData['name'] as String;

          final exercise = Exercise.fromJson(jsonData, id);
          _cache.add(exercise);
        } catch (e) {
          // Log error but continue loading other exercises
          print('Error loading exercise from $filePath: $e');
        }
      }
    } catch (e) {
      print('Error loading exercises: $e');
    }
  }

  /// Clear the cache (useful for testing)
  static void clearCache() {
    _cache.clear();
  }
}
