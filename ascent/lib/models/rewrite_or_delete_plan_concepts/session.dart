import '../blocks/block.dart';
import '../../constants_and_enums/session_type.dart';
import '../../constants_and_enums/exercise_style.dart';

class Session {
  final String id;
  final String title;
  final List<Block> blocks;
  final SessionType type;
  final ExerciseStyle style;

  Session({
    required this.id,
    required this.title,
    List<Block>? blocks,
    this.type = SessionType.full,
    this.style = ExerciseStyle.strength,
  }) : blocks = blocks ?? <Block>[];

  int get estimatedDurationMin {
    final totalSec = blocks.fold<int>(0, (sum, b) => sum + b.estimateDurationSec());
    return (totalSec / 60).ceil();
  }

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'] as String,
    title: json['title'] as String,
    blocks: (json['blocks'] as List<dynamic>? )?.map((e)=> Block.fromJson(Map<String, dynamic>.from(e))).toList() ?? <Block>[],
    type: json['type'] != null ? sessionTypeFromString(json['type'] as String) : SessionType.full,
    style: json['style'] != null ? exerciseStyleFromString(json['style'] as String) : ExerciseStyle.strength,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'blocks': blocks.map((b)=> b.toJson()).toList(),
    'type': sessionTypeToString(type),
    'style': exerciseStyleToString(style),
  };
}