import 'package:json_annotation/json_annotation.dart';
import '../enums/intensity_mode.dart';
import '../converters/enum_converters.dart';

part 'intensity.g.dart';

@JsonSerializable()
class Intensity {
  @IntensityModeConverter()
  final IntensityMode mode;
  final double? value;       // for percent1rm (0-100), e1rm target, rpe
  final int? target;         // for RIR target
  @JsonKey(name: 'levelOrZone')
  final String? levelOrZone; // band level or zone name

  Intensity({
    required this.mode,
    this.value,
    this.target,
    this.levelOrZone,
  });

  Intensity.percent1rm({ required double value })
      : mode = IntensityMode.percent1rm, value = value, target = null, levelOrZone = null;
  Intensity.e1rm({ required double target })
      : mode = IntensityMode.e1rm, value = target, target = null, levelOrZone = null;
  Intensity.rir({ required int target })
      : mode = IntensityMode.rir, value = null, target = target, levelOrZone = null;
  Intensity.rpe({ required double target })
      : mode = IntensityMode.rpe, value = target, target = null, levelOrZone = null;
  Intensity.bandLevel({ required String level })
      : mode = IntensityMode.bandLevel, value = null, target = null, levelOrZone = level;
  Intensity.paceZone({ required String zone })
      : mode = IntensityMode.paceZone, value = null, target = null, levelOrZone = zone;
  Intensity.heartRateZone({ required String zone })
      : mode = IntensityMode.heartRateZone, value = null, target = null, levelOrZone = zone;

  factory Intensity.fromJson(Map<String, dynamic> json) => _$IntensityFromJson(json);
  Map<String, dynamic> toJson() => _$IntensityToJson(this);
}