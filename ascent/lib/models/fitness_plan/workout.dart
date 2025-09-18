import '../../enums/exercise_style.dart';
import '../../enums/session_type.dart';
import '../../constants.dart';

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
      date: json[PlanFields.dateField] != null ? DateTime.parse(json[PlanFields.dateField] as String) : null,
      type: sessionTypeFromString(json[PlanFields.typeField] as String),
      style: exerciseStyleFromString(json[PlanFields.styleField] as String),
      isCompleted: json[PlanFields.isCompletedField] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    PlanFields.dateField: date?.toIso8601String(),
    PlanFields.typeField: sessionTypeToString(type),
    PlanFields.styleField: exerciseStyleToString(style),
    PlanFields.isCompletedField: _isCompleted,
  };
}