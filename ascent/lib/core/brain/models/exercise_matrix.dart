import 'dart:math' as math;
import 'dart:typed_data';

/// Dense representation of an exercise-to-features matrix
/// Uses List<List<double>> for simple, efficient matrix operations
class ExerciseMatrix {
  /// Dense N×M matrix where matrix[exerciseIndex][featureIndex] = value
  late List<List<double>> _matrix;
  
  /// Exercise ID -> row index mapping
  final Map<String, int> _exerciseIndex;
  
  /// Feature ID -> column index mapping  
  final Map<String, int> _featureIndex;
  
  /// Reverse mapping: row index -> exercise ID
  final List<String> _exercises;
  
  /// Reverse mapping: column index -> feature ID
  final List<String> _features;

  ExerciseMatrix._internal({
    required List<List<double>> matrix,
    required Map<String, int> exerciseIndex,
    required Map<String, int> featureIndex,
    required List<String> exercises,
    required List<String> features,
  }) : _matrix = matrix,
       _exerciseIndex = exerciseIndex,
       _featureIndex = featureIndex,
       _exercises = exercises,
       _features = features;

  /// Create empty matrix with specified exercises and features
  factory ExerciseMatrix.create(List<String> exercises, List<String> features) {
    final exerciseIndex = <String, int>{};
    final featureIndex = <String, int>{};
    
    for (int i = 0; i < exercises.length; i++) {
      exerciseIndex[exercises[i]] = i;
    }
    
    for (int i = 0; i < features.length; i++) {
      featureIndex[features[i]] = i;
    }
    
    // Initialize matrix with zeros
    final matrix = List.generate(
      exercises.length, 
      (_) => List.filled(features.length, 0.0),
    );
    
    return ExerciseMatrix._internal(
      matrix: matrix,
      exerciseIndex: exerciseIndex,
      featureIndex: featureIndex,
      exercises: List.from(exercises),
      features: List.from(features),
    );
  }

  /// Get feature value for an exercise
  double getFeature(String exerciseId, String featureId) {
    final exerciseIdx = _exerciseIndex[exerciseId];
    final featureIdx = _featureIndex[featureId];
    
    if (exerciseIdx == null || featureIdx == null) return 0.0;
    return _matrix[exerciseIdx][featureIdx];
  }

  /// Set feature value for an exercise
  void setFeature(String exerciseId, String featureId, double value) {
    final exerciseIdx = _exerciseIndex[exerciseId];
    final featureIdx = _featureIndex[featureId];
    
    if (exerciseIdx == null || featureIdx == null) {
      throw ArgumentError('Exercise "$exerciseId" or feature "$featureId" not found in matrix');
    }
    
    _matrix[exerciseIdx][featureIdx] = value;
  }

  /// Get all features for an exercise as a map
  Map<String, double> getExerciseFeatures(String exerciseId) {
    final exerciseIdx = _exerciseIndex[exerciseId];
    if (exerciseIdx == null) return <String, double>{};
    
    final features = <String, double>{};
    final exerciseRow = _matrix[exerciseIdx];
    
    for (int i = 0; i < _features.length; i++) {
      features[_features[i]] = exerciseRow[i];
    }
    
    return features;
  }

  /// Get exercise feature vector as a typed list (for performance)
  Float64List getExerciseVector(String exerciseId) {
    final exerciseIdx = _exerciseIndex[exerciseId];
    if (exerciseIdx == null) return Float64List(featureCount);
    
    return Float64List.fromList(_matrix[exerciseIdx]);
  }

  /// Calculate dot product of exercise features with a block vector
  double dotProduct(String exerciseId, Map<String, double> blockVector) {
    final exerciseIdx = _exerciseIndex[exerciseId];
    if (exerciseIdx == null) return 0.0;
    
    double product = 0.0;
    final exerciseRow = _matrix[exerciseIdx];
    
    for (final entry in blockVector.entries) {
      final featureIdx = _featureIndex[entry.key];
      if (featureIdx != null) {
        product += exerciseRow[featureIdx] * entry.value;
      }
    }
    
    return product;
  }

  /// Calculate dot product using feature vector (more efficient for repeated operations)
  double dotProductVector(String exerciseId, Float64List blockVector) {
    final exerciseIdx = _exerciseIndex[exerciseId];
    if (exerciseIdx == null) return 0.0;
    
    final exerciseRow = _matrix[exerciseIdx];
    double product = 0.0;
    
    for (int i = 0; i < math.min(exerciseRow.length, blockVector.length); i++) {
      product += exerciseRow[i] * blockVector[i];
    }
    
    return product;
  }

  /// Get exercises compatible with block requirements (above threshold)
  List<String> getCompatibleExercises(Map<String, double> blockVector, {double threshold = 0.1}) {
    final compatible = <String>[];
    
    for (final exerciseId in _exercises) {
      final score = dotProduct(exerciseId, blockVector);
      if (score >= threshold) {
        compatible.add(exerciseId);
      }
    }
    
    return compatible;
  }

