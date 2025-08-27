// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intensity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Intensity _$IntensityFromJson(Map<String, dynamic> json) => Intensity(
  mode: const IntensityModeConverter().fromJson(json['mode'] as String),
  value: (json['value'] as num?)?.toDouble(),
  target: (json['target'] as num?)?.toInt(),
  levelOrZone: json['levelOrZone'] as String?,
);

Map<String, dynamic> _$IntensityToJson(Intensity instance) => <String, dynamic>{
  'mode': const IntensityModeConverter().toJson(instance.mode),
  'value': instance.value,
  'target': instance.target,
  'levelOrZone': instance.levelOrZone,
};
