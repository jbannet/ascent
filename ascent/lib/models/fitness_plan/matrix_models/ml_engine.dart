import 'package:ml_linalg/linalg.dart';


/// Simple dense exercise matrix using ml_linalg for fast ops
class ExerciseMatrix {
  final Map<String, Vector> _exerciseMap = {};
  final List<String> _features; // List of features in column order
  
  
  //MARK: Constructors
  // Expecting payload structure: f({ "exercise_1": [0.1, 0.2], "exercise_2": [0.3, 0.4]}, ["feature1", "feature2"])
  ExerciseMatrix.init(Map<String, dynamic> exercises, List<String> featureList) : _features = featureList {
    for (final exerciseId in exercises.keys) {
      final features = (exercises[exerciseId] as List).cast<double>();
      _addExerciseFromListHelper(exerciseId, features);
    } 
  }

  /// Add or replace a row for an exercise
  void _addExerciseFromListHelper(String exerciseId, List<double> features) {  
    final vec = Vector.fromList(features);
    _exerciseMap[exerciseId] = vec;
  }

  //MARK: Getters
  List<Vector> get _rows => _exerciseMap.values.toList(growable: false);
  int? get _featureCount => _rows.isNotEmpty ? _rows.first.length : null;
  List<String> get features => _features;

  /// Get exercise vector by ID
  Vector? getExercise(String exerciseId) {
    return _exerciseMap[exerciseId];    
  }  

  //MARK: Operations
  /// Multiply all exercise rows by the given vector (row-wise dot products)
  /// Returns a Vector of dot products aligned with insertion order.
  Vector dotProduct(Vector vector) {
    if (_rows.isEmpty) return Vector.fromList(const []);
    if (_featureCount == null) return Vector.fromList(const []);
    if (vector.length != _featureCount) {
      throw ArgumentError(
        'Input vector length ${vector.length} does not match expected $_featureCount',
      );
    }
    final Matrix matrixRepresentation = Matrix.fromRows(_rows);
    Matrix result = matrixRepresentation * vector; // dot product
    return result.getColumn(0); // convert to a vector
  }

  //Multiply by the filter Vector and remove all exercises that have a total score of 0
  ExerciseMatrix filter(Vector filter){
    //Check that filter length matches feature count
    if(_featureCount == null) return this;
    if(filter.length != _featureCount){
      throw ArgumentError(
        'Filter vector length ${filter.length} does not match expected $_featureCount',
      );
    }
    //apply filter
    Map<String, Vector> exercisesToKeep = {};
    for(final id in _exerciseMap.keys){
      final row = _exerciseMap[id]!;
      final dot = row.dot(filter);
      if(dot != 0){
        exercisesToKeep[id] = row;
      }
    }

    return ExerciseMatrix.init(exercisesToKeep, features);
  }
}