import '../../enums/exercise_style.dart';
import '../../enums/session_type.dart';

class Workout{

  DateTime? date; //Sunday date of the week
  SessionType type; // Micro or macro workout
  ExerciseStyle style; // Primary style (cardio, strength, etc)
  bool _isCompleted = false;

  Workout({
    this.date,
    required this.type,
    required this.style,
    bool isCompleted = false,
  }) : _isCompleted = isCompleted;

  get isCompleted => _isCompleted;
  
  void markCompleted(){
    _isCompleted = true;
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      type: sessionTypeFromString(json['type'] as String),
      style: exerciseStyleFromString(json['style'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date?.toIso8601String(),
    'type': sessionTypeToString(type),
    'style': exerciseStyleToString(style),
    'is_completed': _isCompleted,
  };
}