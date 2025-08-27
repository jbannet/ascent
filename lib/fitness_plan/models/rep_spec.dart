import 'package:json_annotation/json_annotation.dart';
import '../enums/rep_kind.dart';
import '../converters/enum_converters.dart';

part 'rep_spec.g.dart';

@JsonSerializable()
class RepSpec {
  @RepKindConverter()
  final RepKind kind;
  final int? value; // when fixed
  final int? min;   // when range
  final int? max;   // when range

  RepSpec({
    required this.kind,
    this.value,
    this.min,
    this.max,
  });

  RepSpec.fixed(int v)
      : kind = RepKind.fixed,
        value = v,
        min = null,
        max = null;

  RepSpec.range({ required int min, required int max })
      : kind = RepKind.range,
        value = null,
        min = min,
        max = max;

  factory RepSpec.fromAny(Object? raw) {
    if (raw == null) return RepSpec.fixed(10);
    if (raw is num) return RepSpec.fixed(raw.toInt());
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      if (map.containsKey('kind')) {
        final k = map['kind'] as String;
        if (k == 'fixed') return RepSpec.fixed((map['value'] as num).toInt());
        return RepSpec.range(min: (map['min'] as num).toInt(), max: (map['max'] as num).toInt());
      }
      if (map.containsKey('min') && map.containsKey('max')) {
        return RepSpec.range(min: (map['min'] as num).toInt(), max: (map['max'] as num).toInt());
      }
    }
    throw ArgumentError('Invalid reps payload: $raw');
  }

  factory RepSpec.fromJson(Map<String, dynamic> json) => _$RepSpecFromJson(json);
  Map<String, dynamic> toJson() => _$RepSpecToJson(this);
}