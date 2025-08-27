import '../enums/block_type.dart';
import 'exercise_prescription.dart';
import 'conditioning_item.dart';

abstract class Block {
  final BlockType type;
  Block(this.type);

  factory Block.fromJson(Map<String, dynamic> json) {
    final t = blockTypeFromString(json['type'] as String);
    switch (t) {
      case BlockType.straight:
        return StraightBlock(
          items: (json['items'] as List<dynamic>? )?.map((e)=> ExercisePrescription.fromJson(Map<String, dynamic>.from(e))).toList() ?? <ExercisePrescription>[],
        );
      case BlockType.superset:
        return SupersetBlock(
          label: json['label'] as String?,
          items: (json['items'] as List<dynamic>? )?.map((e)=> ExercisePrescription.fromJson(Map<String, dynamic>.from(e))).toList() ?? <ExercisePrescription>[],
        );
      case BlockType.conditioning:
        return ConditioningBlock(
          items: (json['items'] as List<dynamic>? )?.map((e)=> ConditioningItem.fromJson(Map<String, dynamic>.from(e))).toList() ?? <ConditioningItem>[],
        );
      default:
        return StraightBlock(items: const <ExercisePrescription>[]);
    }
  }

  Map<String, dynamic> toJson();
}

class StraightBlock extends Block {
  final List<ExercisePrescription> items;
  
  StraightBlock({ List<ExercisePrescription>? items })
      : items = items ?? <ExercisePrescription>[],
        super(BlockType.straight);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': blockTypeToString(type),
    'items': items.map((e)=> e.toJson()).toList(),
  };
}

class SupersetBlock extends Block {
  final String? label;
  final List<ExercisePrescription> items;
  
  SupersetBlock({ this.label, List<ExercisePrescription>? items })
      : items = items ?? <ExercisePrescription>[],
        super(BlockType.superset);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': blockTypeToString(type),
    'label': label,
    'items': items.map((e)=> e.toJson()).toList(),
  };
}

class ConditioningBlock extends Block {
  final List<ConditioningItem> items;
  
  ConditioningBlock({ List<ConditioningItem>? items })
      : items = items ?? <ConditioningItem>[],
        super(BlockType.conditioning);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': blockTypeToString(type),
    'items': items.map((e)=> e.toJson()).toList(),
  };
}