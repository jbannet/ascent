import '../../enums/intensity_mode.dart';

class Intensity {
  final IntensityMode mode;
  final double? value;       // for percent1rm (0-100), e1rm target, rpe
  final int? target;         // for RIR target
  final String? levelOrZone; // band level or zone name

  Intensity.percent1rm({ required this.value })
      : mode = IntensityMode.percent1rm, target = null, levelOrZone = null;
  Intensity.e1rm({ required double target })
      : mode = IntensityMode.e1rm, value = target, target = null, levelOrZone = null;
  Intensity.rir({ required this.target })
      : mode = IntensityMode.rir, value = null, levelOrZone = null;
  Intensity.rpe({ required double target })
      : mode = IntensityMode.rpe, value = target, target = null, levelOrZone = null;
  Intensity.bandLevel({ required String level })
      : mode = IntensityMode.bandLevel, value = null, target = null, levelOrZone = level;
  Intensity.paceZone({ required String zone })
      : mode = IntensityMode.paceZone, value = null, target = null, levelOrZone = zone;
  Intensity.heartRateZone({ required String zone })
      : mode = IntensityMode.heartRateZone, value = null, target = null, levelOrZone = zone;

  factory Intensity.fromJson(Map<String, dynamic> json) {
    final modeStr = json['mode'] as String;
    switch (modeStr) {
      case 'percent1rm':
        return Intensity.percent1rm(value: (json['value'] as num).toDouble());
      case 'e1rm':
        return Intensity.e1rm(target: (json['target'] as num? ?? json['value'] as num).toDouble());
      case 'rir':
        return Intensity.rir(target: (json['target'] as num).toInt());
      case 'rpe':
        return Intensity.rpe(target: (json['target'] as num? ?? json['value'] as num).toDouble());
      case 'bandLevel':
        return Intensity.bandLevel(level: json['level'] as String? ?? json['levelOrZone'] as String);
      case 'paceZone':
        return Intensity.paceZone(zone: json['zone'] as String? ?? json['levelOrZone'] as String);
      case 'heartRateZone':
        return Intensity.heartRateZone(zone: json['zone'] as String? ?? json['levelOrZone'] as String);
      default:
        return Intensity.rir(target: 2);
    }
  }

  Map<String, dynamic> toJson() {
    switch (mode) {
      case IntensityMode.percent1rm:
        return { 'mode': 'percent1rm', 'value': value };
      case IntensityMode.e1rm:
        return { 'mode': 'e1rm', 'target': value };
      case IntensityMode.rir:
        return { 'mode': 'rir', 'target': target };
      case IntensityMode.rpe:
        return { 'mode': 'rpe', 'target': value };
      case IntensityMode.bandLevel:
        return { 'mode': 'bandLevel', 'level': levelOrZone };
      case IntensityMode.paceZone:
        return { 'mode': 'paceZone', 'zone': levelOrZone };
      case IntensityMode.heartRateZone:
        return { 'mode': 'heartRateZone', 'zone': levelOrZone };
    }
  }
}