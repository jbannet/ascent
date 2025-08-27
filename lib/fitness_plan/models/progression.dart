import 'package:json_annotation/json_annotation.dart';
import '../enums/progression_mode.dart';
import '../converters/enum_converters.dart';

part 'progression.g.dart';

@JsonSerializable()
class Progression {
  @ProgressionModeConverter()
  final ProgressionMode mode;
  
  @JsonKey(name: 'increment_lb')
  final double? incrementLb;         // doubleProgression
  
  @JsonKey(name: 'increase_pct')
  final double? increasePct;         // rirGuided
  
  @JsonKey(name: 'decrease_pct')
  final double? decreasePct;         // rirGuided
  
  @JsonKey(name: 'zone_minutes_target')
  final Map<String, int>? zoneMinutesTarget; // conditioning
  
  @JsonKey(name: 'volume_reduction_pct')
  final double? volumeReductionPct;  // deload
  
  @JsonKey(name: 'intensity_reduction_pct')
  final double? intensityReductionPct; // deload

  Progression({
    required this.mode,
    this.incrementLb,
    this.increasePct,
    this.decreasePct,
    this.zoneMinutesTarget,
    this.volumeReductionPct,
    this.intensityReductionPct,
  });

  Progression.doubleProgression({ double incrementLb = 5 })
      : mode = ProgressionMode.doubleProgression,
        incrementLb = incrementLb,
        increasePct = null,
        decreasePct = null,
        zoneMinutesTarget = null,
        volumeReductionPct = null,
        intensityReductionPct = null;

  Progression.rirGuided({ double increasePct = 0.05, double decreasePct = 0.05 })
      : mode = ProgressionMode.rirGuided,
        incrementLb = null,
        increasePct = increasePct,
        decreasePct = decreasePct,
        zoneMinutesTarget = null,
        volumeReductionPct = null,
        intensityReductionPct = null;

  Progression.conditioning({ Map<String, int>? zoneMinutesTarget })
      : mode = ProgressionMode.none, // treat separately if you want
        incrementLb = null,
        increasePct = null,
        decreasePct = null,
        zoneMinutesTarget = zoneMinutesTarget ?? <String, int>{},
        volumeReductionPct = null,
        intensityReductionPct = null;

  Progression.deload({ double volumeReductionPct = 0.35, double intensityReductionPct = 0.10 })
      : mode = ProgressionMode.deload,
        incrementLb = null,
        increasePct = null,
        decreasePct = null,
        zoneMinutesTarget = null,
        volumeReductionPct = volumeReductionPct,
        intensityReductionPct = intensityReductionPct;

  Progression.none()
      : mode = ProgressionMode.none,
        incrementLb = null,
        increasePct = null,
        decreasePct = null,
        zoneMinutesTarget = null,
        volumeReductionPct = null,
        intensityReductionPct = null;

  factory Progression.fromJson(Map<String, dynamic> json) => _$ProgressionFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressionToJson(this);
}