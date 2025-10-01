import 'block_step.dart';
import 'warmup_step.dart';
import 'cooldown_step.dart';
import 'exercise_prescription_step.dart';
import 'rest_step.dart';

enum BlockType {
  warmup,
  main,
  cooldown,
  superset,
  circuit,
}

class Block {
  final String label;
  final BlockType type;
  final List<BlockStep> items;
  final int rounds;
  final int? restSecBetweenRounds;

  Block({
    required this.label,
    required this.type,
    required this.items,
    this.rounds = 1,
    this.restSecBetweenRounds,
  });

  /// Estimate total duration for this block including all rounds
  int estimateDurationSec() {
    final singleRoundDuration = items.fold<int>(
      0,
      (sum, step) => sum + step.estimateDurationSec(),
    );

    final totalWorkTime = singleRoundDuration * rounds;
    final totalRestTime = (rounds - 1) * (restSecBetweenRounds ?? 0);

    return totalWorkTime + totalRestTime;
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'type': type.name,
        'items': items.map((item) => item.toJson()).toList(),
        'rounds': rounds,
        'restSecBetweenRounds': restSecBetweenRounds,
      };

  factory Block.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>).map((itemJson) {
      final type = itemJson['type'] as String;
      switch (type) {
        case 'warmup':
          return WarmupStep.fromJson(itemJson);
        case 'cooldown':
          return CooldownStep.fromJson(itemJson);
        case 'exercise':
          return ExercisePrescriptionStep.fromJson(itemJson);
        case 'rest':
          return RestStep.fromJson(itemJson);
        default:
          throw ArgumentError('Unknown block step type: $type');
      }
    }).toList();

    return Block(
      label: json['label'] as String,
      type: BlockType.values.firstWhere((e) => e.name == json['type']),
      items: items,
      rounds: json['rounds'] as int? ?? 1,
      restSecBetweenRounds: json['restSecBetweenRounds'] as int?,
    );
  }
}
