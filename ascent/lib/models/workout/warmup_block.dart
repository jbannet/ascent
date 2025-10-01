import 'block.dart';

class WarmupBlock extends Block {
  final int durationSec;

  WarmupBlock({
    required this.durationSec,
  }) : super(label: 'Warmup');

  @override
  int estimateDurationSec() => durationSec;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'warmup',
        'label': label,
        'durationSec': durationSec,
      };

  factory WarmupBlock.fromJson(Map<String, dynamic> json) {
    return WarmupBlock(
      durationSec: json['durationSec'] as int,
    );
  }
}
