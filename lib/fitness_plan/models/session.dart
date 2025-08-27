import 'package:json_annotation/json_annotation.dart';
import 'block.dart';
import '../enums/session_tag.dart';
import '../enums/energy_system_tag.dart';
import '../converters/enum_converters.dart';
import '../converters/block_converter.dart';

part 'session.g.dart';

@JsonSerializable()
class Session {
  final String title;
  
  @JsonKey(name: 'estimated_duration_min')
  final int estimatedDurationMin;
  
  final List<String> warmup;
  
  @BlockListConverter()
  final List<Block> blocks;
  
  final List<String> cooldown;
  
  @SessionTagListConverter()
  final List<SessionTag> tags;
  
  @JsonKey(name: 'energy_system')
  @EnergySystemTagConverter()
  final EnergySystemTag? energySystem;

  Session({
    required this.title,
    this.estimatedDurationMin = 45,
    List<String>? warmup,
    List<Block>? blocks,
    List<String>? cooldown,
    List<SessionTag>? tags,
    this.energySystem,
  })  : warmup = warmup ?? <String>[],
        blocks = blocks ?? <Block>[],
        cooldown = cooldown ?? <String>[],
        tags = tags ?? <SessionTag>[];

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
  Map<String, dynamic> toJson() => _$SessionToJson(this);
}