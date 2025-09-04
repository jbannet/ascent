import 'package:ml_linalg/vector.dart';

/// Pattern vector representing feature requirements for a workout block
class PatternVector {
  final Map<String, double> _exerciseFilter;
  
  //Instantiate the PatternVector making sure the features are in the same order as used in the exercise_matrix
  PatternVector(Map<String, double> featureScores, List<String> featureOrder) : _exerciseFilter = {} {
    for (final feature in featureOrder) {
      _exerciseFilter[feature] = featureScores[feature] ?? 0.0;
    }
  }  

  /// Get score for specific feature
  double? getScore(String featureId) => _exerciseFilter[featureId];
  
  /// Get the underlying vector for matrix operations in the SAME ORDER that the constructor added them in
  Vector getVector(List<String> featureOrder) {
    final List<double> scores = _exerciseFilter.values.toList(growable: false);    
    return Vector.fromList(scores);
  }
}