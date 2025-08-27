import 'package:json_annotation/json_annotation.dart';
import '../models/block.dart';

class BlockConverter implements JsonConverter<Block, Map<String, dynamic>> {
  const BlockConverter();

  @override
  Block fromJson(Map<String, dynamic> json) {
    return Block.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Block object) {
    return object.toJson();
  }
}

class BlockListConverter implements JsonConverter<List<Block>, List<dynamic>> {
  const BlockListConverter();

  @override
  List<Block> fromJson(List<dynamic> json) => 
      json.map((e) => Block.fromJson(Map<String, dynamic>.from(e))).toList();

  @override
  List<dynamic> toJson(List<Block> object) => 
      object.map((b) => b.toJson()).toList();
}