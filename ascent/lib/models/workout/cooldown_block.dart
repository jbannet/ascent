import 'block.dart';
import '../../constants_and_enums/workout_enums/movement_pattern.dart';

class CooldownBlock extends Block {
  final List<MovementPattern> patterns;
  final int durationSecPerPattern;

  CooldownBlock({
    required String label,
    required this.patterns,
    required this.durationSecPerPattern,
  }) : super(label: label);

  @override
  int estimateDurationSec() => patterns.length * durationSecPerPattern;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'cooldown',
        'label': label,
        'patterns': patterns.map((p) => p.toJson()).toList(),
        'durationSecPerPattern': durationSecPerPattern,
      };

  factory CooldownBlock.fromJson(Map<String, dynamic> json) {
    return CooldownBlock(
      label: json['label'] as String,
      patterns: (json['patterns'] as List<dynamic>)
          .map((p) => MovementPattern.fromJson(p as String))
          .toList(),
      durationSecPerPattern: json['durationSecPerPattern'] as int,
    );
  }
}
