/// Represents how a question answer contributes to an ML feature.
/// 
/// Each question can contribute to one or more features with different values
/// and combination strategies (set, add, multiply).
class FeatureContribution {
  /// The name of the feature this contributes to
  final String featureName;
  
  /// The numeric value of the contribution (typically 0.0 to 1.0)
  final double value;
  
  /// How this contribution should be combined with existing feature values
  final ContributionType type;
  
  const FeatureContribution(
    this.featureName, 
    this.value, 
    [this.type = ContributionType.set]
  );
  
  @override
  String toString() => 'FeatureContribution($featureName: $value, $type)';
}

/// How feature contributions are combined when multiple questions affect the same feature
enum ContributionType {
  /// Replace any existing value
  set,
  
  /// Add to existing value (for cumulative features)
  add,
  
  /// Multiply with existing value (for modifier features)
  multiply,
}