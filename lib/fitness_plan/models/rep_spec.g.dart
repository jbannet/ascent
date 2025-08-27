// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rep_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepSpec _$RepSpecFromJson(Map<String, dynamic> json) => RepSpec(
  kind: const RepKindConverter().fromJson(json['kind'] as String),
  value: (json['value'] as num?)?.toInt(),
  min: (json['min'] as num?)?.toInt(),
  max: (json['max'] as num?)?.toInt(),
);

Map<String, dynamic> _$RepSpecToJson(RepSpec instance) => <String, dynamic>{
  'kind': const RepKindConverter().toJson(instance.kind),
  'value': instance.value,
  'min': instance.min,
  'max': instance.max,
};
