/// Abstract base class for all block steps
abstract class BlockStep {
  /// Estimate duration in seconds for this step
  int estimateDurationSec();

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson();
}
