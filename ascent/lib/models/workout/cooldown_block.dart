import 'block.dart';

class CooldownBlock extends Block {
  final int durationSec;

  CooldownBlock({
    required this.durationSec,
  }) : super(label: 'Cooldown');

  @override
  int estimateDurationSec() => durationSec;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'cooldown',
        'label': label,
        'durationSec': durationSec,
      };

  factory CooldownBlock.fromJson(Map<String, dynamic> json) {
    return CooldownBlock(
      durationSec: json['durationSec'] as int,
    );
  }
}
