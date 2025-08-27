import 'block.dart';
import '../enums/session_tag.dart';
import '../enums/energy_system_tag.dart';

class Session {
  final String title;
  final int estimatedDurationMin;
  final List<String> warmup;
  final List<Block> blocks;
  final List<String> cooldown;
  final List<SessionTag> tags;
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

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    title: json['title'] as String,
    estimatedDurationMin: (json['estimated_duration_min'] as int?) ?? 45,
    warmup: (json['warmup'] as List<dynamic>? )?.map((e)=> e.toString()).toList() ?? <String>[],
    blocks: (json['blocks'] as List<dynamic>? )?.map((e)=> Block.fromJson(Map<String, dynamic>.from(e))).toList() ?? <Block>[],
    cooldown: (json['cooldown'] as List<dynamic>? )?.map((e)=> e.toString()).toList() ?? <String>[],
    tags: (json['tags'] as List<dynamic>? )?.map((e)=> sessionTagFromString(e.toString())).toList() ?? <SessionTag>[],
    energySystem: json['energy_system'] == null ? null : energySystemFromString(json['energy_system'] as String),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'estimated_duration_min': estimatedDurationMin,
    'warmup': warmup,
    'blocks': blocks.map((b)=> b.toJson()).toList(),
    'cooldown': cooldown,
    'tags': tags.map(sessionTagToString).toList(),
    'energy_system': energySystem == null ? null : energySystemToString(energySystem!),
  };
}