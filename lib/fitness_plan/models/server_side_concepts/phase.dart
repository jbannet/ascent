import 'package:json_annotation/json_annotation.dart';
import '../../enums/progression_mode.dart';
import '../../converters/enum_converters.dart';

part 'phase.g.dart';

@JsonSerializable()
class Phase {
  final String name; // Base / Build / Peak / Deload
  final int weeks;
  final String focus;
  
  @ProgressionModeConverter()
  @JsonKey(name: 'progression')
  final ProgressionMode progressionMode;

  Phase({
    required this.name,
    required this.weeks,
    this.focus = '',
    this.progressionMode = ProgressionMode.doubleProgression,
  });

  factory Phase.fromJson(Map<String, dynamic> json) => _$PhaseFromJson(json);
  Map<String, dynamic> toJson() => _$PhaseToJson(this);
}