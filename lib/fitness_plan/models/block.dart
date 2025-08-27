import 'package:json_annotation/json_annotation.dart';
import '../enums/block_type.dart';
import '../converters/enum_converters.dart';
import 'exercise_prescription.dart';
import 'conditioning_item.dart';

part 'block.g.dart';

abstract class Block {
  @BlockTypeConverter()
  final BlockType type;
  Block(this.type);

  factory Block.fromJson(Map<String, dynamic> json) {
    final t = blockTypeFromString(json['type'] as String);
    switch (t) {
      case BlockType.straight:
        return StraightBlock.fromJson(json);
      case BlockType.superset:
        return SupersetBlock.fromJson(json);
      case BlockType.conditioning:
        return ConditioningBlock.fromJson(json);
      default:
        return StraightBlock.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class StraightBlock extends Block {
  final List<ExercisePrescription> items;
  
  StraightBlock({ List<ExercisePrescription>? items })
      : items = items ?? <ExercisePrescription>[],
        super(BlockType.straight);

  factory StraightBlock.fromJson(Map<String, dynamic> json) => _$StraightBlockFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$StraightBlockToJson(this);
}

@JsonSerializable()
class SupersetBlock extends Block {
  final String? label;
  final List<ExercisePrescription> items;
  
  SupersetBlock({ this.label, List<ExercisePrescription>? items })
      : items = items ?? <ExercisePrescription>[],
        super(BlockType.superset);

  factory SupersetBlock.fromJson(Map<String, dynamic> json) => _$SupersetBlockFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$SupersetBlockToJson(this);
}

@JsonSerializable()
class ConditioningBlock extends Block {
  final List<ConditioningItem> items;
  
  ConditioningBlock({ List<ConditioningItem>? items })
      : items = items ?? <ConditioningItem>[],
        super(BlockType.conditioning);

  factory ConditioningBlock.fromJson(Map<String, dynamic> json) => _$ConditioningBlockFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$ConditioningBlockToJson(this);
}