import '../../constants_and_enums/rep_kind.dart';

class RepSpec {
  final RepKind kind;
  final int? value; // when fixed
  final int? min;   // when range
  final int? max;   // when range

  RepSpec.fixed(int v)
      : kind = RepKind.fixed,
        value = v,
        min = null,
        max = null;

  RepSpec.range({ required this.min, required this.max })
      : kind = RepKind.range,
        value = null;

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

  factory RepSpec.fromJson(Map<String, dynamic> json) => RepSpec.fromAny(json);
  
  Map<String, dynamic> toJson() {
    switch (kind) {
      case RepKind.fixed:
        return { 'kind': 'fixed', 'value': value };
      case RepKind.range:
        return { 'kind': 'range', 'min': min, 'max': max };
    }
  }

  double estimateAverage() {
    switch (kind) {
      case RepKind.fixed:
        return (value ?? 10).toDouble();
      case RepKind.range:
        return ((min ?? 8) + (max ?? 12)) / 2.0;
    }
  }
}