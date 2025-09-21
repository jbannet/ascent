class ExerciseService {
  /// Load the feature order that exercise data rows use in their matrices.
  ///
  /// TODO: Replace with database-backed implementation when exercise metadata
  ///       is integrated. For now we return an empty list and let callers
  ///       handle the fallback/default ordering.
  static Future<List<String>> loadFeatureOrder() async {
    return const <String>[];
  }
}
