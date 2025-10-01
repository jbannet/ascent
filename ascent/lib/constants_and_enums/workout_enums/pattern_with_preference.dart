import 'movement_pattern.dart';

/// Represents a movement pattern with an optional compound/isolation preference
class PatternWithPreference {
  final MovementPattern pattern;

  /// Preference for compound vs isolation exercises
  /// - true: prefer compound exercises
  /// - false: prefer isolation exercises
  /// - null: no preference
  final bool? preferCompound;

  const PatternWithPreference(this.pattern, this.preferCompound);
}
