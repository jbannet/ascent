import '../../constants_and_enums/block_step_kind.dart';
import 'exercise_prescription_step.dart';
import 'rest_step.dart';
import 'warmup_step.dart';
import 'cooldown_step.dart';

abstract class BlockStep {
  BlockStepKind get kind;

  int estimateDurationSec();

  Map<String, dynamic> toJson();

  factory BlockStep.fromJson(Map<String, dynamic> json) {
    final k = json['kind'] as String? ??
        (json.containsKey('exercise_id') ? 'exercise' : null);

    switch (k) {
      case 'exercise':
        return ExercisePrescriptionStep.fromJson(json);
      case 'rest':
        return RestStep.fromJson(json);
      case 'warmup':
        return WarmupStep.fromJson(json);
      case 'cooldown':
        return CooldownStep.fromJson(json);
      default:
        throw ArgumentError('Unknown step kind: $k');
    }
  }
}