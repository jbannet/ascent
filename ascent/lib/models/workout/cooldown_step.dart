import 'block_step.dart';
import '../../constants_and_enums/block_step_kind.dart';

class CooldownStep implements BlockStep {
  @override
  BlockStepKind get kind => BlockStepKind.cooldown;

  final String displayName;
  final int timeSec;

  CooldownStep({ required this.displayName, required this.timeSec });

  @override
  int estimateDurationSec() => timeSec;

  factory CooldownStep.fromJson(Map<String, dynamic> json) =>
      CooldownStep(displayName: json['display_name'] as String, timeSec: json['time_sec'] as int);

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'cooldown',
    'display_name': displayName,
    'time_sec': timeSec,
  };
}