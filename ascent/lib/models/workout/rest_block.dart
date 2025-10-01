import 'block.dart';

class RestBlock extends Block {
  final int durationSec;

  RestBlock({
    required String label,
    required this.durationSec,
  }) : super(label: label);

  @override
  int estimateDurationSec() => durationSec;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'rest',
        'label': label,
        'durationSec': durationSec,
      };

  factory RestBlock.fromJson(Map<String, dynamic> json) {
    return RestBlock(
      label: json['label'] as String,
      durationSec: json['durationSec'] as int,
    );
  }
}
