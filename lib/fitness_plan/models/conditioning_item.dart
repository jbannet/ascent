import 'package:json_annotation/json_annotation.dart';

part 'conditioning_item.g.dart';

@JsonSerializable()
class ConditioningItem {
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  
  @JsonKey(name: 'time_min')
  final int timeMin;
  
  final String? zone; // e.g., "easy"

  ConditioningItem({ required this.exerciseId, required this.timeMin, this.zone });

  factory ConditioningItem.fromJson(Map<String, dynamic> json) => _$ConditioningItemFromJson(json);
  Map<String, dynamic> toJson() => _$ConditioningItemToJson(this);
}