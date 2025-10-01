import 'block_step.dart';
import '../../constants_and_enums/workout_enums/movement_pattern.dart';

class CooldownStep extends BlockStep {
  final MovementPattern pattern;
  final int durationSec;

  CooldownStep({
    required this.pattern,
    required this.durationSec,
  });

  @override
  int estimateDurationSec() => durationSec;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'cooldown',
        'pattern': pattern.toJson(),
        'durationSec': durationSec,
      };

  factory CooldownStep.fromJson(Map<String, dynamic> json) {
    return CooldownStep(
      pattern: MovementPattern.fromJson(json['pattern'] as String),
      durationSec: json['durationSec'] as int,
    );
  }
}
