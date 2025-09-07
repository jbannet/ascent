import 'package:ml_linalg/vector.dart';

/// A Person Vector represents the user's initial preferences + ongoing feedback + progress
class PersonVector {
  final Map<String, double> _featureScores;
  
  //Instantiate the PersonVector making sure the features are in the same order as used in the exercise_matrix
  PersonVector(Map<String, double> exerciseScores, List<String> featureOrder) : _featureScores = {} {
    for (final feature in featureOrder) {
      _featureScores[feature] = exerciseScores[feature] ?? 0.0;
    }
  }  

  /// Get score for specific feature
  double? getScore(String featureId) => _featureScores[featureId];
  
  /// Get the underlying vector for matrix operations in the SAME ORDER that the constructor added them in
  Vector getVector(List<String> featureOrder) {
    final List<double> scores = _featureScores.values.toList(growable: false);    
    return Vector.fromList(scores);
  }
}