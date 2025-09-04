import 'package:vector_math/vector_math.dart';

/// Simple dense exercise matrix
class ExerciseMatrix {
  final Map<String, Vector> _exercises = {};
  
  /// Add a row for an exercise
  void addExercise(String exerciseId, List<double> features) {
    _exercises[exerciseId] = Vector.fromList(features);
  }
  
  /// Get exercise by ID
  Vector? getExercise(String exerciseId) {
    return _exercises[exerciseId];
  }
  
  /// Calculate dot product between exercise and block vector
  double dotProduct(String exerciseId, List<double> blockVector) {
    final exercise = _exercises[exerciseId];
    if (exercise == null) return 0.0;
    
    final blockVec = Vector.fromList(blockVector);
    return exercise.dot(blockVec);
  }
}