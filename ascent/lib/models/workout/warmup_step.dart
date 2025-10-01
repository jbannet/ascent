import 'block_step.dart';
import '../../constants_and_enums/workout_enums/movement_pattern.dart';

class WarmupStep extends BlockStep {
  final MovementPattern pattern;
  final int durationSec;

  WarmupStep({
    required this.pattern,
    required this.durationSec,
  });

  @override
  int estimateDurationSec() => durationSec;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'warmup',
        'pattern': pattern.toJson(),
        'durationSec': durationSec,
      };

  factory WarmupStep.fromJson(Map<String, dynamic> json) {
    return WarmupStep(
      pattern: MovementPattern.fromJson(json['pattern'] as String),
      durationSec: json['durationSec'] as int,
    );
  }
}
