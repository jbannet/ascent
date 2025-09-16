import '../../enums/progression_mode.dart';

class Phase {
  final String name; // Base / Build / Peak / Deload
  final int weeks;
  final String focus;
  final ProgressionMode progressionMode;

  Phase({
    required this.name,
    required this.weeks,
    this.focus = '',
    this.progressionMode = ProgressionMode.doubleProgression,
  });

  factory Phase.fromJson(Map<String, dynamic> json) => Phase(
    name: json['name'] as String,
    weeks: json['weeks'] as int,
    focus: (json['focus'] as String?) ?? '',
    progressionMode: progressionFromString((json['progression'] as String?) ?? (json['progressionMode'] as String?)),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'weeks': weeks,
    'focus': focus,
    'progression': progressionToString(progressionMode),
  };
}