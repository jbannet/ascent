import '../../constants_and_enums/progression_mode.dart';

class Progression {
  final ProgressionMode mode;
  final double? incrementLb;         // doubleProgression
  final double? increasePct;         // rirGuided
  final double? decreasePct;         // rirGuided
  final Map<String, int>? zoneMinutesTarget; // conditioning
  final double? volumeReductionPct;  // deload
  final double? intensityReductionPct; // deload

  Progression.doubleProgression({ this.incrementLb = 5 })
      : mode = ProgressionMode.doubleProgression,
        increasePct = null,
        decreasePct = null,
        zoneMinutesTarget = null,
        volumeReductionPct = null,
        intensityReductionPct = null;

  Progression.rirGuided({ this.increasePct = 0.05, this.decreasePct = 0.05 })
      : mode = ProgressionMode.rirGuided,
        incrementLb = null,
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

  Progression.deload({ this.volumeReductionPct = 0.35, this.intensityReductionPct = 0.10 })
      : mode = ProgressionMode.deload,
        incrementLb = null,
        increasePct = null,
        decreasePct = null,
        zoneMinutesTarget = null;

  Progression.none()
      : mode = ProgressionMode.none,
        incrementLb = null,
        increasePct = null,
        decreasePct = null,
        zoneMinutesTarget = null,
        volumeReductionPct = null,
        intensityReductionPct = null;

  factory Progression.fromJson(Map<String, dynamic> json) {
    final modeStr = (json['mode'] as String?) ?? 'none';
    switch (modeStr) {
      case 'doubleProgression':
        return Progression.doubleProgression(
          incrementLb: (json['increment_lb'] as num?)?.toDouble() ?? 5,
        );
      case 'rirGuided':
        return Progression.rirGuided(
          increasePct: (json['increase_pct'] as num?)?.toDouble() ?? 0.05,
          decreasePct: (json['decrease_pct'] as num?)?.toDouble() ?? 0.05,
        );
      case 'deload':
        return Progression.deload(
          volumeReductionPct: (json['volume_reduction_pct'] as num?)?.toDouble() ?? 0.35,
          intensityReductionPct: (json['intensity_reduction_pct'] as num?)?.toDouble() ?? 0.10,
        );
      case 'linear':
      case 'none':
      default:
        return Progression.none();
    }
  }

  Map<String, dynamic> toJson() {
    switch (mode) {
      case ProgressionMode.doubleProgression:
        return { 'mode': 'doubleProgression', 'increment_lb': incrementLb };
      case ProgressionMode.rirGuided:
        return { 'mode': 'rirGuided', 'increase_pct': increasePct, 'decrease_pct': decreasePct };
      case ProgressionMode.deload:
        return { 'mode': 'deload', 'volume_reduction_pct': volumeReductionPct, 'intensity_reduction_pct': intensityReductionPct };
      case ProgressionMode.linear:
        return { 'mode': 'linear' };
      case ProgressionMode.none:
        return { 'mode': 'none' };
    }
  }
}