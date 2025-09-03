import '../../enums/block_type.dart';
import 'block_step.dart';

class Block {
  final String? label;
  final BlockType type;

  /// If `rounds > 1`, treat items as a circuit (e.g., a superset) repeated `rounds` times.
  final int rounds;

  /// Rest after each round (useful for supersets/circuits).
  final int restSecBetweenRounds;

  /// Straight list of items; how they're executed depends on [type] + [rounds].
  /// 
  final List<BlockStep> items;

  Block({
    this.label,
    required this.type,
    List<BlockStep>? items,
    this.rounds = 1,
    this.restSecBetweenRounds = 0,
  }) : items = items ?? <BlockStep>[];

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        label: json['label'] as String?,
        type: blockTypeFromString(json['type'] as String),
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => BlockStep.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            <BlockStep>[],
        rounds: (json['rounds'] as int?) ?? 1,
        restSecBetweenRounds: (json['rest_sec_between_rounds'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'type': blockTypeToString(type),
        'items': items.map((e) => e.toJson()).toList(),
        'rounds': rounds,
        'rest_sec_between_rounds': restSecBetweenRounds,
      };

  /// Estimation driven by parameters, not subclasses.
  int estimateDurationSec() {
    // Sum one "round"
    final roundWork = items.fold<int>(0, (sum, it) => sum + it.estimateDurationSec());
    if (rounds <= 1) return roundWork;

    // If circuit/superset: repeat the round N times, add rest between rounds
    final rests = restSecBetweenRounds * (rounds - 1);
    return (roundWork * rounds) + rests;
  }
}