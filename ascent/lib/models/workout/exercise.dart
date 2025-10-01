import '../../constants_and_enums/workout_enums/movement_pattern.dart';

class Exercise {
  final String id;
  final String name;
  final String? force; // "pull", "push", "static", or null
  final String level; // "beginner", "intermediate", "expert"
  final String? mechanic; // "compound", "isolation", or null
  final String? equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String category;
  final List<MovementPattern> movementPatterns;
  final List<String> workoutStyles;

  Exercise({
    required this.id,
    required this.name,
    this.force,
    required this.level,
    this.mechanic,
    this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
    required this.movementPatterns,
    required this.workoutStyles,
  });

  factory Exercise.fromJson(Map<String, dynamic> json, String id) {
    return Exercise(
      id: id,
      name: json['name'] as String,
      force: json['force'] as String?,
      level: json['level'] as String,
      mechanic: json['mechanic'] as String?,
      equipment: json['equipment'] as String?,
      primaryMuscles: (json['primaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] as String,
      movementPatterns: (json['movementPatterns'] as List<dynamic>?)
              ?.map((e) => MovementPattern.fromJson(e as String))
              .toList() ??
          [],
      workoutStyles: (json['workoutStyles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'force': force,
        'level': level,
        'mechanic': mechanic,
        'equipment': equipment,
        'primaryMuscles': primaryMuscles,
        'secondaryMuscles': secondaryMuscles,
        'instructions': instructions,
        'category': category,
        'movementPatterns': movementPatterns.map((p) => p.toJson()).toList(),
        'workoutStyles': workoutStyles,
      };
}
