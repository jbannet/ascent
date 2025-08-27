import '../../enums/block_type.dart';
import 'exercise_prescription_step.dart';

class Block {
  final BlockType type;

  /// If `rounds > 1`, treat items as a circuit (e.g., a superset) repeated `rounds` times.
  final int rounds;

  /// Rest after each round (useful for supersets/circuits).
  final int restSecBetweenRounds;

  /// Straight list of items; how they're executed depends on [type] + [rounds].
  /// 
  final List<ExercisePrescriptionStep> items;

  Block({
    required this.type,
    List<ExercisePrescriptionStep>? items,
    this.rounds = 1,
    this.restSecBetweenRounds = 0,
  }) : items = items ?? <ExercisePrescriptionStep>[];

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        type: blockTypeFromString(json['type'] as String),
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => ExercisePrescriptionStep.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            <ExercisePrescriptionStep>[],
        rounds: (json['rounds'] as int?) ?? 1,
        restSecBetweenRounds: (json['rest_sec_between_rounds'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
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