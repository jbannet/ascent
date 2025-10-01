import 'block_step.dart';
import '../../constants_and_enums/block_step_kind.dart';

class RestStep implements BlockStep {
  @override
  BlockStepKind get kind => BlockStepKind.rest;

  final int seconds;
  final String? label; // e.g., "Rest before next round"

  RestStep({ required this.seconds, this.label });

  @override
  int estimateDurationSec() => seconds;

  factory RestStep.fromJson(Map<String, dynamic> json) =>
      RestStep(seconds: json['seconds'] as int, label: json['label'] as String?);

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'rest',
    'seconds': seconds,
    'label': label,
  };
}