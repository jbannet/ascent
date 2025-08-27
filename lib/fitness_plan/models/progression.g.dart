// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Progression _$ProgressionFromJson(Map<String, dynamic> json) => Progression(
  mode: const ProgressionModeConverter().fromJson(json['mode'] as String),
  incrementLb: (json['increment_lb'] as num?)?.toDouble(),
  increasePct: (json['increase_pct'] as num?)?.toDouble(),
  decreasePct: (json['decrease_pct'] as num?)?.toDouble(),
  zoneMinutesTarget: (json['zone_minutes_target'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toInt())),
  volumeReductionPct: (json['volume_reduction_pct'] as num?)?.toDouble(),
  intensityReductionPct: (json['intensity_reduction_pct'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ProgressionToJson(Progression instance) =>
    <String, dynamic>{
      'mode': const ProgressionModeConverter().toJson(instance.mode),
      'increment_lb': instance.incrementLb,
      'increase_pct': instance.increasePct,
      'decrease_pct': instance.decreasePct,
      'zone_minutes_target': instance.zoneMinutesTarget,
      'volume_reduction_pct': instance.volumeReductionPct,
      'intensity_reduction_pct': instance.intensityReductionPct,
    };
