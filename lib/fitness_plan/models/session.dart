import 'blocks/block.dart';

class Session {
  final String id;
  final String title;
  final List<Block> blocks;

  Session({
    required this.id,
    required this.title,
    List<Block>? blocks,
  }) : blocks = blocks ?? <Block>[];

  int get estimatedDurationMin {
    final totalSec = blocks.fold<int>(0, (sum, b) => sum + b.estimateDurationSec());
    return (totalSec / 60).ceil();
  }

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'] as String,
    title: json['title'] as String,
    blocks: (json['blocks'] as List<dynamic>? )?.map((e)=> Block.fromJson(Map<String, dynamic>.from(e))).toList() ?? <Block>[],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'blocks': blocks.map((b)=> b.toJson()).toList(),
  };
}