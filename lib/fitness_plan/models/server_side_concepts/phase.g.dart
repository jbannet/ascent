// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phase _$PhaseFromJson(Map<String, dynamic> json) => Phase(
  name: json['name'] as String,
  weeks: (json['weeks'] as num).toInt(),
  focus: json['focus'] as String? ?? '',
  progressionMode:
      json['progression'] == null
          ? ProgressionMode.doubleProgression
          : const ProgressionModeConverter().fromJson(
            json['progression'] as String,
          ),
);

Map<String, dynamic> _$PhaseToJson(Phase instance) => <String, dynamic>{
  'name': instance.name,
  'weeks': instance.weeks,
  'focus': instance.focus,
  'progression': const ProgressionModeConverter().toJson(
    instance.progressionMode,
  ),
};
