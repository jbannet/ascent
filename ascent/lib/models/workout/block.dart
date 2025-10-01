import 'warmup_block.dart';
import 'cooldown_block.dart';
import 'exercise_block.dart';
import 'rest_block.dart';

/// Abstract base class for all workout blocks
abstract class Block {
  final String label;

  Block({required this.label});

  /// Estimate duration in seconds for this block
  int estimateDurationSec();

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson();

  /// Factory method to create appropriate block type from JSON
  factory Block.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'warmup':
        return WarmupBlock.fromJson(json);
      case 'cooldown':
        return CooldownBlock.fromJson(json);
      case 'exercise':
        return ExerciseBlock.fromJson(json);
      case 'rest':
        return RestBlock.fromJson(json);
      default:
        throw ArgumentError('Unknown block type: $type');
    }
  }
}
