import 'block_step.dart';
import '../../enums/block_step_kind.dart';

class WarmupStep implements BlockStep {
  @override
  BlockStepKind get kind => BlockStepKind.warmup;

  final String displayName;  // "Bike (easy)" or "Hip Mobility"
  final int timeSec;

  WarmupStep({ required this.displayName, required this.timeSec });

  @override
  int estimateDurationSec() => timeSec;

  factory WarmupStep.fromJson(Map<String, dynamic> json) =>
      WarmupStep(displayName: json['display_name'] as String, timeSec: json['time_sec'] as int);

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'warmup',
    'display_name': displayName,
    'time_sec': timeSec,
  };
}