import 'package:json_annotation/json_annotation.dart';

part 'readiness_adjustment.g.dart';

@JsonSerializable()
class ReadinessAdjustment {
  final double low;
  final double high;
  
  ReadinessAdjustment({ this.low = -0.05, this.high = 0.05 });

  factory ReadinessAdjustment.fromJson(Map<String, dynamic> json) => _$ReadinessAdjustmentFromJson(json);
  Map<String, dynamic> toJson() => _$ReadinessAdjustmentToJson(this);
}