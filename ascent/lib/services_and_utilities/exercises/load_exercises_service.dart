import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/workout/exercise.dart';
import '../../constants_and_enums/workout_enums/movement_pattern.dart';

class LoadExercisesService {
  static List<Exercise> _cache = [];

  /// Get all exercises that match the given MovementPattern
  /// Optionally filter by compound/isolation preference
  static Future<List<Exercise>> getExercises(
    MovementPattern movementPattern, {
    bool? preferCompound,
  }) async {
    if (_cache.isEmpty) {
      await _load();
    }

    var exercises = _cache.where((exercise) =>
      exercise.movementPatterns.contains(movementPattern)
    ).toList();

    // Filter by mechanic preference if specified
    if (preferCompound != null) {
      final mechanic = preferCompound ? 'compound' : 'isolation';
      final filtered = exercises.where((e) => e.mechanic == mechanic).toList();
      // Use filtered list if not empty, otherwise fall back to all exercises
      if (filtered.isNotEmpty) {
        exercises = filtered;
      }
    }

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
      for (final filePath in exerciseFiles) {
        try {
          final content = await rootBundle.loadString(filePath);
          final jsonData = json.decode(content) as Map<String, dynamic>;

          // Extract ID from filename (remove path and .json extension)
          final id = filePath.split('/').last.replaceAll('.json', '');

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