  /// Get ranked exercise candidates with their scores
  List<ExerciseCandidate> getRankedCandidates(Map<String, double> blockVector) {
    final candidates = <ExerciseCandidate>[];
    
    for (final exerciseId in _exercises) {
      final score = dotProduct(exerciseId, blockVector);
      candidates.add(ExerciseCandidate(
        exerciseId: exerciseId,
        compatibilityScore: score,
      ));
    }
    
    candidates.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
    return candidates;
  }

  /// Calculate cosine similarity between two exercises
  double calculateExerciseSimilarity(String exerciseId1, String exerciseId2) {
    final idx1 = _exerciseIndex[exerciseId1];
    final idx2 = _exerciseIndex[exerciseId2];
    
    if (idx1 == null || idx2 == null) return 0.0;
    
    final features1 = _matrix[idx1];
    final features2 = _matrix[idx2];
    
    double dotProduct = 0.0;
    double magnitude1 = 0.0;
    double magnitude2 = 0.0;
    
    for (int i = 0; i < features1.length; i++) {
      final value1 = features1[i];
      final value2 = features2[i];
      
      dotProduct += value1 * value2;
      magnitude1 += value1 * value1;
      magnitude2 += value2 * value2;
    }
    
    if (magnitude1 == 0.0 || magnitude2 == 0.0) return 0.0;
    
    return dotProduct / (math.sqrt(magnitude1) * math.sqrt(magnitude2));
  }

  /// Add a new exercise (expands the matrix)
  void addExercise(String exerciseId, Map<String, double> features) {
    if (_exerciseIndex.containsKey(exerciseId)) {
      throw ArgumentError('Exercise "$exerciseId" already exists');
    }
    
    // Add to mappings
    final newIdx = _exercises.length;
    _exerciseIndex[exerciseId] = newIdx;
    _exercises.add(exerciseId);
    
    // Add new row to matrix
    final newRow = List.filled(_features.length, 0.0);
    for (final entry in features.entries) {
      final featureIdx = _featureIndex[entry.key];
      if (featureIdx != null) {
        newRow[featureIdx] = entry.value;
      }
    }
    _matrix.add(newRow);
  }

  /// Add a new feature (expands the matrix)
  void addFeature(String featureId, {double defaultValue = 0.0}) {
    if (_featureIndex.containsKey(featureId)) {
      throw ArgumentError('Feature "$featureId" already exists');
    }
    
    // Add to mappings
    final newIdx = _features.length;
    _featureIndex[featureId] = newIdx;
    _features.add(featureId);
    
    // Add new column to all rows
    for (final row in _matrix) {
      row.add(defaultValue);
    }
  }

  // Getters
  List<String> get exerciseIds => List.from(_exercises);
  List<String> get featureIds => List.from(_features);
  int get exerciseCount => _exercises.length;
  int get featureCount => _features.length;

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    final matrixData = <String, Map<String, double>>{};
    
    for (int i = 0; i < _exercises.length; i++) {
      final exerciseFeatures = <String, double>{};
      for (int j = 0; j < _features.length; j++) {
        exerciseFeatures[_features[j]] = _matrix[i][j];
      }
      matrixData[_exercises[i]] = exerciseFeatures;
    }
    
    return {
      'matrix': matrixData,
      'exercises': _exercises,
      'features': _features,
      'dimensions': {
        'exercises': exerciseCount,
        'features': featureCount,
      },
    };
  }

  /// Create from JSON representation
  factory ExerciseMatrix.fromJson(Map<String, dynamic> json) {
    final exercises = (json['exercises'] as List).cast<String>();
    final features = (json['features'] as List).cast<String>();
    
    final matrix = ExerciseMatrix.create(exercises, features);
    
    final matrixData = json['matrix'] as Map<String, dynamic>;
    for (final entry in matrixData.entries) {
      final exerciseId = entry.key;
      final featuresMap = entry.value as Map<String, dynamic>;
      
      for (final featureEntry in featuresMap.entries) {
        final featureId = featureEntry.key;
        final value = (featureEntry.value as num).toDouble();
        matrix.setFeature(exerciseId, featureId, value);
      }
    }
    
    return matrix;
  }
}

/// Candidate exercise with compatibility score
class ExerciseCandidate {
  final String exerciseId;
  final double compatibilityScore;

  const ExerciseCandidate({
    required this.exerciseId,
    required this.compatibilityScore,
  });

  @override
  String toString() => 'ExerciseCandidate($exerciseId: $compatibilityScore)';
}

/// Common feature constants for exercises
class ExerciseFeatures {
  // Equipment requirements
  static const String requiresDumbbells = 'requires_dumbbells';
  static const String requiresBarbell = 'requires_barbell';
  static const String requiresBalanceBall = 'requires_balance_ball';
  static const String requiresResistanceBand = 'requires_resistance_band';
  static const String requiresGym = 'requires_gym';
  static const String bodywightOnly = 'bodyweight_only';
  
  // Body targeting
  static const String targetsUpperBody = 'targets_upper_body';
  static const String targetsLowerBody = 'targets_lower_body';
  static const String targetsCore = 'targets_core';
  static const String isFullBody = 'is_full_body';
  
