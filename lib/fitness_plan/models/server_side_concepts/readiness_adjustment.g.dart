// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readiness_adjustment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadinessAdjustment _$ReadinessAdjustmentFromJson(Map<String, dynamic> json) =>
    ReadinessAdjustment(
      low: (json['low'] as num?)?.toDouble() ?? -0.05,
      high: (json['high'] as num?)?.toDouble() ?? 0.05,
    );

Map<String, dynamic> _$ReadinessAdjustmentToJson(
  ReadinessAdjustment instance,
) => <String, dynamic>{'low': instance.low, 'high': instance.high};
