// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
  title: json['title'] as String,
  estimatedDurationMin: (json['estimated_duration_min'] as num?)?.toInt() ?? 45,
  warmup: (json['warmup'] as List<dynamic>?)?.map((e) => e as String).toList(),
  blocks: _$JsonConverterFromJson<List<dynamic>, List<Block>>(
    json['blocks'],
    const BlockListConverter().fromJson,
  ),
  cooldown:
      (json['cooldown'] as List<dynamic>?)?.map((e) => e as String).toList(),
  tags: _$JsonConverterFromJson<List<dynamic>, List<SessionTag>>(
    json['tags'],
    const SessionTagListConverter().fromJson,
  ),
  energySystem: _$JsonConverterFromJson<String, EnergySystemTag>(
    json['energy_system'],
    const EnergySystemTagConverter().fromJson,
  ),
);

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
  'title': instance.title,
  'estimated_duration_min': instance.estimatedDurationMin,
  'warmup': instance.warmup,
  'blocks': const BlockListConverter().toJson(instance.blocks),
  'cooldown': instance.cooldown,
  'tags': const SessionTagListConverter().toJson(instance.tags),
  'energy_system': _$JsonConverterToJson<String, EnergySystemTag>(
    instance.energySystem,
    const EnergySystemTagConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
