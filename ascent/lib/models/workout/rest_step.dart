import 'block_step.dart';

class RestStep extends BlockStep {
  final int durationSec;

  RestStep({
    required this.durationSec,
  });

  @override
  int estimateDurationSec() => durationSec;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'rest',
        'durationSec': durationSec,
      };

  factory RestStep.fromJson(Map<String, dynamic> json) {
    return RestStep(
      durationSec: json['durationSec'] as int,
    );
  }
}
