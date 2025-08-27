// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StraightBlock _$StraightBlockFromJson(Map<String, dynamic> json) =>
    StraightBlock(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => ExercisePrescription.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$StraightBlockToJson(StraightBlock instance) =>
    <String, dynamic>{'items': instance.items};

SupersetBlock _$SupersetBlockFromJson(Map<String, dynamic> json) =>
    SupersetBlock(
      label: json['label'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => ExercisePrescription.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$SupersetBlockToJson(SupersetBlock instance) =>
    <String, dynamic>{'label': instance.label, 'items': instance.items};

ConditioningBlock _$ConditioningBlockFromJson(Map<String, dynamic> json) =>
    ConditioningBlock(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ConditioningItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ConditioningBlockToJson(ConditioningBlock instance) =>
    <String, dynamic>{'items': instance.items};