  // Movement patterns
  static const String isCompoundMovement = 'is_compound_movement';
  static const String isIsolationMovement = 'is_isolation_movement';
  static const String requiresBalance = 'requires_balance';
  static const String requiresCoordination = 'requires_coordination';
  
  // Intensity and difficulty
  static const String suitableForBeginners = 'suitable_for_beginners';
  static const String highCardioIntensity = 'high_cardio_intensity';
  static const String lowImpact = 'low_impact';
  static const String highIntensity = 'high_intensity';
  
  // Exercise goals
  static const String buildsStrength = 'builds_strength';
  static const String improvesMobility = 'improves_mobility';
  static const String improvesCardio = 'improves_cardio';
  static const String improvesFlexibility = 'improves_flexibility';

  /// Get all feature constants as a list
  static List<String> get allFeatures => [
    requiresDumbbells,
    requiresBarbell,
    requiresBalanceBall,
    requiresResistanceBand,
    requiresGym,
    bodywightOnly,
    targetsUpperBody,
    targetsLowerBody,
    targetsCore,
    isFullBody,
    isCompoundMovement,
    isIsolationMovement,
    requiresBalance,
    requiresCoordination,
    suitableForBeginners,
    highCardioIntensity,
    lowImpact,
    highIntensity,
    buildsStrength,
    improvesMobility,
    improvesCardio,
    improvesFlexibility,
  ];
}

/// Factory class to create exercise matrices with sample data
class ExerciseMatrixFactory {
  /// Create a sample exercise matrix with common exercises
  static ExerciseMatrix createSampleMatrix() {
    final exercises = ['push_ups', 'dumbbell_rows', 'balance_ball_squats', 'burpees'];
    final features = ExerciseFeatures.allFeatures;
    
    final matrix = ExerciseMatrix.create(exercises, features);
    
    // Push-ups
    matrix.setFeature('push_ups', ExerciseFeatures.bodywightOnly, 1.0);
    matrix.setFeature('push_ups', ExerciseFeatures.targetsUpperBody, 1.0);
    matrix.setFeature('push_ups', ExerciseFeatures.targetsCore, 0.6);
    matrix.setFeature('push_ups', ExerciseFeatures.isCompoundMovement, 1.0);
    matrix.setFeature('push_ups', ExerciseFeatures.suitableForBeginners, 0.8);
    matrix.setFeature('push_ups', ExerciseFeatures.buildsStrength, 0.8);
    matrix.setFeature('push_ups', ExerciseFeatures.lowImpact, 0.7);
    
    // Dumbbell rows
    matrix.setFeature('dumbbell_rows', ExerciseFeatures.requiresDumbbells, 1.0);
    matrix.setFeature('dumbbell_rows', ExerciseFeatures.targetsUpperBody, 1.0);
    matrix.setFeature('dumbbell_rows', ExerciseFeatures.targetsCore, 0.4);
    matrix.setFeature('dumbbell_rows', ExerciseFeatures.isCompoundMovement, 1.0);
    matrix.setFeature('dumbbell_rows', ExerciseFeatures.suitableForBeginners, 0.7);
    matrix.setFeature('dumbbell_rows', ExerciseFeatures.buildsStrength, 0.9);
    matrix.setFeature('dumbbell_rows', ExerciseFeatures.lowImpact, 0.8);
    
    // Balance ball squats
    matrix.setFeature('balance_ball_squats', ExerciseFeatures.requiresBalanceBall, 1.0);
    matrix.setFeature('balance_ball_squats', ExerciseFeatures.targetsLowerBody, 1.0);
    matrix.setFeature('balance_ball_squats', ExerciseFeatures.targetsCore, 0.8);
    matrix.setFeature('balance_ball_squats', ExerciseFeatures.isCompoundMovement, 1.0);
    matrix.setFeature('balance_ball_squats', ExerciseFeatures.requiresBalance, 1.0);
    matrix.setFeature('balance_ball_squats', ExerciseFeatures.requiresCoordination, 0.8);
    matrix.setFeature('balance_ball_squats', ExerciseFeatures.suitableForBeginners, 0.5);
    matrix.setFeature('balance_ball_squats', ExerciseFeatures.buildsStrength, 0.7);
    
    // Burpees
    matrix.setFeature('burpees', ExerciseFeatures.bodywightOnly, 1.0);
    matrix.setFeature('burpees', ExerciseFeatures.isFullBody, 1.0);
    matrix.setFeature('burpees', ExerciseFeatures.isCompoundMovement, 1.0);
    matrix.setFeature('burpees', ExerciseFeatures.highCardioIntensity, 1.0);
    matrix.setFeature('burpees', ExerciseFeatures.highIntensity, 1.0);
    matrix.setFeature('burpees', ExerciseFeatures.requiresCoordination, 0.7);
    matrix.setFeature('burpees', ExerciseFeatures.suitableForBeginners, 0.3);
    matrix.setFeature('burpees', ExerciseFeatures.improvesCardio, 1.0);
    matrix.setFeature('burpees', ExerciseFeatures.buildsStrength, 0.6);
    
    return matrix;
  }
}